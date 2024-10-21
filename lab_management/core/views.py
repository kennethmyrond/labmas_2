from django.shortcuts import render, redirect, get_object_or_404, HttpResponse
from django.contrib.auth import authenticate, login as auth_login, logout
from django.contrib.auth.decorators import login_required
from django.db.models.functions import TruncDate
from django.contrib import messages
from django.db.models import Q, Sum , Prefetch, F
from django.utils import timezone
from django import forms
from django.http import HttpResponse, JsonResponse, Http404, HttpResponseRedirect
from .forms import LoginForm, InventoryItemForm
from .models import laboratory, Module, item_description, item_types, item_inventory, suppliers, user, suppliers, item_expirations, item_handling
from .models import borrow_info, borrowed_items, borrowing_config, reported_items
from .models import rooms, laboratory_reservations, time_configuration, reservation_blocked
from datetime import timedelta, date, datetime
from django.urls import reverse
from calendar import monthrange
from pyzbar.pyzbar import decode
from PIL import Image 
from io import BytesIO
from django.core.files.uploadedfile import InMemoryUploadedFile
from django.db import connection, models
import json, qrcode, base64, threading, time

# thread every midnight query items to check due date if today (for on holding past due date )
def thread_function():
    prev_day = timezone.now().day  # Start with the current day
    
    while True:
        # Get current date and time
        current_datetime = timezone.now()
        current_day = current_datetime.day

        # Check if the day has changed (execute once every new day)
        if current_day != prev_day:
            # Update `prev_day` to track the day change
            prev_day = current_day

            # 1. Cancel borrows if their `borrow_date` is past today and status is still 'Accepted' ('A')
            expired_borrows = borrow_info.objects.filter(
                status='A',  # Accepted borrows
                borrow_date__lt=current_datetime.date()  # Past borrow dates
            )
            for borrow in expired_borrows:
                borrow.status = 'L'  # Cancel the borrow
                borrow.remarks = "Automatically cancelled due to expired borrow date."
                borrow.save()

            # 2. Handle borrowed items with past due dates
            overdue_borrows = borrow_info.objects.filter(
                status='B',  # Borrowed status
                due_date__lt=current_datetime.date()  # Past due dates
            )
            for borrow in overdue_borrows:
                # Get the borrowed items
                borrowed_items_list = borrowed_items.objects.filter(borrow=borrow)

                for item in borrowed_items_list:
                    # Check if the item hasn't been fully returned
                    if item.qty > item.returned_qty:
                        # Create a reported item for overdue borrowed items
                        reported_item = reported_items.objects.create(
                            borrow=borrow,
                            item=item.item,
                            qty_reported=item.qty - item.returned_qty,
                            report_reason="Overdue item",
                            amount_to_pay=99999,  # You can set an amount if needed
                            status=1  # Pending
                        )
                        reported_item.save()

                # Put borrower's clearance on hold
                borrow.status = 'B'  # Mark borrow as 'Cancelled/On Hold'
                borrow.remarks = "Automatically placed on hold due to overdue items."
                borrow.save()

        # Sleep for 1 hour (3600 seconds)
        time.sleep(3600)

# Start the thread for daily checking
# x = threading.Thread(target=thread_function)
# x.start()

# functions
def get_inventory_history(item_description_instance):
    inventory_items = item_inventory.objects.filter(item=item_description_instance)
    history = item_handling.objects.filter(inventory_item__in=inventory_items).order_by('-updated_on')
    return history

def check_item_expiration(request, item_id):
    # Get the item_description instance by item_id
    item = get_object_or_404(item_description, item_id=item_id)
    
    # Return JSON response with rec_expiration value
    return JsonResponse({
        'rec_expiration': item.rec_expiration
    })

def suggest_items(request):
    query = request.GET.get('query', '')
    selected_laboratory_id = request.session.get('selected_lab')
    suggestions = item_description.objects.filter(item_name__icontains=query, laboratory_id=selected_laboratory_id, is_disabled=0)[:5]

    data = []
    for item in suggestions:
        data.append({
            'item_id': item.item_id,
            'item_name': item.item_name,
            'rec_expiration': item.rec_expiration
        })
    
    return JsonResponse(data, safe=False)

def suggest_suppliers(request):
    if not request.user.is_authenticated:
        return redirect('userlogin')
    
    selected_laboratory_id = request.session.get('selected_lab')
    query = request.GET.get('query', '')
    supplier_suggestions = suppliers.objects.filter(supplier_name__icontains=query, laboratory=selected_laboratory_id, is_disabled=0)[:5]  # Limit the results to 5

    data = []
    for supplier in supplier_suggestions:
        data.append({
            'suppliers_id': supplier.suppliers_id,
            'supplier_name': supplier.supplier_name
        })

    return JsonResponse(data, safe=False)

def remove_item_from_inventory(item_inventory_instance, qty, user, changes):
    if item_inventory_instance.qty >= int(qty):
        item_inventory_instance.qty -= int(qty)
        item_inventory_instance.save()
        
        # Log the removal
        item_handling.objects.create(
            inventory_item=item_inventory_instance,
            updated_on=timezone.now(),
            updated_by=user,
            changes=changes,
            qty=qty,
        )
    else:
        raise ValueError("Not enough quantity in inventory")

def generate_qr_code(item_id):
    # Create a QR code instance
    qr = qrcode.QRCode(
        version=1,
        error_correction=qrcode.constants.ERROR_CORRECT_L,
        box_size=10,
        border=4,
    )

    # Add data to the QR code (in this case, the item_id)
    qr.add_data(f'Item ID: {item_id}')
    qr.make(fit=True)

    # Create an image from the QR code
    img = qr.make_image(fill='black', back_color='white')

    # Convert the image to a byte stream
    buffer = BytesIO()
    img.save(buffer, format="PNG")
    qr_code_img = buffer.getvalue()

    # Encode the byte stream to base64
    qr_code_b64 = base64.b64encode(qr_code_img).decode('utf-8')

    return qr_code_b64  # Return the base64 encoded string

# forms
class ItemEditForm(forms.ModelForm):
    class Meta:
        model = item_description
        fields = ['item_name']


# views

# misc views
def userlogin(request):
    return render(request,"user_login.html")

@login_required(login_url='/login')
def home(request):
    return render(request,"home.html")

def set_lab(request, laboratory_id):
    # Set the chosen laboratory in the session
    lab = get_object_or_404(laboratory, laboratory_id=laboratory_id)
    request.session['selected_lab'] = lab.laboratory_id
    request.session['selected_lab_name'] = lab.name
    return redirect(request.META.get('HTTP_REFERER', '/'))  # Redirect back to the previous page

def logout_view(request):
    logout(request)
    return redirect("/login")

def error_page(request, message=None):
    """
    Renders a generic error page.
    :param request: HTTP request
    :param message: The error message to display (optional)
    """
    return render(request, 'error_page.html', {'message': message})


# inventory
def inventory_view(request):
    if not request.user.is_authenticated:
        return redirect('userlogin')
    
    # Get the selected laboratory from the session
    selected_laboratory_id = request.session.get('selected_lab')
    
    # Get all item types for the selected laboratory
    item_types_list = item_types.objects.filter(laboratory_id=selected_laboratory_id)
    
    # Get the selected item_type from the GET parameters
    selected_item_type = request.GET.get('item_type')

    # Filter inventory items by both the selected item_type and the selected laboratory,
    # and ensure the item is not disabled
    if selected_item_type:
        inventory_items = item_description.objects.filter(
            itemType_id=selected_item_type,
            laboratory_id=selected_laboratory_id,
            is_disabled=0  # Only get items that are enabled
        ).annotate(total_qty=Sum('item_inventory__qty'))  # Calculate total quantity
        selected_item_type_instance = item_types.objects.get(pk=selected_item_type)
        add_cols = json.loads(selected_item_type_instance.add_cols)
    else:
        inventory_items = item_description.objects.filter(
            laboratory_id=selected_laboratory_id,
            is_disabled=0  # Only get items that are enabled
        ).annotate(total_qty=Sum('item_inventory__qty'))  # Calculate total quantity
        add_cols = []

    return render(request, 'mod_inventory/view_inventory.html', {
        'inventory_items': inventory_items,
        'item_types': item_types_list,
        'selected_item_type': int(selected_item_type) if selected_item_type else None,
        'add_cols': add_cols,
    })

def inventory_itemDetails_view(request, item_id):
    if not request.user.is_authenticated:
        return redirect('userlogin')
    
    # Get the item_description instance
    item = get_object_or_404(item_description, item_id=item_id)

    # Parse add_cols JSON
    add_cols_data = json.loads(item.add_cols) if item.add_cols else {}

    # Get the related itemType instance
    item_type = item.itemType

    # Get the related laboratory instance
    lab = get_object_or_404(laboratory, laboratory_id=item.laboratory_id)

    # Get all item_inventory entries for the specified item_id
    # Prefetch item_handling related to item_inventory
    item_handling_prefetch = Prefetch('item_handling_set', queryset=item_handling.objects.all())
    # Filter item_inventory and prefetch related supplier and item_handling data
    item_inventories = item_inventory.objects.filter(item=item).select_related('supplier').prefetch_related(item_handling_prefetch)

    # Calculate the total quantity
    total_qty = item_inventories.aggregate(Sum('qty'))['qty__sum'] or 0

    qr_code_data = generate_qr_code(item.item_id)

    # Prepare context for rendering
    context = {
        'item': item,
        'itemType_name': item_type.itemType_name if item_type else None,
        'laboratory_name': lab.name if lab else None,
        'item_inventories': item_inventories,
        #  'item_expirations': item_expiration,
        'total_qty': total_qty,
        'add_cols_data': add_cols_data,
        'is_edit_mode': False,  # Not in edit mode
        'qr_code_data': qr_code_data,
    }

    return render(request, 'mod_inventory/inventory_itemDetails.html', context)

