# decorators.py

from functools import wraps
from django.shortcuts import redirect
from django.urls import reverse
from django.core.exceptions import PermissionDenied
from .utils import has_lab_permission

def lab_permission_required(permission_codename):
    """
    Decorator to check if a user has a specific lab permission.
    """
    def decorator(view_func):
        @wraps(view_func)
        def _wrapped_view(request, *args, **kwargs):
            lab_id = request.session.get('selected_lab')
            if lab_id and has_lab_permission(request.user, lab_id, permission_codename):
                return view_func(request, *args, **kwargs)
            # Redirect to error page with a message if permission is denied
            error_url = f"{reverse('error_page')}?message=You do not have permission to access this page."
            return redirect(error_url)
        return _wrapped_view
    return decorator

# decorators
def superuser_or_lab_permission_required(permission_codename):
    def decorator(view_func):
        @wraps(view_func)
        def _wrapped_view(request, *args, **kwargs):
            # if request.user.is_superuser or request.user.has_perm(permission):
            #     return view_func(request, *args, **kwargs)
            # raise PermissionDenied
        
            lab_id = request.session.get('selected_lab')
            if request.user.is_superuser or (lab_id and has_lab_permission(request.user, lab_id, permission_codename)):
                return view_func(request, *args, **kwargs)
            # Redirect to error page with a message if permission is denied
            error_url = f"{reverse('error_page')}?message=You do not have permission to access this page."
            return redirect(error_url)
        return _wrapped_view
    return decorator