from django.shortcuts import render, redirect, get_object_or_404, HttpResponse
from django.contrib.auth import authenticate, login as auth_login, logout
from django.contrib.auth.decorators import login_required
from django.db.models.functions import TruncDate
from django.contrib import messages
from django.db.models import Q, Sum , Prefetch, F
from django.utils import timezone
from django import forms
from django.http import HttpResponse, JsonResponse, Http404
from .forms import LoginForm, InventoryItemForm
from .models import laboratory, Module, item_description, item_types, item_inventory, suppliers, user, suppliers, item_expirations, item_handling
from .models import borrow_info, borrowed_items, borrowing_config, reported_items
from datetime import timedelta
import json, qrcode, base64
from pyzbar.pyzbar import decode
from PIL import Image 
from io import BytesIO
from django.core.files.uploadedfile import InMemoryUploadedFile
from django.db import connection

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
    supplier_suggestions = suppliers.objects.filter(supplier_name__icontains=query, laboratory=selected_laboratory_id)[:5]  # Limit the results to 5

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
            )
            # If expiration date is provided, save it
            if expiration_date:
                item_expirations.objects.create(
                    inventory_item=new_inventory_item,
                    expired_date=expiration_date
                )
        else:
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
                print(item_inventory_instance)
                print('inv qty: ' + str(item_inventory_instance.qty))
                print('rem: ' + str(remaining_amount))

                if remaining_amount <= 0:
                    break

                if item_inventory_instance.qty >= remaining_amount:
                    try:
                        remove_item_from_inventory(item_inventory_instance, remaining_amount, current_user, 'R')
                        remaining_amount = 0
                    except ValueError as e:
                        print(e)
                        break
                else:
                    try:
                        remaining_amount = remaining_amount - int(item_inventory_instance.qty)
                        remove_item_from_inventory(item_inventory_instance, item_inventory_instance.qty, current_user, 'R')
                    except ValueError as e:
                        print(e)
                        break

            if remaining_amount > 0:
                print(f"Could not remove the full amount. {remaining_amount} items remaining.")
            else:
                print("Successfully removed the requested amount.")

        # Success message
        context = {
            'success_message': f"Item {'added to' if action_type == 'add' else 'removed from'} inventory successfully!"
        }

        return render(request, 'mod_inventory/inventory_updateItem.html', context)

    return render(request, 'mod_inventory/inventory_updateItem.html')

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
    lab_suppliers = suppliers.objects.filter(laboratory=selected_laboratory_id)

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

        # Fetch suppliers again to ensure the list is up to date
        lab_suppliers = suppliers.objects.filter(laboratory=selected_laboratory_id)
        return redirect('inventory_manageSuppliers')

    return render(request, 'mod_inventory/inventory_manageSuppliers.html', {
        'suppliers': lab_suppliers,
    })

def inventory_supplierDetails_view(request, supplier_id):
    if not request.user.is_authenticated:
        return redirect('userlogin')
    
    # Get the supplier details using the supplier_id
    supplier = suppliers.objects.get(suppliers_id=supplier_id)

    # Get all item_inventory instances associated with the supplier
    items = item_inventory.objects.filter(supplier=supplier)
    
    # Get item_handling entries where changes is 'A' (Add to inventory) and the related item belongs to the supplier
    item_handling_entries = item_handling.objects.filter(
        inventory_item__supplier=supplier,
        changes='A'
    ).select_related('inventory_item')  # Use select_related to reduce DB queries

    return render(request, 'mod_inventory/inventory_supplierDetails.html', {
        'supplier': supplier,
        'items': items,
        'item_handling_entries': item_handling_entries
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

        # Fetch all equipment items including their total quantities
        equipment_list = item_description.objects.filter(
            laboratory_id=laboratory_id,
            is_disabled=0,
            allow_borrow=1  # Only include items that can be borrowed
        ).annotate(total_qty=Sum('item_inventory__qty'))

        # Fetch inventory items and order them by item type name
        inventory_items = item_description.objects.filter(
            laboratory_id=laboratory_id,
            is_disabled=0,
            allow_borrow=1  # Only get items that can be borrowed
        ).annotate(total_qty=Sum('item_inventory__qty')).select_related('itemType').order_by('itemType__itemType_name')

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
                    'equipment_list': equipment_list,  # Include equipment_list here
                    'inventory_items': inventory_items,  # Include inventory_items here
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
        'equipment_list': equipment_list,
        'inventory_items': inventory_items,
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

def borrowing_labtech_detailedprebookrequests(request):
    return render(request, 'mod_borrowing/borrowing_labtech_detailedprebookRequests.html')

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
    accepted_requests = borrow_info.objects.filter(status='A').select_related('user')

    if request.method == 'POST':
        borrow_id = request.POST.get('borrow_id')
        action = request.POST.get('action')

        # Update borrow_info status
        borrow_entry = get_object_or_404(borrow_info, borrow_id=borrow_id)
        if action == 'borrowed':
            borrow_entry.status = 'B'  # Mark as Borrowed
        elif action == 'cancel':
            borrow_entry.status = 'C'  # Mark as Cancelled
        borrow_entry.save()

        return JsonResponse({'success': True})

    return render(request, 'mod_borrowing/borrowing_labtech_prebookrequests.html', {
        'accepted_requests': accepted_requests,
    })



#CLEARANCE
def clearance_view(request):
    return render(request, 'mod_clearance/clearance.html')

def clearance_student_viewClearance(request):
    return render(request, 'mod_clearance/student_viewClearance.html')

def clearance_student_viewClearanceDetailed(request):
    return render(request, 'mod_clearance/student_viewClearanceDetailed.html')


def lab_reservation_view(request):
    return render(request, 'mod_labRes/lab_reservation.html')

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

