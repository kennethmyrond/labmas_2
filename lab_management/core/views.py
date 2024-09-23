from django.shortcuts import render, redirect
from django.contrib.auth import authenticate, login as auth_login, logout
from django.contrib.auth.decorators import login_required
from django.http import HttpResponse
from .forms import LoginForm, InventoryItemForm
from .models import laboratory, Module, item_description, item_types, item_inventory
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
        item_type_id = request.POST.get('item_type')  # Get the selected itemType_id from the dropdown
        amount = request.POST.get('amount')
        dimension = request.POST.get('item_dimension')
        nature = request.POST.get('item_nature')
        grade = request.POST.get('item_grade')
        location = request.POST.get('item_location')
        kind = request.POST.get('item_kind')

        # Prepare the add_cols field in JSON format
        add_cols = json.dumps({
            'Nature': nature,
            'Grade': grade,
            'Location': location,
            'Kind': kind
        })

        # Save the data to the database
        new_item = item_description(
            laboratory_id=1,  # Assuming the laboratory is 1
            item_name=item_name,
            itemType_id=item_type_id,  # Set the itemType_id from the dropdown
            amount=amount,
            dimension=dimension,
            add_cols=add_cols
        )
        new_item.save()

        # Redirect after successful submission
        return redirect('inventory_view')  # Redirect to the inventory view page

    return render(request, 'mod_inventory/inventory_addNewItem.html', {
        'item_types': item_types_list  # Pass the item types to the template
    })

def inventory_itemDetails_view(request):
    return render(request, 'mod_inventory/inventory_itemDetails.html')

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

@login_required(login_url='/login/superuser')
def superuser_setup(request):
    if not request.user.is_superuser:
        return redirect('userlogin')

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

