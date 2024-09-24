from django.shortcuts import render, redirect, get_object_or_404
from django.contrib.auth import authenticate, login as auth_login, logout
from django.contrib.auth.decorators import login_required
from django.db.models import Q 
from django.utils import timezone
from django.http import HttpResponse, JsonResponse
from .forms import LoginForm, InventoryItemForm
from .models import laboratory, Module, item_description, item_types, item_inventory, suppliers, item_transactions, user
import json

def userlogin(request):
    return render(request,"user_login.html")

@login_required(login_url='/login')
def home(request):
    return render(request,"home.html")


def logout_view(request):
    logout(request)
    return redirect("/login")

def inventory_view(request):
    inventory_items = item_inventory.objects.select_related('item').all()
    return render(request, 'mod_inventory/view_inventory.html', {'inventory_items': inventory_items})

def inventory_addNewItem_view(request):
    # Fetch all item types to populate the dropdown
    item_types_list = item_types.objects.all()

    if request.method == "POST":
        # Extract form data
        item_name = request.POST.get('item_name')
        item_type_id = request.POST.get('item_type')
        amount = request.POST.get('amount')
        dimension = request.POST.get('item_dimension')

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
            laboratory_id=1,  # Assuming the laboratory is 1
            item_name=item_name,
            itemType_id=item_type_id,  # Set the itemType_id from the dropdown
            amount=amount,
            dimension=dimension,
            add_cols=add_cols_json  # Save the additional columns as JSON
        )
        new_item.save()

        # Redirect after successful submission
        return redirect('inventory_view')

    return render(request, 'mod_inventory/inventory_addNewItem.html', {
        'item_types': item_types_list  # Pass the item types to the template
    })

def suggest_items(request):
    query = request.GET.get('query', '')
    suggestions = item_description.objects.filter(item_name__icontains=query)[:5]  # Get up to 5 matching items

    data = []
    for item in suggestions:
        # Get the associated item_inventory entry
        inventory_item = item_inventory.objects.filter(item_id=item.item_id).first()  # Get the first inventory entry
        
        if inventory_item:
            data.append({
                'item_name': item.item_name,
                'amount': item.amount,  # From item_description
                'dimension': item.dimension,
                'unit_price': inventory_item.purchase_price,  # Correctly named field
                'supplier': inventory_item.supplier_id,  # Assuming supplier_id is the integer supplier ID
                'date_received': inventory_item.date_received,  # Correct field name
                'qty'          : inventory_item.qty
            })
    
    return JsonResponse(data, safe=False)



def inventory_updateItem_view(request):
    if request.method == 'POST':
        item_name = request.POST.get('item_name')
        amount = request.POST.get('amount')
        item_date_purchased = request.POST.get('item_date_purchased')
        item_date_received = request.POST.get('item_date_received')
        item_price = request.POST.get('item_price')
        item_supplier = request.POST.get('item_supplier')

        # Check if user is authenticated
        if not request.user.is_authenticated:
            return HttpResponse("You are not authenticated.", status=403)

        # Find the item_id based on the item_name
        item_description_instance = get_object_or_404(item_description, item_name=item_name)

        # Ensure the supplier_id exists
        try:
            supplier_instance = suppliers.objects.get(suppliers_id=item_supplier)
        except suppliers.DoesNotExist:
            return HttpResponse("Supplier does not exist.", status=400)

        # Retrieve the custom user instance
        try:
            current_user = user.objects.get(email=request.user.email)
        except user.DoesNotExist:
            return HttpResponse("No user matches the given query.", status=404)

        # Create a new item transaction
        transaction = item_transactions.objects.create(
            user=current_user,
            timestamp=timezone.now()
        )

        # Create a new items inventory entry
        new_inventory_item = item_inventory.objects.create(
            item=item_description_instance,
            supplier=supplier_instance,
            date_purchased=item_date_purchased,
            date_received=item_date_received,
            purchase_price=item_price,
            transaction=transaction,
            qty=amount
        )

        # Prepare the context to render the new item
        context = {
            'new_item': new_inventory_item,
            'success_message': "Item added successfully!"
        }

        # Render the updated template with the new item
        return render(request, 'mod_inventory/inventory_updateItem.html', context)

    # If the request method is not POST, render the form
    return render(request, 'mod_inventory/inventory_updateItem.html')



def inventory_itemDetails_view(request):
    return render(request, 'mod_inventory/inventory_itemDetails.html')

def inventory_physicalCount_view(request):
    return render(request, 'mod_inventory/inventory_physicalCount.html')

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

