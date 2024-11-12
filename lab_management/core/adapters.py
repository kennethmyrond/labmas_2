# adapters.py in core app
from allauth.account.adapter import DefaultAccountAdapter
from allauth.socialaccount.adapter import DefaultSocialAccountAdapter
from allauth.exceptions import ImmediateHttpResponse
from allauth.socialaccount.signals import pre_social_login
from allauth.account.utils import perform_login
from allauth.utils import get_user_model
from django.http import HttpResponse
from django.dispatch import receiver
from django.shortcuts import redirect
from django.conf import settings
from django.shortcuts import redirect
from django.urls import reverse
from .models import user
from django.contrib import messages
import json

# core/adapters.py

# core/adapters.py

from allauth.socialaccount.adapter import DefaultSocialAccountAdapter
from django.contrib.auth import get_user_model
from django.shortcuts import redirect
from django.urls import reverse
from django.contrib import messages
from allauth.exceptions import ImmediateHttpResponse

User = get_user_model()

class CustomSocialAccountAdapter(DefaultSocialAccountAdapter):
    def pre_social_login(self, request, sociallogin):
        email = sociallogin.account.extra_data.get('email')
        if email and not User.objects.filter(email=email).exists():
            messages.error(request, "Account does not exist. Please sign up first.")
            sociallogin.state['process'] = 'connect'  # Prevents the signup process
            raise ImmediateHttpResponse(redirect(reverse('userlogin')))  # Redirect to a custom page




# class MySocialAccountAdapter(DefaultSocialAccountAdapter):
#     def pre_social_login(self, request, sociallogin):
#         # Get the email from the social login response
#         email = sociallogin.account.extra_data.get('email')
#         # Check if this email exists in core_user
#         if not user.objects.filter(email=email).exists():
#             # Redirect to an error or info page if user does not exist
#             return redirect(reverse('error_page'))  # Define error_page view for users without access
