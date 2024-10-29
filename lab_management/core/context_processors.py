from .models import laboratory, user, laboratory_users, Module
from django.shortcuts import get_object_or_404


def labs_context(request):
    selected_lab_id = request.session.get('selected_lab')
    try:
        current_user = get_object_or_404(user, email=request.user.email)
    except:
        current_user = None
    
    selected_lab_modules = []
    if selected_lab_id:
        lab = laboratory.objects.filter(laboratory_id=selected_lab_id).first()
        if lab:
            module_ids = lab.modules
            selected_lab_modules = [module.id for module in Module.objects.filter(id__in=module_ids, enabled=True)]
    
    user_labs = laboratory.objects.filter(is_available=True, laboratory_users__user=current_user)
    print(user_labs)

    return {
        'laboratories': user_labs,
        'selected_lab_name': request.session.get('selected_lab_name'),
        'selected_lab_modules': selected_lab_modules,
        'logged_user': current_user
    }