def inventory_addNewItem_view(request):
    if not request.user.is_authenticated:
        return redirect('userlogin')
    
    selected_lab = request.session.get('selected_lab')
    if selected_lab:
        item_types_list = item_types.objects.filter(laboratory_id=selected_lab)
    else:
        item_types_list = item_types.objects.none()  # No lab selected, show nothing or handle it accordingly

    qr_code_image = None  # Placeholder for QR code image
    
    if request.method == "POST":
        # Extract form data
        item_name = request.POST.get('item_name')
        item_type_id = request.POST.get('item_type')
        rec_expiration = request.POST.get('rec_expiration') == 'on'
        alert_qty = request.POST.get('alert_qty')

        # Dynamic fields from additional columns (based on the selected item_type)
        item_type = item_types.objects.get(itemType_id=item_type_id)
        add_cols_dict = {}
        if item_type.add_cols:
            add_cols = json.loads(item_type.add_cols)
            for col in add_cols:
                field_value = request.POST.get(f'add_col_{col.lower()}')
                add_cols_dict[col] = field_value

        # Convert the additional columns to a JSON string
        add_cols_json = json.dumps(add_cols_dict)

        # Save the data to the database
        new_item = item_description(
            laboratory_id=selected_lab,
            item_name=item_name,
            itemType_id=item_type_id,
            add_cols=add_cols_json,
            alert_qty=alert_qty,
            rec_expiration = rec_expiration,
        )
        new_item.save()

        qr_code_data = generate_qr_code(new_item.item_id)
        # Render the page with QR code and modal trigger
        return render(request, 'mod_inventory/inventory_addNewItem.html', {
            'item_types': item_types_list,
            'qr_code_data': qr_code_data,
            'new_item': new_item,  # Pass new item details for modal
            'show_modal': True,    # Flag to show the modal
        })

    return render(request, 'mod_inventory/inventory_addNewItem.html', {
        'item_types': item_types_list,
        'selected_lab_name': request.session.get('selected_lab_name'),
    })

def inventory_updateItem_view(request):
    if not request.user.is_authenticated:
        return redirect('userlogin')
    
    if request.method == 'POST':
        item_id = request.POST.get('item_name')
        action_type = request.POST.get('action_type')
        amount = request.POST.get('amount') if action_type == 'add' else request.POST.get('quantity_removed')
        item_date_purchased = request.POST.get('item_date_purchased')
        item_date_received = request.POST.get('item_date_received')
        item_price = request.POST.get('item_price')
        item_supplier_id = request.POST.get('item_supplier')
        remarks = request.POST.get('remarks', '')  # Additional field for remarks in case of damage/loss

        # Fetch item and supplier
        item_description_instance = get_object_or_404(item_description, item_id=item_id)
        current_user = get_object_or_404(user, user_id=request.user.id)

        expiration_date = None
        if item_description_instance.rec_expiration and 'expiration_date' in request.POST:
            expiration_date = request.POST.get('expiration_date')

        # Add or remove inventory logic
        if action_type == 'add':
            supplier_instance = get_object_or_404(suppliers, suppliers_id=item_supplier_id)
            new_inventory_item = item_inventory.objects.create(
                item=item_description_instance,
                supplier=supplier_instance,
                date_purchased=item_date_purchased,
                date_received=item_date_received,
                purchase_price=item_price,
                qty=amount,
                remarks="add"
            )
            item_handling.objects.create(
                inventory_item=new_inventory_item,
                updated_on=timezone.now(),
                updated_by=current_user,
                changes='A',
                qty=amount,
                remarks='add'
            )
            # If expiration date is provided, save it
            if expiration_date:
                item_expirations.objects.create(
                    inventory_item=new_inventory_item,
                    expired_date=expiration_date
                )
        elif action_type == 'remove':
            # Handle remove from inventory
            # Filter item_inventory by item, join with item_expirations, filter by quantity, and order by expired_date
            if item_description_instance.rec_expiration == 1:
                item_inventory_queryset = item_inventory.objects.filter(
                    item=item_description_instance,
                    qty__gt=0
                ).annotate(
                    expired_date=F('item_expirations__expired_date')
                ).order_by('expired_date')
            else:
                item_inventory_queryset = item_inventory.objects.filter(
                    item=item_description_instance,
                    qty__gt=0
                ).order_by('inventory_item_id')

            # Initialize the amount to be removed
            remaining_amount = int(amount)

            # Iterate through the queryset and deduct the quantity
            for item_inventory_instance in item_inventory_queryset:
                if remaining_amount <= 0:
                    break

                if item_inventory_instance.qty >= remaining_amount:
                    try:
                        remove_item_from_inventory(item_inventory_instance, remaining_amount, current_user, 'R', 'Remove')
                        remaining_amount = 0
                    except ValueError as e:
                        print(e)
                        break
                else:
                    try:
                        remaining_amount = remaining_amount - int(item_inventory_instance.qty)
                        remove_item_from_inventory(item_inventory_instance, item_inventory_instance.qty, current_user, 'R', 'Remove')
                    except ValueError as e:
                        print(e)
                        break

            if remaining_amount > 0:
                print(f"Could not remove the full amount. {remaining_amount} items remaining.")
            else:
                print("Successfully removed the requested amount.")

        elif action_type == 'damage':
            # Handle reporting damaged/lost items
            if item_description_instance.rec_expiration == 1:
                item_inventory_queryset = item_inventory.objects.filter(
                    item=item_description_instance,
                    qty__gt=0
                ).annotate(
                    expired_date=F('item_expirations__expired_date')
                ).order_by('expired_date')
            else:
                item_inventory_queryset = item_inventory.objects.filter(
                    item=item_description_instance,
                    qty__gt=0
                ).order_by('inventory_item_id')

            remaining_amount = int(amount)

            # Iterate through the queryset and deduct the quantity
            for item_inventory_instance in item_inventory_queryset:
                if remaining_amount <= 0:
                    break
                if item_inventory_instance.qty >= remaining_amount:
                    try:
                        remove_item_from_inventory(item_inventory_instance, remaining_amount, current_user, 'R', remarks=remarks)
                        remaining_amount = 0
                    except ValueError as e:
                        print(e)
                        break
                else:
                    try:
                        remaining_amount = remaining_amount - int(item_inventory_instance.qty)
                        remove_item_from_inventory(item_inventory_instance, item_inventory_instance.qty, current_user, 'R', remarks=remarks)
                    except ValueError as e:
                        print(e)
                        break

            if remaining_amount > 0:
                print(f"Could not report the full damaged amount. {remaining_amount} items remaining.")
            else:
                print("Successfully reported damaged/lost items.")

        # Success message
        context = {
            'success_message': f"Item {'added to' if action_type == 'add' else 'removed from'} inventory successfully!"
        }

        return render(request, 'mod_inventory/inventory_updateItem.html', context)

    return render(request, 'mod_inventory/inventory_updateItem.html')

# Helper function for removing items from inventory
def remove_item_from_inventory(inventory_item, amount, user, change_type, remarks=''):
    if inventory_item.qty < amount:
        raise ValueError("Not enough items in inventory to remove.")

    inventory_item.qty -= amount
    inventory_item.save()

    # Record the item handling
    item_handling.objects.create(
        inventory_item=inventory_item,
        updated_on=timezone.now(),
        updated_by=user,
        changes=change_type,
        qty=amount,
        remarks=remarks,
    )

def inventory_itemEdit_view(request, item_id):
    if not request.user.is_authenticated:
        return redirect('userlogin')
    
    # Get the item_description instance
    item = get_object_or_404(item_description, item_id=item_id)

    # Parse add_cols JSON
    add_cols_data = json.loads(item.add_cols) if item.add_cols else {}

    if request.method == 'POST':
        form = ItemEditForm(request.POST, instance=item)
        
        # Handle additional form fields (rec_expiration, alert_qty)
        rec_expiration = request.POST.get('rec_expiration', 'off') == 'on'  # True if checked, False if not
        alert_qty_disabled = request.POST.get('disable_alert_qty', 'off') == 'on'  # Is alert_qty disabled?

        if form.is_valid():
            # Save the main form fields
            form.save()

            # Update additional columns
            for label in add_cols_data.keys():
                add_cols_data[label] = request.POST.get(label, '')
            
            item.add_cols = json.dumps(add_cols_data)
            
            # Handle rec_expiration and alert_qty logic
            item.rec_expiration = rec_expiration
            if alert_qty_disabled:
                item.alert_qty = 0  # If disabled, set alert_qty to 0
            else:
                item.alert_qty = request.POST.get('alert_qty', item.alert_qty)  # Update alert_qty if not disabled
            
            # Save the item
            item.save()

            return redirect('inventory_itemDetails_view', item_id=item_id)
    else:
        form = ItemEditForm(instance=item)

    return render(request, 'mod_inventory/inventory_itemEdit.html', {
        'form': form,
        'item': item,
        'add_cols_data': add_cols_data,
        'is_alert_disabled': item.alert_qty == 0,  # Alert if disabled
    })

def inventory_itemDelete_view(request, item_id):
    if not request.user.is_authenticated:
        return redirect('userlogin')
    
    item = get_object_or_404(item_description, item_id=item_id)

      # Redirect to view inventory after disabling
    if request.method == 'POST':
        item.is_disabled = 1  # Mark item as disabled
        item.save()
        return redirect('inventory_view')

    # Prepare context for rendering the confirmation template
    item_type = item.itemType
    lab = get_object_or_404(laboratory, laboratory_id=item.laboratory_id)
    context = {
        'item': item,
        'itemType_name': item_type.itemType_name if item_type else None,
        'laboratory_name': lab.name if lab else None,
    }

    

    return render(request, 'mod_inventory/inventory_itemDelete.html', context)

