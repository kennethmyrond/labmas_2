from allauth.socialaccount.adapter import DefaultSocialAccountAdapter
from allauth.exceptions import ImmediateHttpResponse
from django.shortcuts import redirect
from django.contrib import messages
from core.models import user as CoreUser

class CustomSocialAccountAdapter(DefaultSocialAccountAdapter):
    def pre_social_login(self, request, sociallogin):
        # Extract the email from the social account
        email = sociallogin.account.extra_data.get('email')

        if not email:
            # Handle case where email is not provided by Google
            messages.error(request, "Google account does not have an associated email.")
            raise ImmediateHttpResponse(redirect('userlogin'))

        try:
            # Match the email with your custom user model
            core_user = CoreUser.objects.get(email=email)
            sociallogin.user = core_user  # Associate the social login with the existing user
        except CoreUser.DoesNotExist:
            # Redirect to login page with an error message if the user doesn't exist
            messages.error(request, "No account found for the provided Google email. Please log in with your credentials or contact support.")
            raise ImmediateHttpResponse(redirect('userlogin'))

    def is_auto_signup_allowed(self, request, sociallogin):
        # Ensure automatic signup is disabled
        return False
