from .models import laboratory

def labs_context(request):
    return {
        'laboratories': laboratory.objects.filter(is_available=True),
        'selected_lab_name': request.session.get('selected_lab_name')
    }