def inventory_physicalCount_view(request):
    if not request.user.is_authenticated:
        return redirect('userlogin')
    
    # Get the selected laboratory from the session
    selected_laboratory_id = request.session.get('selected_lab')
    item_types_list = item_types.objects.filter(laboratory_id=selected_laboratory_id)
    selected_item_type = request.GET.get('item_type')
    current_user = get_object_or_404(user, user_id=request.user.id)

    # Filter items by laboratory and selected item type
    if selected_item_type:
        inventory_items = item_description.objects.filter(
            laboratory_id=selected_laboratory_id, 
            itemType_id=selected_item_type, 
            is_disabled=0
        ).annotate(total_qty=Sum('item_inventory__qty'))
    else:
        inventory_items = item_description.objects.filter(
            laboratory_id=selected_laboratory_id, 
            is_disabled=0
        ).annotate(total_qty=Sum('item_inventory__qty'))
    
    # Check if the form is submitted
    if request.method == "POST":
        for item in inventory_items:
            c_qty = request.POST.get(f'count_qty_{item.item_id}')
            print(f'Item ID: {item.item_id}, Count Qty: {c_qty}')  # For debugging
            
            # Ensure the count_qty is not None and convert it to an integer
            if c_qty is not None and c_qty != '':
                count_qty = int(c_qty)  # Get the count qty from the form
                current_qty = item.total_qty or 0  # total qty from item_inventory

                if count_qty != current_qty:
                    discrepancy_qty = count_qty - current_qty

                    # If discrepancy_qty is positive, add items to the inventory
                    if discrepancy_qty > 0:
                        # Add the discrepancy_qty to the item
                        item_inventory_instance = item_inventory.objects.create(
                            item=item,
                            qty=discrepancy_qty,
                            date_purchased=timezone.now(),
                            date_received=timezone.now(),
                            remarks="Physical count adjustment",
                            supplier=None  # Supplier can be left as None for physical adjustments
                        )
                        # Log this addition in item_handling
                        item_handling.objects.create(
                            inventory_item=item_inventory_instance,
                            updated_on=timezone.now(),
                            updated_by=current_user,
                            changes='Y',  # A for Add
                            qty=discrepancy_qty
                        )

                    # If discrepancy_qty is negative, remove items from the inventory
                    elif discrepancy_qty < 0:
                        remaining_amount = abs(discrepancy_qty)  # Calculate how many items to remove

                        # Query item_inventory instances with positive qty and order by expiration date (if any)
                        item_inventory_queryset = item_inventory.objects.filter(
                            item=item,
                            qty__gt=0
                        ).annotate(
                            expired_date=F('item_expirations__expired_date')
                        ).order_by('expired_date')

                        item_description_instance = get_object_or_404(item_description, item_id=item.item_id)
                        if item_description_instance.rec_expiration == 1:
                            item_inventory_queryset = item_inventory.objects.filter(
                                item=item_description_instance,
                                qty__gt=0
                            ).annotate(
                                expired_date=F('item_expirations__expired_date')
                            ).order_by('expired_date')
                        else:
                            item_inventory_queryset = item_inventory.objects.filter(
                                item=item_description_instance,
                                qty__gt=0
                            ).order_by('inventory_item_id')

                        # Iterate through item_inventory instances to remove the items
                        for item_inventory_instance in item_inventory_queryset:
                            if remaining_amount <= 0:
                                break

                            if item_inventory_instance.qty >= remaining_amount:
                                try:
                                    remove_item_from_inventory(item_inventory_instance, remaining_amount, current_user, 'P')
                                    remaining_amount = 0
                                except ValueError as e:
                                    print(e)
                                    break
                            else:
                                try:
                                    remove_item_from_inventory(item_inventory_instance, item_inventory_instance.qty, current_user, 'P')
                                    remaining_amount -= item_inventory_instance.qty
                                except ValueError as e:
                                    print(e)
                                    break

                    # Step 4: Update the item_description.qty with the new count qty
                    item.qty = count_qty
                    item.save()

        messages.success(request, 'Physical count saved successfully!')

    return render(request, 'mod_inventory/inventory_physicalCount.html', {
        'inventory_items': inventory_items,
        'item_types': item_types_list,
        'selected_item_type': int(selected_item_type) if selected_item_type else None,
    })

def inventory_manageSuppliers_view(request):
    if not request.user.is_authenticated:
        return redirect('userlogin')

    selected_laboratory_id = request.session.get('selected_lab')
    
    # Annotate suppliers with the count of items supplied in item_inventory
    lab_suppliers = suppliers.objects.filter(laboratory=selected_laboratory_id, is_disabled=0).annotate(
        supplied_items_count=models.Count('item_inventory')
    )

    if request.method == "POST":
        supplier_name = request.POST.get("supplier_name")
        contact_person = request.POST.get("contact_person")
        contact_number = request.POST.get("contact_number")
        supplier_desc = request.POST.get("description")

        new_supplier = suppliers(
            laboratory_id=selected_laboratory_id,
            supplier_name=supplier_name,
            contact_person=contact_person,
            contact_number=contact_number,
            description=supplier_desc
        )
        new_supplier.save()

        return redirect('inventory_manageSuppliers')

    return render(request, 'mod_inventory/inventory_manageSuppliers.html', {
        'suppliers': lab_suppliers,
    })

def inventory_supplierDetails_view(request, supplier_id):
    if not request.user.is_authenticated:
        return redirect('userlogin')

    # Get the supplier details using the supplier_id
    supplier = get_object_or_404(suppliers, suppliers_id=supplier_id)

    # Get item handling entries associated with the supplier
    item_handling_entries = item_handling.objects.filter(
        inventory_item__supplier=supplier,
        changes='A'
    ).select_related('inventory_item')

    if request.method == "POST":
        if 'edit_supplier' in request.POST:
            # Handle supplier edit
            supplier.supplier_name = request.POST.get("supplier_name")
            supplier.contact_person = request.POST.get("contact_person") or None
            supplier.contact_number = request.POST.get("contact_number") or None
            supplier.description = request.POST.get("description") or None
            supplier.save()

            return redirect('inventory_supplierDetails', supplier_id=supplier.suppliers_id)
        
        elif 'disable_supplier' in request.POST:
            # Handle supplier disable
            supplier.is_disabled = True
            supplier.save()

            return redirect('inventory_manageSuppliers')

    return render(request, 'mod_inventory/inventory_supplierDetails.html', {
        'supplier': supplier,
        'item_handling_entries': item_handling_entries,
    })

def inventory_config_view(request):
    if not request.user.is_authenticated:
        return redirect('login')

    # Retrieve the selected laboratory ID from the session
    selected_lab = request.session.get('selected_lab')
    
    # Query categories based on the selected laboratory ID
    if selected_lab:
        categories = item_types.objects.filter(laboratory_id=selected_lab)
    else:
        categories = item_types.objects.none()  # No categories if no lab is selected

    # Get attributes for the first category if it exists
    attributes = json.loads(categories[0].add_cols) if categories.exists() else []

    # Prepare the context for rendering the template
    context = {
        'categories': categories,
        'attributes': attributes
    }

    return render(request, 'mod_inventory/inventory_config.html', context)

def add_category(request):
    if not request.user.is_authenticated:
        return redirect('userlogin')

    # Get laboratory_id from the session
    laboratory_id = request.session.get('selected_lab')

    if not laboratory_id:
        messages.error(request, "No laboratory selected.")
        return redirect('inventory_config')

    if request.method == 'POST':
        category_name = request.POST.get('category')  # Change 'category_name' to 'category'
        add_cols = request.POST.get('add_cols')  # Ensure you have this input field in your form

        # Debugging output to check what is received
        print(f"Received category_name: {category_name}, add_cols: {add_cols}")  

        if not category_name:  # Check if category_name is empty
            messages.error(request, "Category name cannot be empty.")
            return redirect('inventory_config')

        new_category = item_types(
            laboratory_id=laboratory_id,
            itemType_name=category_name,
            # add_cols=add_cols
        )
        new_category.save()

        messages.success(request, 'Category added successfully!')
        return redirect('inventory_config')

    return render(request, 'mod_inventory/add_category.html')

def delete_category(request, category_id):
    if request.method == 'POST':
        category = get_object_or_404(item_types, pk=category_id)

        # Optional: Ensure that the category belongs to the selected laboratory
        selected_lab = request.session.get('selected_lab')
        if category.laboratory_id != selected_lab:
            return JsonResponse({'success': False, 'message': "Category does not belong to the selected laboratory."}, status=400)

        category.delete()  # Delete the category from item_types
        messages.success(request, 'Category deleted successfully!')
        return JsonResponse({'success': True})

    return JsonResponse({'success': False}, status=400)

def add_attributes(request):
    if request.method == 'POST':
        category_id = request.POST['category']
        attribute_name = request.POST['attributeName']
        
        # Gather all fixed values from the inputs
        fixed_values = request.POST.getlist('fixedValues')

        category = get_object_or_404(item_types, pk=category_id)

        # Check if the category belongs to the selected laboratory
        selected_lab = request.session.get('selected_lab')
        if category.laboratory_id != selected_lab:
            return JsonResponse({'success': False, 'message': "Category does not belong to the selected laboratory."}, status=400)

        # Initialize add_cols if necessary
        if category.add_cols is None:
            add_cols = []  # Initialize to empty list
        else:
            add_cols = json.loads(category.add_cols)

        # Create a combined attribute string with fixed values if any
        if fixed_values:
            combined_attribute = f"{attribute_name} ({', '.join(fixed_values)})"
        else:
            combined_attribute = attribute_name

        if combined_attribute not in add_cols:  # Prevent duplicate attributes
            add_cols.append(combined_attribute)
            category.add_cols = json.dumps(add_cols)
            category.save()
            return JsonResponse({'success': True, 'attribute': combined_attribute})
        else:
            return JsonResponse({'success': False, 'message': "Attribute already exists."})

    return JsonResponse({'success': False, 'message': "Invalid request."})

def get_fixed_choices(request, category_id):
    category = get_object_or_404(item_types, pk=category_id)
    return JsonResponse({'fixed_choices': category.fixed_choices})

def delete_attribute(request, category_id, attribute_name):
    if request.method == 'POST':
        category = get_object_or_404(item_types, pk=category_id)

        # Check if the category belongs to the selected laboratory
        selected_lab = request.session.get('selected_lab')
        if category.laboratory_id != selected_lab:
            return JsonResponse({'success': False, 'message': "Category does not belong to the selected laboratory."}, status=400)

        # Load the current add_cols and ensure it is a valid list
        try:
            add_cols = json.loads(category.add_cols) if category.add_cols else []
        except json.JSONDecodeError:
            add_cols = []  # Handle case where add_cols might not be valid JSON
        
        # Remove the attribute if it exists
        if attribute_name in add_cols:
            add_cols.remove(attribute_name)
            category.add_cols = json.dumps(add_cols)
            category.save()
            return JsonResponse({'success': True})
        else:
            return JsonResponse({'success': False, 'message': 'Attribute not found.'}, status=404)

    return JsonResponse({'success': False}, status=400)
    
def get_add_cols(request, category_id):
    category = get_object_or_404(item_types, pk=category_id)
    add_cols = json.loads(category.add_cols) if category.add_cols else []
    return JsonResponse({'add_cols': add_cols})


# =====================================================

#BORROWING
def borrowing_view(request):
    return render(request, 'mod_borrowing/borrowing.html')

