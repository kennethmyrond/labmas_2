# utils.py

from django.core.exceptions import PermissionDenied
from .models import laboratory_users, laboratory_permissions

def has_lab_permission(user, lab_id, permission_codename):
    """
    Checks if a user has a given permission for a specific laboratory.
    """
    try:
        # Check if user has a role in the lab
        lab_user = laboratory_users.objects.get(user=user, laboratory_id=lab_id, status='A', is_active=1)
        
        # Retrieve permissions for the user’s role in this lab
        role_permissions = laboratory_permissions.objects.filter(
            role=lab_user.role,
            laboratory_id=lab_id,
            permissions__codename=permission_codename,
        )
        
        return role_permissions.exists()  # Return True if permission exists
    except laboratory_users.DoesNotExist:
        return False  # User has no role in the lab
