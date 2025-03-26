# context_processors.py
from .models import laboratory, user, laboratory_users, Module, permissions as Permissions, borrowing_config

from django.db.models import Subquery, OuterRef, Q, F, Value, CharField
from django.db.models.functions import Concat

from .utils import has_lab_permission
from django.shortcuts import get_object_or_404
from django.core.exceptions import ObjectDoesNotExist

def labs_context(request):
    selected_lab_id = request.session.get('selected_lab')
    current_user = None
    selected_lab_modules = []
    user_labs = []
    borrow_config = None
    permissions = {}
    is_available = True
    user_role = None

    if request.user.is_authenticated:
        # print(request.user.user_id)
        try:
            current_user = user.objects.get(email=request.user.email)
        except user.DoesNotExist:
            pass
        
        coordinator_name = user.objects.filter(
            laboratory_users__laboratory=OuterRef('pk'),
            laboratory_users__role__roles_id=2,
            laboratory_users__is_active=True,
            laboratory_users__status='A'
        ).annotate(
            full_name=Concat(F('firstname'), Value(' '), F('lastname'), output_field=CharField())
        ).values('full_name')[:1]

        user_labs = laboratory.objects.filter(
            is_available=True, 
            laboratory_users__user=request.user, 
            laboratory_users__is_active=True,
            laboratory_users__status='A'
        ).annotate(
            coordinator_name=Subquery(coordinator_name)
        )

        if selected_lab_id:
            is_available = get_object_or_404(laboratory, laboratory_id=selected_lab_id).is_available

            lab = laboratory.objects.filter(laboratory_id=selected_lab_id).first()
            if lab:
                module_ids = lab.modules
                selected_lab_modules = Module.objects.filter(id__in=module_ids, enabled=True).values_list('id', flat=True)
            
            try:
                borrow_config = borrowing_config.objects.get(laboratory_id=selected_lab_id)
            except borrowing_config.DoesNotExist:
                pass

            all_permissions = Permissions.objects.values('codename')
            permissions = {
                f"can_{perm['codename']}": has_lab_permission(request.user, selected_lab_id, perm['codename'])
                for perm in all_permissions
            }

            user_role = laboratory_users.objects.filter(
                user=current_user,
                laboratory_id=selected_lab_id,
                is_active=True,
                status='A'
            ).values('role_id').first()

    return {
        'laboratories': user_labs,
        'selected_lab_id': selected_lab_id,
        'selected_lab_name': request.session.get('selected_lab_name'),
        'selected_lab_modules': selected_lab_modules,
        'logged_user': current_user,
        'permissions': permissions,
        'borrow_config': borrow_config,
        'is_available_lab': is_available,
        'user_role': user_role.get('role_id') if user_role else None
    }