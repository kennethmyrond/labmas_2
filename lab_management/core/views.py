from django.shortcuts import render, redirect, get_object_or_404
from django.contrib.auth import authenticate, login as auth_login, logout
from django.contrib.auth.decorators import login_required
from django.db.models import Q 
from django.utils import timezone
from django.http import HttpResponse, JsonResponse
from .forms import LoginForm, InventoryItemForm
from .models import laboratory, Module, item_description, item_types, item_inventory, suppliers, item_transactions, user, suppliers
import json
from django.http import JsonResponse
from django.shortcuts import render, get_object_or_404, HttpResponse
from .models import item_description, item_inventory, item_transactions, suppliers, user

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

def inventory_view(request):
    # Get the selected laboratory from the session
    selected_laboratory_id = request.session.get('selected_lab')
    
    # Get all item types for the selected laboratory
    item_types_list = item_types.objects.filter(laboratory_id=selected_laboratory_id)
    
    # Get the selected item_type from the GET parameters
    selected_item_type = request.GET.get('item_type')

    # Filter inventory items by both the selected item_type and the selected laboratory
    if selected_item_type:
        # Filter by both item_type and selected_lab (item's laboratory should match)
        inventory_items = item_description.objects.filter(
            itemType_id=selected_item_type,
            laboratory_id=selected_laboratory_id
        )
        # Get the add_cols for the selected item_type
        selected_item_type_instance = item_types.objects.get(pk=selected_item_type)
        add_cols = json.loads(selected_item_type_instance.add_cols)
    else:
        # Filter only by the selected_lab if no item_type is chosen
        inventory_items = item_description.objects.filter(
            laboratory_id=selected_laboratory_id
        )
        add_cols = []

    return render(request, 'mod_inventory/view_inventory.html', {
        'inventory_items': inventory_items,
        'item_types': item_types_list,
        'selected_item_type': int(selected_item_type) if selected_item_type else None,  # Fix comparison issue
        'add_cols': add_cols
    })

def inventory_addNewItem_view(request):
    selected_lab = request.session.get('selected_lab')
    if selected_lab:
        item_types_list = item_types.objects.filter(laboratory_id=selected_lab)
    else:
        item_types_list = item_types.objects.none()  # No lab selected, show nothing or handle it accordingly

    if request.method == "POST":
        # Extract form data
        item_name = request.POST.get('item_name')
        item_type_id = request.POST.get('item_type')
        amount = request.POST.get('amount')
        dimension = request.POST.get('item_dimension')
        laboratory = request.session.get('selected_lab_name')

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
            laboratory_id=selected_lab,  # Assuming the laboratory is 1
            item_name=item_name,
            itemType_id=item_type_id,  # Set the itemType_id from the dropdown
            amount=amount,
            dimension=dimension,
            add_cols=add_cols_json,  # Save the additional columns as JSON
            qty = 0,
            alert_qty = 0,
        )
        new_item.save()

        # Redirect after successful submission
        return redirect('inventory_view')

    return render(request, 'mod_inventory/inventory_addNewItem.html', {
        'item_types': item_types_list,
        'selected_lab_name': request.session.get('selected_lab_name'),
    })

def suggest_items(request):
    query = request.GET.get('query', '')
    selected_laboratory_id = request.session.get('selected_lab')
    suggestions = item_description.objects.filter(item_name__icontains=query, laboratory_id=selected_laboratory_id)[:5]  # Get up to 5 matching items

    data = []
    for item in suggestions:
        # Parse add_cols from item_description if it's available
        try:
            add_cols = json.loads(item.add_cols) if item.add_cols else {}
        except json.JSONDecodeError:
            add_cols = {}

        # Add item details including add_cols to the response data
        data.append({
            'item_name': item.item_name,
            'amount': item.amount,
            'dimension': item.dimension,
            'add_cols': add_cols,  # Pass the parsed add_cols
            'qty': item.qty  # Assuming qty is now in item_description
        })
    
    return JsonResponse(data, safe=False)

# def suggest_items(request):
#     query = request.GET.get('query', '')
#     selected_laboratory_id = request.session.get('selected_lab')
#     suggestions = item_description.objects.filter(item_name__icontains=query, laboratory_id=selected_laboratory_id)[:5]

#     data = []
#     for item in suggestions:
#         data.append({
#             'item_id': item.item_id,
#             'item_name': item.item_name,
#             'amount': item.amount,
#             'dimension': item.dimension
#         })
    
#     return JsonResponse(data, safe=False)

# def suggest_suppliers(request):
#     query = request.GET.get('query', '')
#     supplier_suggestions = suppliers.objects.filter(supplier_name__icontains=query)[:5]

#     data = []
#     for supplier in supplier_suggestions:
#         data.append({
#             'suppliers_id': supplier.suppliers_id,
#             'supplier_name': supplier.supplier_name
#         })

