# core/signals.py

from allauth.socialaccount.signals import social_account_added
from django.dispatch import receiver
from django.shortcuts import redirect

@receiver(social_account_added)
def handle_social_signup(sender, request, sociallogin, **kwargs):
    """
    Custom handler for social signup.
    Redirects to a specific page on first-time signup.
    """
    if not sociallogin.is_existing:
        # Redirect the user after signup; replace 'welcome' with your signup page route name
        return redirect('welcome')
