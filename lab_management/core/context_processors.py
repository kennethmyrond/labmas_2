from .models import laboratory, LaboratoryModule, user, laboratory_users
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
            # Get all enabled modules related to the selected lab
            selected_lab_modules = [module.id for module in lab.modules.filter(enabled=True)]

    return {
        'laboratories': laboratory.objects.filter(is_available=True, laboratory_users__user=current_user),
        'selected_lab_name': request.session.get('selected_lab_name'),
        'selected_lab_modules': selected_lab_modules,
    }