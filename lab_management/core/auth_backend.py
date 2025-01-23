from django.contrib.auth.backends import BaseBackend
from core.models import user as CoreUser

class CustomUserBackend(BaseBackend):
    def authenticate(self, request, email=None, password=None):
        try:
            core_user = CoreUser.objects.get(email=email)
            if core_user.check_password(password):  # Use AbstractBaseUser's check_password method
                return core_user
        except CoreUser.DoesNotExist:
            return None

    def get_user(self, user_id):
        try:
            return CoreUser.objects.get(pk=user_id)
        except CoreUser.DoesNotExist:
            return None