#     return JsonResponse(data, safe=False)


def inventory_updateItem_view(request):
    if request.method == 'POST':
        item_name = request.POST.get('item_name')
        action_type = request.POST.get('action_type')
        amount = request.POST.get('amount') if action_type == 'add' else request.POST.get('quantity_removed')
        item_date_purchased = request.POST.get('item_date_purchased')
        item_date_received = request.POST.get('item_date_received')
        item_price = request.POST.get('item_price')
        item_supplier = request.POST.get('item_supplier')

        # Check if user is authenticated
        if not request.user.is_authenticated:
            return HttpResponse("You are not authenticated.", status=403)

        # Find the item_id based on the item_name
        item_description_instance = get_object_or_404(item_description, item_name=item_name)

        # Ensure the supplier exists
        try:
            supplier_instance = suppliers.objects.get(suppliers_id=item_supplier)
        except suppliers.DoesNotExist:
            return HttpResponse("Supplier does not exist.", status=400)

        # Retrieve the current user instance
        current_user = get_object_or_404(user, email=request.user.email)
        # current_user = 1

        # Create a new item transaction
        transaction = item_transactions.objects.create(
            user=current_user,
            timestamp=timezone.now(),
            remarks="Add to inventory" if action_type == 'add' else "Remove from inventory"
        )

        # Add to inventory logic
        if action_type == 'add':
            # Create a new item_inventory entry
            new_inventory_item = item_inventory.objects.create(
                item=item_description_instance,
                supplier=supplier_instance,
                date_purchased=item_date_purchased,
                date_received=item_date_received,
                purchase_price=item_price,
                transaction=transaction,
                qty=amount
            )

            item_description_instance.qty += int(amount)
            item_description_instance.save()
        else:
            # Remove from inventory: Decrease the qty from item_description
            item_description_instance.qty -= int(amount)
            item_description_instance.save()

        # Prepare the context to render the new item
        context = {
            'success_message': f"Item {'added to' if action_type == 'add' else 'removed from'} inventory successfully!"
        }

        return render(request, 'mod_inventory/inventory_updateItem.html', context)

    # If the request method is not POST, render the form
    return render(request, 'mod_inventory/inventory_updateItem.html')


def inventory_itemDetails_view(request):
    return render(request, 'mod_inventory/inventory_itemDetails.html')

def inventory_physicalCount_view(request):
    # Get the selected laboratory from the session
    selected_laboratory_id = request.session.get('selected_lab')

    # Get all item types for the selected laboratory
    item_types_list = item_types.objects.filter(laboratory_id=selected_laboratory_id)

    # Get the selected item_type from the GET parameters
    selected_item_type = request.GET.get('item_type')

    # Filter items by laboratory and selected item type
    if selected_item_type:
        inventory_items = item_description.objects.filter(
            laboratory_id=selected_laboratory_id, 
            itemType_id=selected_item_type
        )
    else:
        inventory_items = item_description.objects.filter(laboratory_id=selected_laboratory_id)

    if request.method == "POST":
        # Step 1: Create a new transaction record
        transaction = item_transactions.objects.create(
            user_id=1,  # Assuming user with ID 1 for now
            timestamp=timezone.now(),
            remarks="physcount"
        )
        
        # Step 2: Iterate over all items and check for discrepancies
        for item in inventory_items:
            count_qty = int(request.POST.get(f'count_qty_{item.item_id}'))  # Get the count qty from the form
            current_qty = item.qty  # Current qty from item_description

            # Step 3: If there's a discrepancy, create a new item_inventory record
            if count_qty != current_qty:
                discrepancy_qty = count_qty - current_qty

                # Create a new item_inventory record for the discrepancy
                item_inventory.objects.create(
                    item=item,
                    supplier=None,  # Set the supplier as None since it's not relevant for the physical count
                    date_purchased=None,  # Optional; set to None for now
                    date_received=None,  # Optional; set to None for now
                    purchase_price=None,  # Optional; set to None for now
                    remarks="physcount",  # Remark as "physcount"
                    transaction=transaction,  # Link to the newly created transaction
                    qty=discrepancy_qty,  # Record the difference
                )

                # Step 4: Update the item_description.qty with the new count qty
                item.qty = count_qty
                item.save()

        # Redirect to the inventory view after saving the counts
        return redirect('inventory_view')

    return render(request, 'mod_inventory/inventory_physicalCount.html', {
        'inventory_items': inventory_items,
        'item_types': item_types_list,
        'selected_item_type': int(selected_item_type) if selected_item_type else None  # Fix comparison issue
    })

def borrowing_view(request):
    return render(request, 'mod_borrowing/borrowing.html')

def clearance_view(request):
    return render(request, 'mod_clearance/clearance.html')

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