def borrowing_student_prebookview(request):
    try:
        laboratory_id = request.session.get('selected_lab')
        user_id = request.user.id
        lab = get_object_or_404(borrowing_config, laboratory_id=laboratory_id)

        # Check if pre-booking is allowed
        if not lab.allow_prebook:
            return render(request, 'error_page.html', {'message': 'Pre-booking is not allowed for this laboratory.'})

        # Fetch the prebook-specific questions
        prebook_questions = lab.get_questions(mode='prebook')

        # Fetch all inventory items
        inventory_items = item_description.objects.filter(
            laboratory_id=laboratory_id,
            is_disabled=0,
            allow_borrow=1  # Only get items that can be borrowed
        ).select_related('itemType').annotate(total_qty=Sum('item_inventory__qty'))

        # Group items by their itemType
        items_by_type = {}
        for item in inventory_items:
            item_type = item.itemType.itemType_name
            if item_type not in items_by_type:
                items_by_type[item_type] = []
            items_by_type[item_type].append(item)

        if request.method == 'POST':
            # Fetch form data
            borrowing_type = request.POST.get('borrowing-type')
            one_day_date = request.POST.get('one_day_booking_date')
            from_date = request.POST.get('from_date')
            to_date = request.POST.get('to_date')

            # Collect responses to the custom questions
            custom_question_responses = {}
            for question in prebook_questions:
                custom_question_responses[question['question_text']] = request.POST.get(question['question_text'])

            request_date = timezone.now().date()

            # Determine borrow and due dates based on borrowing type
            error_message = None
            if borrowing_type == 'oneday':
                borrow_date = one_day_date
                due_date = one_day_date

                # Validate that the borrowing date is not in the past
                if one_day_date < request_date.strftime('%Y-%m-%d'):
                    error_message = 'The borrowing date cannot be earlier than today for one-day borrowing.'

                # Validate the one-day borrowing: must be at least 3 days from the request date
                min_borrow_date = request_date + timedelta(days=int(lab.prebook_lead_time))
                if one_day_date < min_borrow_date.strftime('%Y-%m-%d'):
                    error_message = f'For one-day borrowing, the requested date must be at least {lab.prebook_lead_time} days from today.'
            else:
                borrow_date = from_date
                due_date = to_date

                # Validate the long-term borrowing
                min_from_date = request_date + timedelta(days=int(lab.prebook_lead_time))
                if from_date < min_from_date.strftime('%Y-%m-%d'):
                    error_message = f'The "From" date for long-term borrowing must be at least {lab.prebook_lead_time} days from the request date.'

                if to_date < from_date:
                    error_message = '"To" date cannot be earlier than the "From" date.'

            # If there is an error, re-render the form with the error message
            if error_message:
                return render(request, 'mod_borrowing/borrowing_studentPrebook.html', {
                    'error_message': error_message,
                    'current_date': request_date,
                    'items_by_type': items_by_type,  # Include grouped items here
                })

            # If validation passes, proceed with insertion
            borrow_entry = borrow_info.objects.create(
                laboratory_id=laboratory_id,
                user_id=user_id,
                request_date=timezone.now(),  # Use current timestamp
                borrow_date=borrow_date,
                due_date=due_date,
                status='P',  # Set initial status to 'Pending'
                questions_responses=custom_question_responses
            )

            # Process equipment details
            equipment_rows = request.POST.getlist('equipment_ids[]')  # List of equipment items
            quantities = request.POST.getlist('quantities[]')       # Corresponding quantities

            for i, item_id in enumerate(equipment_rows):
                quantity = int(quantities[i])
                # Fetch the item from core_item_description
                item = item_description.objects.get(item_id=item_id)
                
                # Insert the item into borrowed_items table
                borrowed_items.objects.create(
                    borrow=borrow_entry,
                    item=item,
                    qty=quantity
                )
            return redirect('borrowing_studentviewPreBookRequests')

        current_date = timezone.now().date()

    except Http404:
        return render(request, 'error_page.html', {'message': 'The laboratory was not found.'})

    return render(request, 'mod_borrowing/borrowing_studentPrebook.html', {
        'current_date': current_date,
        'items_by_type': items_by_type,  # Pass grouped items to the template
        'prebook_questions': prebook_questions  # Pass the prebook questions to the template
    })


def get_items_by_type(request, item_type_id):
    try:
        items = item_description.objects.filter(itemType_id=item_type_id, is_disabled=0, allow_borrow=1)
        item_list = []

        for item in items:
            # Calculate total quantity for each item
            total_qty = item_inventory.objects.filter(item_id=item.item_id).aggregate(total_qty=Sum('qty'))['total_qty'] or 0
            
            item_list.append({
                'item_id': item.item_id,
                'item_name': item.item_name,
                'total_qty': total_qty  # Include total quantity in the response
            })

        return JsonResponse(item_list, safe=False)
    except Exception as e:
        # Log the exception for debugging
        print(f"Error fetching items: {e}")
        return JsonResponse({'error': str(e)}, status=500)
    
def get_quantity_for_item(request, item_id):
    try:
        # Fetch the total quantity for the specified item_id
        total_quantity = item_inventory.objects.filter(item_id=item_id).aggregate(total_qty=Sum('qty'))['total_qty'] or 0
        return JsonResponse({'total_qty': total_quantity})
    except Exception as e:
        print(f"Error fetching quantity: {e}")
        return JsonResponse({'error': str(e)}, status=500)

def borrowing_student_walkinview(request):
    # Get session details
    laboratory_id = request.session.get('selected_lab')
    user_id = request.user.id

    # Fetch the lab's borrowing configuration
    lab = get_object_or_404(borrowing_config, laboratory_id=laboratory_id)

    # Check if walk-ins are allowed
    if not lab.allow_walkin:
        return render(request, 'error_page.html', {'message': 'Walk-ins are not allowed for this laboratory.'})

    # Fetch the walk-in-specific questions
    walkin_questions = lab.get_questions(mode='walkin')

    # Fetch all inventory items
    inventory_items = item_description.objects.filter(
        laboratory_id=laboratory_id,
        is_disabled=0,
        allow_borrow=1  # Only get items that can be borrowed
     ).select_related('itemType').annotate(total_qty=Sum('item_inventory__qty'))
    
    # Group items by their itemType
    items_by_type = {}
    for item in inventory_items:
        item_type = item.itemType.itemType_name
        if item_type not in items_by_type:
            items_by_type[item_type] = []
        items_by_type[item_type].append(item)

    if request.method == 'POST':
        request_date = timezone.now()
        borrow_date = request_date
        due_date = request_date

        # Collect responses to the custom walk-in questions
        custom_question_responses = {}
        for question in walkin_questions:
            response = request.POST.get(question['question_text'])
            custom_question_responses[question['question_text']] = response

        # Insert into core_borrow_info
        borrow_entry = borrow_info.objects.create(
            laboratory_id=laboratory_id,
            user_id=user_id,
            request_date=request_date,
            borrow_date=borrow_date,
            due_date=due_date,
            status='P',  # Set initial status to 'Pending'
            questions_responses=custom_question_responses  # Save the user's responses to the questions
        )

        # Process equipment details
        equipment_rows = request.POST.getlist('equipment_ids[]')  # List of equipment items
        quantities = request.POST.getlist('quantities[]')       # Corresponding quantities

        # Validate equipment quantities and items
        error_message = None
        for i, item_id in enumerate(equipment_rows):
            try:
                quantity = int(quantities[i])
                if quantity <= 0:
                    error_message = 'Quantity must be greater than 0 for each item.'
                    break

                # Check if item exists and is borrowable
                item = item_description.objects.filter(item_id=item_id, is_disabled=0, allow_borrow=1).first()
                if not item:
                    error_message = f'Item with ID {item_id} is not available for borrowing.'
                    break
            except (ValueError, IndexError) as e:
                error_message = 'Invalid quantity or item ID.'
                break

        if error_message:
            return render(request, 'mod_borrowing/borrowing_studentWalkIn.html', {
                'current_date': request_date.date(),
                'equipment_list': item_description.objects.filter(laboratory_id=laboratory_id, is_disabled=0, allow_borrow=1),
                'error_message': error_message,
                'inventory_items': inventory_items,
                'walkin_questions': walkin_questions,  # Pass walk-in questions back to the template
                 'items_by_type': items_by_type,  # Pass grouped items to the template
            })

        # If validation passes, insert items into borrowed_items
        for i, item_id in enumerate(equipment_rows):
            quantity = int(quantities[i])
            if quantity <= 0:
                continue  # Skip if quantity is invalid

            item = item_description.objects.get(item_id=item_id)

            # Check if item already exists in borrowed_items
            existing_borrowed_item = borrowed_items.objects.filter(borrow=borrow_entry, item=item).first()
            if existing_borrowed_item:
                continue  # Skip insertion if it already exists

            # Insert the item into borrowed_items table
            borrowed_item = borrowed_items.objects.create(
                borrow=borrow_entry,
                item=item,
                qty=quantity
            )

        return redirect('borrowing_studentviewWalkInRequests')

    # Fetch the current date and all equipment items including chemicals
    current_date = timezone.now().date()

    # Get unique item types for dropdown filtering
    item_types_list = item_types.objects.filter(laboratory_id=laboratory_id)

    # Fetch all equipment items including their total quantities
    equipment_list = item_description.objects.filter(
        laboratory_id=laboratory_id,
        is_disabled=0,
        allow_borrow=1  # Only include items that can be borrowed
    ).annotate(total_qty=Sum('item_inventory__qty'))  # Annotate with total quantity

    # Get all item types for the selected laboratory
    item_types_list = item_types.objects.filter(laboratory_id=laboratory_id)

    # Fetch inventory items and order them by item type name
    inventory_items = item_description.objects.filter(
        laboratory_id=laboratory_id,
        is_disabled=0,  # Only get items that are enabled
        allow_borrow=1  # Only get items that can be borrowed
    ).annotate(total_qty=Sum('item_inventory__qty'))  # Calculate total quantity
    inventory_items = inventory_items.select_related('itemType').order_by('itemType__itemType_name')  # Order by itemType name

    return render(request, 'mod_borrowing/borrowing_studentWalkIn.html', {
        'current_date': current_date,
        'equipment_list': equipment_list,
        'item_types': item_types_list,  # Pass item types to the template
        'inventory_items': inventory_items,
        'walkin_questions': walkin_questions,  # Pass the walk-in questions to the template
        'items_by_type': items_by_type,  # Pass grouped items to the template
    })


