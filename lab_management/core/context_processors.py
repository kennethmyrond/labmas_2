# context_processors.py
from .models import laboratory, user, laboratory_users, Module, permissions as Permissions
from .utils import has_lab_permission
from django.shortcuts import get_object_or_404


def labs_context(request):
    selected_lab_id = request.session.get('selected_lab')
    try:
        current_user = get_object_or_404(user, email=request.user.email)
    except:
        current_user = None
    # print(current_user)
    
    selected_lab_modules = []
    if selected_lab_id:
        lab = laboratory.objects.filter(laboratory_id=selected_lab_id).first()
        if lab:
            module_ids = lab.modules
            selected_lab_modules = [module.id for module in Module.objects.filter(id__in=module_ids, enabled=True)]
    
    user_labs = laboratory.objects.filter(is_available=True, laboratory_users__user=current_user)
    # print(user_labs)

    # Default permissions are empty
    permissions = {}
    if selected_lab_id:
        # Query all permissions and set them dynamically
        all_permissions = Permissions.objects.values('codename')
        permissions = {
            f"can_{perm['codename']}": has_lab_permission(request.user, selected_lab_id, perm['codename'])
            for perm in all_permissions
        }
    
    return {
        'laboratories': user_labs,
        'selected_lab_name': request.session.get('selected_lab_name'),
        'selected_lab_modules': selected_lab_modules,
        'logged_user': current_user,
        'permissions': permissions
    }