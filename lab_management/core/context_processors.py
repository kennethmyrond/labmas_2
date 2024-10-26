from .models import laboratory, LaboratoryModule



def labs_context(request):
    selected_lab_id = request.session.get('selected_lab')
    selected_lab_modules = []
    
    if selected_lab_id:
        lab = laboratory.objects.filter(laboratory_id=selected_lab_id).first()
        if lab:
            # Get all enabled modules related to the selected lab
            selected_lab_modules = [module.name for module in lab.modules.filter(enabled=True)]

    return {
        'laboratories': laboratory.objects.filter(is_available=True),
        'selected_lab_name': request.session.get('selected_lab_name'),
        'selected_lab_modules': selected_lab_modules,
    }