# booking requests
def borrowing_student_viewPreBookRequestsview(request):
    if not request.user.is_authenticated:
        return redirect('userlogin')

    current_user = get_object_or_404(user, user_id=request.user.id)

    # Get the borrowing configuration for the laboratory
    laboratory_id = request.session.get('selected_lab')
    lab_config = get_object_or_404(borrowing_config, laboratory_id=laboratory_id)

    # Filter borrow_info based on statuses
    prebook_requests = borrow_info.objects.annotate(
        truncated_request_date=TruncDate('request_date')
    ).filter(
        user=current_user,
        request_date__isnull=False,
        borrow_date__isnull=False
    ).exclude(
        truncated_request_date=F('borrow_date')  # Exclude same-day requests (walk-ins)
    ).order_by('-request_date')

    # Walk-in requests: where request_date == borrow_date
    walkin_requests = borrow_info.objects.filter(
        user=current_user,
        request_date=F('borrow_date'),  # Walk-ins: request_date equals borrow_date
        request_date__isnull=False,
        borrow_date__isnull=False
    ).order_by('-request_date')


    # Filter pre-book requests by status
    pending_requests = prebook_requests.filter(status='P')
    accepted_requests = prebook_requests.filter(status='A')
    declined_requests = prebook_requests.filter(status='D')
    borrowed_requests = prebook_requests.filter(status='B')
    cancelled_requests = prebook_requests.filter(status='C')
    completed_requests = prebook_requests.filter(status='X')

    # Walk-in request statuses
    walkin_pending_requests = walkin_requests.filter(status='P')
    walkin_accepted_requests = walkin_requests.filter(status='A')
    walkin_declined_requests = walkin_requests.filter(status='D')
    walkin_borrowed_requests = walkin_requests.filter(status='B')
    walkin_cancelled_requests = walkin_requests.filter(status='C')
    walkin_completed_requests = walkin_requests.filter(status='X')

    return render(request, 'mod_borrowing/borrowing_studentViewPreBookRequests.html', {
        'pending_requests': pending_requests,
        'accepted_requests': accepted_requests,
        'declined_requests': declined_requests,
        'borrowed_requests': borrowed_requests,
        'cancelled_requests': cancelled_requests,
        'completed_requests': completed_requests,
        'walkin_pending_requests': walkin_pending_requests,
        'walkin_accepted_requests': walkin_accepted_requests,
        'walkin_declined_requests': walkin_declined_requests,
        'walkin_borrowed_requests': walkin_borrowed_requests,
        'walkin_cancelled_requests': walkin_cancelled_requests,
        'walkin_completed_requests': walkin_completed_requests,
        'lab_config': lab_config,  # Pass borrowing config to template
        'prebook_requests_all': prebook_requests,
    })
# @require_POST
def cancel_borrow_request(request):
    try:
        data = json.loads(request.body)
        borrow_id = data.get('borrow_id')

        borrow_entry = borrow_info.objects.get(borrow_id=borrow_id)
        # Only allow cancel if the status is pending
        if borrow_entry.status == 'P':
            borrow_entry.status = 'C'  # Canceled
            borrow_entry.save()
            return JsonResponse({'success': True, 'message': 'Request successfully canceled.'})
        return JsonResponse({'success': False, 'message': 'Only pending requests can be canceled.'})
    except borrow_info.DoesNotExist:
        return JsonResponse({'success': False, 'message': 'Request not found.'})

def borrowing_student_WalkInRequestsview(request):
    if not request.user.is_authenticated:
        return redirect('userlogin')

    current_user = get_object_or_404(user, user_id=request.user.id)

    # Annotate the request date as truncated date (without time) and exclude records where dates match
    prebook_requests = borrow_info.objects.annotate(
        truncated_request_date=TruncDate('request_date')
    ).filter(
        user=current_user,
        request_date__isnull=False,
        borrow_date__isnull=False
    ).exclude(
        truncated_request_date=F('borrow_date')
    ).order_by('-request_date')

    return render(request, 'mod_borrowing/borrowing_studentViewWalkInRequests.html', {
        'prebook_requests': prebook_requests,
    })

def borrowing_student_detailedPreBookRequestsview(request, borrow_id):
    if not request.user.is_authenticated:
        return redirect('userlogin')

    # Get the borrow_info instance using the borrow_id
    borrow_request = get_object_or_404(borrow_info, borrow_id=borrow_id)

    # Get all the items that were borrowed under this request
    borrowed_items_list = borrowed_items.objects.filter(borrow=borrow_request)

    return render(request, 'mod_borrowing/borrowing_studentDetailedPreBookRequests.html', {
        'borrow_request': borrow_request,
        'borrowed_items': borrowed_items_list,
    })

def borrowing_student_detailedWalkInRequestsview(request):
    if not request.user.is_authenticated:
        return redirect('userlogin')

    # Get the borrow_info instance using the borrow_id
    borrow_request = get_object_or_404(borrow_info, borrow_id=borrow_id)

    # Get all the items that were borrowed under this request
    borrowed_items_list = borrowed_items.objects.filter(borrow=borrow_request)

    return render(request, 'mod_borrowing/borrowing_studentDetailedWalkInRequests.html', {
        'borrow_request': borrow_request,
        'borrowed_items': borrowed_items_list,
    })


def borrowing_labcoord_prebookrequests(request):
    if not request.user.is_authenticated:
        return redirect('userlogin')
    
    # Get selected status from the GET request, default to 'P' (Pending)
    selected_status = request.GET.get('status', 'P')

    # Filter borrowing requests based on the selected status
    if selected_status == 'all':
        borrowing_requests = borrow_info.objects.all().order_by('request_date')
    else:
        borrowing_requests = borrow_info.objects.filter(status=selected_status).order_by('request_date')

    if request.method == 'POST':
        # Get borrow_id and action from form submission
        borrow_id = request.POST.get('borrow_id')
        action = request.POST.get('action')

        # Retrieve the borrow_info object
        borrow_request = get_object_or_404(borrow_info, borrow_id=borrow_id)

        # Update status based on the action
        if action == 'approve':
            borrow_request.status = 'A'
            borrow_request.approved_by = request.user  # Set the approving lab coordinator
            borrow_request.save()
            messages.success(request, f"Borrow request {borrow_id} has been approved.")
        elif action == 'reject':
            borrow_request.status = 'D'
            borrow_request.approved_by = request.user
            borrow_request.save()
            messages.success(request, f"Borrow request {borrow_id} has been rejected.")

        return redirect('borrowing_labcoord_prebookrequests')

    return render(request, 'mod_borrowing/borrowing_labcoord_prebookrequests.html', {
        'borrowing_requests': borrowing_requests,
        'selected_status': selected_status,  # Pass the selected status to the template
    })

def borrowing_labcoord_borrowconfig(request):
    selected_laboratory_id = request.session.get('selected_lab')

    # Fetch all active (not disabled) items under the selected laboratory
    items = item_description.objects.filter(laboratory_id=selected_laboratory_id, is_disabled=False)

    # Fetch all item types under the selected laboratory
    item_types_list = item_types.objects.filter(laboratory_id=selected_laboratory_id)

    # Fetch the lab's borrowing configuration
    lab = get_object_or_404(borrowing_config, laboratory_id=selected_laboratory_id)

    # Annotate each item type to check if all items under it are borrowable
    for type in item_types_list:
        type.all_items_borrowable = item_description.objects.filter(itemType_id=type.itemType_id, allow_borrow=False).count() == 0

    if request.method == 'POST':
        if 'lab_config_form' in request.POST:
            lab.allow_walkin = 'allow_walkin' in request.POST
            lab.allow_prebook = 'allow_prebook' in request.POST
            lab.prebook_lead_time = request.POST.get('prebook_lead_time') or None
            lab.allow_shortterm = 'allow_shortterm' in request.POST
            lab.allow_longterm = 'allow_longterm' in request.POST
            lab.save()
            messages.success(request, 'Borrowing configurations updated successfully!')
            return redirect('borrowing_labcoord_borrowconfig')

        elif 'borrow_config_form' in request.POST:
            allowed_items = request.POST.getlist('borrow_item')  # Items explicitly checked
            allowed_item_types = request.POST.getlist('borrow_item_type')  # Item types explicitly checked

            # Reset borrowability for all items to False
            item_description.objects.filter(laboratory_id=selected_laboratory_id).update(allow_borrow=False)

            # Handle individual items: Set allow_borrow=True for explicitly checked items
            if allowed_items:
                item_description.objects.filter(item_id__in=allowed_items).update(allow_borrow=True)
                # p2=get_object_or_404(item_description, item_id__in=allowed_items)
                # print(p2.item_name)
                # print(p2.allow_borrow)

            # Handle item types: Set allow_borrow=True for all items under the checked item types
            if allowed_item_types:
                item_description.objects.filter(itemType_id__in=allowed_item_types).update(allow_borrow=True)

            # Update is_consumable for item types and handle unchecking of item types
            for type in item_types_list:
                # Update the consumable status of the item type
                type.is_consumable = f'is_consumable_{type.itemType_id}' in request.POST
                type.save()

                # If the item type is checked in the form, mark all items under this type as borrowable
                if str(type.itemType_id) in allowed_item_types:
                    item_description.objects.filter(itemType_id=type.itemType_id).update(allow_borrow=True)
                else:
                    # If unchecked, ensure items under this type are set to allow_borrow=False
                    item_description.objects.filter(itemType_id=type.itemType_id).update(allow_borrow=False)

            messages.success(request, "Borrowing configuration updated successfully!")
            return redirect('borrowing_labcoord_borrowconfig')
        
        elif 'add_question_form' in request.POST:
            question_text = request.POST.get('question_text')
            input_type = request.POST.get('input_type')
            borrowing_mode = request.POST.get('borrowing_mode')  # New: borrow mode (walk-in, pre-book, both)
            dropdown_choices = request.POST.get('dropdown_choices', '').split(',') if input_type == 'dropdown' else None

            lab.add_question(question_text, input_type, borrowing_mode, dropdown_choices)
            messages.success(request, 'Question added successfully!')
            return redirect('borrowing_labcoord_borrowconfig')

        elif 'update_question_form' in request.POST:
            index = int(request.POST.get('question_index'))
            question_text = request.POST.get('question_text')
            input_type = request.POST.get('input_type')
            borrowing_mode = request.POST.get('borrowing_mode')  # New: borrow mode (walk-in, pre-book, both)
            dropdown_choices = request.POST.get('dropdown_choices', '').split(',') if input_type == 'dropdown' else None

            lab.update_question(index, question_text, input_type, borrowing_mode, dropdown_choices)
            messages.success(request, 'Question updated successfully!')
            return redirect('borrowing_labcoord_borrowconfig')

        elif 'remove_question_form' in request.POST:
            index = int(request.POST.get('question_index'))

            lab.remove_question(index)
            messages.success(request, 'Question removed successfully!')
            return redirect('borrowing_labcoord_borrowconfig')

    return render(request, 'mod_borrowing/borrowing_labcoord_borrowconfig.html', {
        'items': items,
        'item_types_list': item_types_list,
        'lab': lab,
        'questions': lab.get_questions()  # Get the questions to display them
    })

