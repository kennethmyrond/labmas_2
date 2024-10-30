# adapters.py in core app
from allauth.socialaccount.adapter import DefaultSocialAccountAdapter
from django.shortcuts import redirect
from django.urls import reverse
from .models import user
from django.contrib import messages

class MySocialAccountAdapter(DefaultSocialAccountAdapter):
    def pre_social_login(self, request, sociallogin):
        # Get the email from the social login response
        email = sociallogin.account.extra_data.get('email')
        # Check if this email exists in core_user
        if not user.objects.filter(email=email).exists():
            # Redirect to an error or info page if user does not exist
            return redirect(reverse('error_page'))  # Define error_page view for users without access