def borrowing_labcoord_detailedPrebookrequests(request, borrow_id):
    borrow_request = get_object_or_404(borrow_info, borrow_id=borrow_id)
    borrowed_items_list = borrowed_items.objects.filter(borrow=borrow_request)

    if request.method == 'POST':
        action = request.POST.get('action')
        
        # Handle declining request
        if action == 'decline':
            decline_reason = request.POST.get('decline_reason')
            if decline_reason:
                borrow_request.status = 'D'  # Declined
                borrow_request.remarks = decline_reason
                borrow_request.save()
                messages.success(request, 'The request has been declined.')
            else:
                messages.error(request, 'Please provide a reason for declining.')
        
        # Handle accepting request
        elif action == 'accept':
            borrow_request.status = 'A'  # Accepted
            borrow_request.remarks = "Accepted"
            borrow_request.save()
            messages.success(request, 'The request has been accepted.')

        return redirect('borrowing_labcoord_detailedPrebookrequests', borrow_id=borrow_id)

    # Only show action buttons if the request is still pending or if the status is accepted/declined (to allow modification)
    show_action_buttons = borrow_request.status in ['P', 'A', 'D']

    return render(request, 'mod_borrowing/borrowing_labcoord_DetailedPrebookRequests.html', {
        'borrow_request': borrow_request,
        'borrowed_items_list': borrowed_items_list,
        'show_action_buttons': show_action_buttons,
    })


def return_borrowed_items(request):
    borrow_id = request.POST.get('borrow_id', '')  # Fetch borrow_id from POST or use empty string

    # Check if the borrow_id is provided and fetch the relevant data
    borrow_entry = None
    borrowed_items_list = None
    consumed_items_list = None

    if borrow_id:
        try:
            selected_laboratory_id = request.session.get('selected_lab')
            borrow_entry = get_object_or_404(borrow_info, borrow_id=borrow_id, laboratory_id=selected_laboratory_id)

            # Display error message if status is not 'B' (borrowed)
            if borrow_entry.status != 'B':
                messages.error(request, 'Status of borrowing request is not applicable for returning')
            
            borrowed_items_list = borrowed_items.objects.filter(borrow=borrow_entry, item__is_consumable=False).annotate(remaining_borrowed=F('qty') - F('returned_qty'))
            consumed_items_list = borrowed_items.objects.filter(borrow=borrow_entry, item__is_consumable=True).annotate(remaining_borrowed=F('qty') - F('returned_qty'))
        except borrow_info.DoesNotExist:
            borrow_entry = None  # Show no data if the borrow ID is invalid

    if request.method == 'POST' and 'return_items' in request.POST and borrow_entry and borrow_entry.status == 'B':
        # Process return and report submission
        for item in borrowed_items_list:
            returned_all = request.POST.get(f'returned_all_{item.item.item_id}', False) == 'on'
            qty_returned = int(request.POST.get(f'return_qty_{item.item.item_id}', 0))
            hold_clearance = request.POST.get(f'hold_clearance_{item.item.item_id}', False) == 'on'
            remarks = request.POST.get(f'remarks_{item.item.item_id}', '').strip()
            amount_to_pay = request.POST.get(f'amount_to_pay_{item.item.item_id}', 0)

            # Handle item returns
            if returned_all:
                item.returned_qty = item.qty  # Mark all items as returned
            else:
                item.returned_qty = qty_returned  # Only return the specified quantity

            item.save()

            # Handle hold clearance and issue reporting
            if hold_clearance and remarks:
                reported_items.objects.create(
                    borrow=borrow_entry,
                    item=item.item,
                    qty_reported=item.qty - item.returned_qty,  # Remaining items not returned
                    report_reason=remarks,
                    amount_to_pay=amount_to_pay or 0
                )

        # Automatically mark all consumed items as returned
        for consumed_item in consumed_items_list:
            consumed_item.returned_qty = consumed_item.qty
            consumed_item.save()

        # Update the status if all items are returned
        if all(item.qty == item.returned_qty for item in borrowed_items_list) and \
           all(item.qty == item.returned_qty for item in consumed_items_list):
            borrow_entry.status = 'X'  # Mark as completed
            borrow_entry.save()

        return redirect('return_borrowed_items')

    return render(request, 'mod_borrowing/borrowing_return_borrowed_items.html', {
        'borrow_entry': borrow_entry,
        'borrowed_items_list': borrowed_items_list,
        'consumed_items_list': consumed_items_list,
        'borrow_id': borrow_id,
    })

def borrowing_labtech_prebookrequests(request):
    selected_laboratory_id = request.session.get('selected_lab')
    
    today = date.today()
    
    # Fetch borrowing requests based on their borrow_date
    today_borrows = borrow_info.objects.filter(borrow_date=today, status='A', laboratory_id=selected_laboratory_id).select_related('user')
    future_borrows = borrow_info.objects.filter(borrow_date__gt=today, status='A', laboratory_id=selected_laboratory_id).select_related('user')
    past_borrows = borrow_info.objects.filter(borrow_date__lt=today, status='A', laboratory_id=selected_laboratory_id).select_related('user')
    cancelled_borrows = borrow_info.objects.filter(status='L', laboratory_id=selected_laboratory_id).select_related('user')
    borrowed_borrows = borrow_info.objects.filter(status='B', laboratory_id=selected_laboratory_id).select_related('user')

    # Fetch all accepted borrow requests sorted by request_date
    accepted_borrows = borrow_info.objects.filter(status='A', laboratory_id=selected_laboratory_id).order_by('-request_date').select_related('user')

    if request.method == 'POST':
        borrow_id = request.POST.get('borrow_id')
        action = request.POST.get('action')
        remarks = request.POST.get('remarks', '')

        # Update borrow_info status
        borrow_entry = get_object_or_404(borrow_info, borrow_id=borrow_id)
        
        if action == 'borrowed':
            borrow_entry.status = 'B'  # Mark as Borrowed
        elif action == 'cancel':
            borrow_entry.status = 'L'  # Mark as Cancelled
            borrow_entry.remarks = remarks  # Save cancellation remarks
        borrow_entry.save()

        return redirect('borrowing_labtech_prebookrequests')

    return render(request, 'mod_borrowing/borrowing_labtech_prebookrequests.html', {
        'today_borrows': today_borrows,
        'future_borrows': future_borrows,
        'past_borrows': past_borrows,
        'cancelled_borrows': cancelled_borrows,
        'accepted_borrows': accepted_borrows,
        'borrowed_borrows': borrowed_borrows
    })

def borrowing_labtech_detailedprebookrequests(request, borrow_id):
    borrow_entry = get_object_or_404(borrow_info, borrow_id=borrow_id)
    borrowed_items1 = borrowed_items.objects.filter(borrow=borrow_entry)
    
    if request.method == 'POST':
        action = request.POST.get('action')
        remarks = request.POST.get('remarks', '')

        if action == 'borrowed':
            borrow_entry.status = 'B'
        elif action == 'cancel':
            borrow_entry.status = 'L'
            borrow_entry.remarks = remarks  # Save cancellation remarks
        borrow_entry.save()

        return redirect('borrowing_labtech_prebookrequests')

    return render(request, 'mod_borrowing/borrowing_labtech_detailedprebookrequests.html', {
        'borrow_entry': borrow_entry,
        'borrowed_items': borrowed_items1,
    })




#CLEARANCE
def clearance_view(request):
    return render(request, 'mod_clearance/clearance.html')

def clearance_student_viewClearance(request):
    # Get the currently logged-in user
    user = request.user

    # Debugging output to verify the user instance
    if not user.is_authenticated:
        return render(request, 'mod_clearance/student_viewClearance.html', {'error': 'User is not authenticated.'})

    # Use the user instance's ID for querying
    user_id = user.id
    selected_laboratory_id = request.session.get('selected_lab')

    try:
        # Retrieve the borrow_info entries for the current user
        user_borrows = borrow_info.objects.filter(user_id=user_id, laboratory_id=selected_laboratory_id)

        # Check if the user has any borrows
        if user_borrows.exists():
            reports = reported_items.objects.filter(borrow__in=user_borrows)

            # Handle the filter by status
            status = request.GET.get('status', 'All')
            if status != 'All':
                if status == 'Cleared':
                    reports = reports.filter(status=0)  # Clear status
                elif status == 'Pending':
                    reports = reports.filter(status=1)  # Pending status
        else:
            reports = reported_items.objects.none()  # No reports if no borrows

    except Exception as e:
        reports = reported_items.objects.none()  # If there's an error, return no reports
        print(f"Error fetching reports: {e}")  # Debugging output for error tracking

    context = {
        'reports': reports,
    }
    return render(request, 'mod_clearance/student_viewClearance.html', context)


def clearance_student_viewClearanceDetailed(request, borrow_id):
    # Get the currently logged-in user
    user = request.user

    # Debugging output to verify the user instance
    if not user.is_authenticated:
        return render(request, 'mod_clearance/student_viewClearanceDetailed.html', {'error': 'User is not authenticated.'})

    # Use the user instance's ID for querying
    user_id = user.id

    try:
        # Retrieve the borrow_info entries for the current user
        user_borrow = borrow_info.objects.filter(user=user_id, borrow_id=borrow_id).first()

        if user_borrow:
            # Retrieve reported items associated with the borrow_info entry
            reports = reported_items.objects.filter(borrow=user_borrow)
        else:
            reports = reported_items.objects.none()  # No reports if no borrows

    except Exception as e:
        reports = reported_items.objects.none()  # If there's an error, return no reports
        print(f"Error fetching reports: {e}")  # Debugging output for error tracking

    # Include borrow details in the context
    borrow_details = {
        'borrow_id': user_borrow.borrow_id if user_borrow else None,
        'request_date': user_borrow.request_date if user_borrow else None,
        'borrow_date': user_borrow.borrow_date if user_borrow else None,
        'due_date': user_borrow.due_date if user_borrow else None,
        'questions_responses': user_borrow.questions_responses if user_borrow else {},
    }

     
    
    context = {
        'reports': reports,
        'borrow_details': borrow_details,
    
    }
    return render(request, 'mod_clearance/student_viewClearanceDetailed.html', context)

def clearance_labtech_viewclearance(request):
    # Get the currently logged-in user (labtech)
    user = request.user

    # Ensure the user is authenticated
    if not user.is_authenticated:
        return render(request, 'mod_clearance/labtech_viewclearance.html', {'error': 'User is not authenticated.'})

    # Retrieve the selected laboratory ID from the session
    selected_laboratory_id = request.session.get('selected_lab')

    try:
         # Fetch all reported items related to the selected laboratory, regardless of status
        reports = reported_items.objects.filter(borrow__laboratory_id=selected_laboratory_id)

        # Filter by status if needed
        status_filter = request.GET.get('status', 'All')
        if status_filter == 'Cleared':
            reports = reports.filter(status=0)  # status=0 means Cleared
        elif status_filter == 'Pending':
            reports = reports.filter(status=1)  # status=1 means Pending

        # Create a context with the reports
        report_data = []
        for report in reports:
            borrow_info_obj = report.borrow
            user_obj = borrow_info_obj.user
            item_obj = report.item

            # Add data to the context
            report_data.append({
                'report_id': report.id,
                'borrow_id': borrow_info_obj.borrow_id,  # RF#
                'user_name': f"{user_obj.firstname} {user_obj.lastname}",  # Student's Name
                'id_number': user_obj.id_number,  # Fetch ID number from user
                'item_name': item_obj.item_name,  # Item Name
                'reason': report.report_reason,  # Report Reason
                'amount_due': report.amount_to_pay,  # Amount to Pay
                'status': 'Pending' if report.status == 1 else 'Cleared',  # Status
            })

    except Exception as e:
        report_data = []  # In case of an error, show an empty list
        print(f"Error fetching reports: {e}")

    context = {
        'reports': report_data,
    }
    return render(request, 'mod_clearance/labtech_viewclearance.html', context)


def clearance_labtech_viewclearanceDetailed(request, report_id):
    # Get the reported item by ID
    report = get_object_or_404(reported_items, id=report_id)

    if request.method == 'POST':
        # Handle remarks submission and marking as cleared
        remarks = request.POST.get('remarks', '').strip()
        if remarks:
            report.remarks = remarks
        
        # Update the status to Cleared
        report.status = 0  # Assuming status 0 means Cleared
        report.save()

        # Redirect to the same page or to the view clearance page
        return HttpResponseRedirect(request.path_info)

     # Prepare the context for rendering
    context = {
        'RFno': report.borrow.borrow_id,  # RF#
        'student_name': f"{report.borrow.user.firstname} {report.borrow.user.lastname}",  # Student's Name
        'ID_number': report.borrow.user.id_number,  # Student's Name
        'item_name': report.item.item_name,  # Item Name
        'reason': report.report_reason,  # Reason
        'amount_due': report.amount_to_pay,  # Amount Due
        'status': 'Pending' if report.status == 1 else 'Cleared',  # Status
        'remarks': report.remarks if report.remarks else '',  # Fetch remarks if they exist
    }
    
    return render(request, 'mod_clearance/labtech_viewclearanceDetailed.html', context)




# lab reserv ================================================================= 
def lab_reservation_view(request):
    return render(request, 'mod_labRes/lab_reservation.html')

def lab_reservation_student_reserveLabChooseRoom(request):
    selected_laboratory_id = request.session.get('selected_lab')
    today = timezone.now().date()
    min_reservation_date = today + timedelta(days=0)

    reservation_date = request.GET.get('reservationDate')
    error_message = None

    if reservation_date:
        reservation_date = datetime.strptime(reservation_date, '%Y-%m-%d').date()
        if reservation_date < min_reservation_date:
            error_message = "Selected date must be at least 3 days from today."
    else:
        error_message = "Please select a reservation date."

    if error_message:
        context = {
            'error_message': error_message,
            'min_reservation_date': min_reservation_date,
        }
        return render(request, 'mod_labRes/lab_reservation_studentReserveLabChooseRoom.html', context)

    capacity_filter = request.GET.get('capacityFilter', '')

    # Fetch rooms based on selected lab and not disabled
    rooms_query = rooms.objects.filter(laboratory_id=selected_laboratory_id, is_disabled=False, is_reservable=True)

    # Filter by room capacity if provided
    if capacity_filter:
        rooms_query = rooms_query.filter(capacity__gte=capacity_filter)

    # Create time intervals (7AM to 5PM)
    time_slots = [f"{hour:02d}:00" for hour in range(7, 17)]
    # time_slots = [(f"{hour:02d}:00", f"{hour + 1:02d}:00") for hour in range(7, 17)] #for start and end

    # Fetch existing reservations for the selected date
    existing_reservations = laboratory_reservations.objects.filter(
        room__laboratory_id=selected_laboratory_id, start_date=reservation_date)

    time_slots = [f"{hour:02d}:00" for hour in range(7, 17)]

    room_availability = {}
    for room in rooms_query:
        availability = {}
        for start in time_slots:
            slot_key = f"{start}"
            reserved = existing_reservations.filter(
                room=room,
                start_time__lte=start,
                end_time__gt=start,
                status='R' or 'A'
            ).exists()
            availability[slot_key] = 'red' if reserved else 'green'
        room_availability[room.room_id] = availability


    print(room_availability)
    context = {
        'rooms': rooms_query,
        'time_slots': time_slots,
        'room_availability': room_availability,  # Flat structure
        'reservation_date': reservation_date,
        'min_reservation_date': min_reservation_date,
        'capacity_filter': capacity_filter,
        'error_message': error_message,  # Pass the error message to the template if any
    }

    return render(request, 'mod_labRes/lab_reservation_studentReserveLabChooseRoom.html', context)

def lab_reservation_student_reserveLabConfirm(request):
    if request.method == 'POST':
        selected_room_id = request.POST.get('selectedRoom')
        selected_date = request.POST.get('selectedDate')
        selected_start_time = request.POST.get('selectedStartTime')
        selected_end_time = request.POST.get('selectedEndTime')

        # Fetch room information
        selected_room = get_object_or_404(rooms, room_id=selected_room_id)

        # Check if the room is already reserved for the selected date and time
        existing_reservation = laboratory_reservations.objects.filter(
            room=selected_room,
            start_date=selected_date,
            status='R'
        ).filter(
            start_time__lt=selected_end_time,
            end_time__gt=selected_start_time
        ).exists()

        if existing_reservation:
            error_message = "The selected time slot for this room is already booked."
            messages.error(request, error_message)
            return HttpResponseRedirect(request.META.get('HTTP_REFERER', '/'))

        # Save the reservation data in session temporarily for confirmation
        request.session['reservation_data'] = {
            'room': selected_room.name,
            'selected_date': selected_date,
            'start_time': selected_start_time,
            'end_time': selected_end_time,
        }

        return redirect('lab_reservation_student_reserveLabConfirmDetails')

    return HttpResponse("Invalid request", status=400)

def lab_reservation_student_reserveLabConfirmDetails(request):
    reservation_data = request.session.get('reservation_data')
    current_user = get_object_or_404(user, user_id=request.user.id)

    if not reservation_data:
        return redirect('lab_reservation_student_reserveLabChooseRoom')

    if request.method == 'POST':
        # Get user details (if logged in) or allow input from non-logged-in users
        # user = request.user if request.user.is_authenticated else None
        contact_name = request.POST.get('contact_name')
        contact_email = request.POST.get('contact_email')
        num_people = request.POST.get('num_people')
        purpose = request.POST.get('purpose')

        print(contact_name)
        print(contact_email)

        # Save the reservation to the database
        reservation = laboratory_reservations.objects.create(
            user=current_user or None,
            room=rooms.objects.get(name=reservation_data['room']),
            start_date=reservation_data['selected_date'],
            start_time=reservation_data['start_time'],
            end_time=reservation_data['end_time'],
            contact_name=contact_name,
            contact_email=contact_email,
            contact_number=0,
            num_people=num_people,
            purpose=purpose,
            status='R'  # Reserved
        )

        # Clear session data and redirect to the booking list page
        del request.session['reservation_data']
        return redirect('lab_reservation_detail', reservation.reservation_id)

    return render(request, 'mod_labRes/lab_reservation_studentReserveLabConfirm.html', {
        'reservation_data': reservation_data,
        'user': request.user if request.user.is_authenticated else None
    })

# not used for now
def lab_reservation_student_reserveLabChooseTime(request):
     return render(request, 'mod_labRes/lab_reservation_studentReserveLabChooseTime.html')

def lab_reservation_student_reserveLabSummary(request):
    # Get the current user
    # current_user = request.user
    current_user = get_object_or_404(user, user_id=request.user.id)
    
    # Get today's date
    today = timezone.now().date()

    # Filter reservations by categories
    tab = request.GET.get('tab', 'all')  # Default to 'today' tab
    reservations = laboratory_reservations.objects.filter(user=current_user)

    if tab == 'today':
        reservations = reservations.filter(start_date=today)
    elif tab == 'previous':
        reservations = reservations.filter(start_date__lt=today)
    elif tab == 'future':
        reservations = reservations.filter(start_date__gt=today)
    elif tab == 'cancelled':
        reservations = reservations.filter(status='C')  # Assuming 'C' is the status for cancelled
    else:
        reservations = reservations.all()

    context = {
        'reservations': reservations,
        'tab': tab,
    }

    return render(request, 'mod_labRes/lab_reservation_studentReserveLabSummary.html', context)

def cancel_reservation(request, reservation_id):
    # Get the reservation object by id
    current_user = get_object_or_404(user, user_id=request.user.id)
    reservation = get_object_or_404(laboratory_reservations, reservation_id=reservation_id, user=current_user)

    # Change the status to 'Cancelled' (assuming 'C' represents cancelled)
    reservation.status = 'C'
    reservation.save()

    # Redirect to the reservation summary page
    return redirect('lab_reservation_student_reserveLabSummary')

def lab_reservation_detail(request, reservation_id):
    # Get the reservation object by its ID
    current_user = get_object_or_404(user, user_id=request.user.id)
    reservation = get_object_or_404(laboratory_reservations, reservation_id=reservation_id, user=current_user)

    context = {
        'reservation': reservation,
    }

    return render(request, 'mod_labRes/lab_reservation_detail.html', context)

def labres_lab_schedule(request):
    selected_laboratory_id = request.session.get('selected_lab')
    room_list = []
    reservations = []
    selected_month = None
    selected_room = None
    reservations_by_day = {}

      # Get the current month
    current_month = datetime.now().strftime('%Y-%m')  # Format: YYYY-MM

    if selected_laboratory_id:
        room_list = rooms.objects.filter(laboratory_id=selected_laboratory_id, is_disabled=False)

    if request.method == "GET":
        selected_room = request.GET.get('roomSelect')
        selected_month = request.GET.get('selectMonth', current_month)
        
        if selected_room and selected_month:
            try:
                room = rooms.objects.get(name=selected_room, laboratory_id=selected_laboratory_id)

                # Get the first and last day of the selected month
                year, month = map(int, selected_month.split('-'))
                start_date = datetime(year, month, 1)
                end_date = (start_date + timedelta(days=31)).replace(day=1) - timedelta(days=1)

                # Get reservations for the selected month
                reservations = laboratory_reservations.objects.filter(
                    room_id=room.room_id,  # Ensure you use room.room_id to access the ID
                    start_date__range=[start_date, end_date]
                )

                # Format start_time and end_time for each reservation
                for reservation in reservations:
                    reservation.formatted_start_time = reservation.start_time.strftime("%I:%M%p") if reservation.start_time else "N/A"
                    reservation.formatted_end_time = reservation.end_time.strftime("%I:%M%p") if reservation.end_time else "N/A"

                # Prepare a list to hold reservations indexed by day
                days_in_month = monthrange(year, month)[1]
                reservations_by_day = {day: [] for day in range(1, days_in_month + 1)}

                # Organize reservations by day
                for reservation in reservations:
                    reservations_by_day[reservation.start_date.day].append(reservation)

            except rooms.DoesNotExist:
                print(f"Room '{selected_room}' does not exist.")
            except Exception as e:
                print(f"Error occurred: {str(e)}")

    context = {
        'room_list': room_list,
        'reservations_by_day': reservations_by_day,  # Pass the organized reservations
        'selected_month': selected_month,
        'selected_room': selected_room,
    }

    return render(request, 'mod_labRes/labres_lab_schedule.html', context)

def labres_lab_reservationreqs(request):
    selected_laboratory_id = request.session.get('selected_lab')
    reservations = []
    selected_room = None
    selected_date = None
    room_list = []

    if selected_laboratory_id:
        room_list = rooms.objects.filter(laboratory_id=selected_laboratory_id, is_disabled=False)

    if request.method == "GET":
        selected_room = request.GET.get('roomSelect')
        selected_date = request.GET.get('selectDate')

        if selected_room and selected_date:
            try:
                room = rooms.objects.get(name=selected_room, laboratory_id=selected_laboratory_id)
                reservations = laboratory_reservations.objects.filter(
                    room=room,
                    start_date=selected_date,
                )

                # Format start_time, end_time and calculate interval
                for reservation in reservations:
                    # Format time as 9:00AM
                    reservation.formatted_start_time = reservation.start_time.strftime("%I:%M%p")
                    reservation.formatted_end_time = reservation.end_time.strftime("%I:%M%p")

                    # Combine start_date with start_time and end_time to get datetime objects
                    start_datetime = datetime.combine(reservation.start_date, reservation.start_time)
                    end_datetime = datetime.combine(reservation.start_date, reservation.end_time)

                    # Calculate the time difference in minutes
                    time_difference = end_datetime - start_datetime
                    reservation.time_interval = int(time_difference.total_seconds() // 60)


            except rooms.DoesNotExist:
                pass

        # Handle POST requests for Accept and Delete actions
    if request.method == "POST":
        action = request.POST.get('action')

        if action:
            # Check if the action is accept or delete for a specific reservation
            if action.startswith("accept_"):
                reservation_id = action.split("_")[1]
                reservation = get_object_or_404(laboratory_reservations, reservation_id=reservation_id)

                if reservation.status == 'P':  # Only update if pending
                    reservation.status = 'A'  # Change status to Approved
                    reservation.save()

            elif action.startswith("delete_"):
                reservation_id = action.split("_")[1]
                reservation = get_object_or_404(laboratory_reservations, reservation_id=reservation_id)

                if reservation.status == 'P':  # Only update if pending
                    reservation.status = 'L'  # Change status to Cancelled by Lab Tech
                    reservation.save()

        # Redirect to avoid form resubmission on page reload
        return HttpResponseRedirect(reverse('labres_lab_reservationreqs'))
    
    context = {
        'room_list': room_list,
        'reservations': reservations,
        'selected_room': selected_room,
        'selected_date': selected_date,
    }

    return render(request, 'mod_labRes/labres_lab_reservationreqs.html', context)

def labres_lab_reservationreqsDetailed(request, reservation_id):
    selected_laboratory_id = request.session.get('selected_lab')

    try:
        reservation = laboratory_reservations.objects.get(reservation_id=reservation_id)
        room = rooms.objects.get(room_id=reservation.room.room_id, laboratory_id=selected_laboratory_id)
    except (laboratory_reservations.DoesNotExist, rooms.DoesNotExist):
        reservation = None
        room = None

    if request.method == "POST":
        action = request.POST.get('action')
        if action == 'accept':
            # Change status to 'Approved' ('A')
            reservation.status = 'A'
        elif action == 'delete':
            # Change status to 'Cancelled' ('L')
            reservation.status = 'D'
        reservation.save()

        return redirect('labres_lab_reservationreqsDetailed', reservation_id=reservation_id)

    context = {
        'reservation': reservation,
        'room': room,
    }

    return render(request, 'mod_labRes/labres_lab_reservationreqsDetailed.html', context)



def labres_labcoord_configroom(request):
    selected_laboratory_id = request.session.get('selected_lab')

    # Handle Room Configuration
    if request.method == "POST":
        if 'save_rooms' in request.POST:
            # Update is_reservable field for rooms
            for room in rooms.objects.filter(laboratory_id=selected_laboratory_id):
                room.is_reservable = f'room_{room.room_id}_enabled' in request.POST
                room.save()

            # Handle deleting rooms
        elif 'delete_room' in request.POST:
            delete_room_id = request.POST.get('delete_room')
            room = get_object_or_404(rooms, room_id=delete_room_id)
            room.is_disabled = True
            room.save()

        elif 'add_room' in request.POST:
            # Add a new room
            room_name = request.POST.get('room_name')
            room_capacity = request.POST.get('room_capacity')
            room_description = request.POST.get('room_description')

            if room_name and room_capacity:
                new_room = rooms(
                    laboratory_id=selected_laboratory_id,
                    name=room_name,
                    capacity=room_capacity,
                    description=room_description
                )
                new_room.save()

        elif 'save_time' in request.POST:
            # Save time configuration
            is_global = request.POST.get('global_config') == 'on'
            if is_global:
                time_config, _ = time_configuration.objects.get_or_create(is_global=True)
            else:
                room_id = request.POST.get('room_id')
                room = get_object_or_404(rooms, pk=room_id)
                time_config, _ = time_configuration.objects.get_or_create(room=room)

            time_config.reservation_type = request.POST.get('reservation_type')

            if time_config.reservation_type == 'hourly':
                time_config.start_time = request.POST.get('hourly_start_time')
                time_config.end_time = request.POST.get('hourly_end_time')

            time_config.save()

            # Save blocked times
            for day in ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday']:
                for time_slot in request.POST.getlist(f'{day}_time_slots'):
                    start_time, end_time = time_slot.split('-')
                    is_blocked = f'{day}_{start_time}_{end_time}_blocked' in request.POST
                    reservation_blocked.objects.update_or_create(
                        time_config=time_config, day_of_week=day, start_time=start_time, end_time=end_time,
                        defaults={'is_blocked': is_blocked}
                    )

        elif 'cancel' in request.POST:
            # Logic to cancel changes
            pass

    # Fetch data to display
    rooms_query = rooms.objects.filter(laboratory_id=selected_laboratory_id, is_disabled=False)
    time_slots = [f"{hour:02d}:00" for hour in range(7, 17)]  # For time configuration

    context = {
        'rooms': rooms_query,
        'time_slots': time_slots,
    }

    return render(request, 'mod_labRes/labres_labcoord_configroom.html', context)

#  ================================================================= 


def reports_view(request):
    return render(request, 'mod_reports/reports.html')

def user_settings_view(request):
    return render(request, 'user_settings.html')



# superuser stuff

def superuser_login(request):
    if request.method == 'POST':
        form = LoginForm(request, data=request.POST)
        if form.is_valid():
            user = form.get_user()
            auth_login(request, user)
            return redirect('superuser_setup')
    else:
        form = LoginForm()
    return render(request, 'superuser/superuser_login.html', {'form': form})

def superuser_logout(request):
    logout(request)
    return redirect("/login/superuser")


@login_required()
def superuser_setup(request):
    if not request.user.is_superuser:
        return redirect('/login')

    labs = laboratory.objects.all()
    modules = Module.objects.all()
    return render(request, 'superuser/superuser_setup.html', {'labs': labs, 'modules': modules})


from django.shortcuts import render, redirect
from django.contrib.auth.decorators import login_required
from .forms import LaboratoryForm

@login_required(login_url='/login/superuser')
def add_laboratory(request):
    if not request.user.is_superuser:
        return redirect('login')

    if request.method == 'POST':
        form = LaboratoryForm(request.POST)
        if form.is_valid():
            laboratory = form.save(commit=False)
            # Save the laboratory instance first
            laboratory.save()
            # Then save the selected modules
            form.save_m2m()
            return redirect('superuser_setup')
    else:
        form = LaboratoryForm()

    return render(request, 'superuser/add_laboratory.html', {'form': form})

