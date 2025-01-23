# core/signals.py

from allauth.socialaccount.signals import social_account_added
from django.dispatch import receiver
from django.shortcuts import redirect

# @receiver(user_logged_in)
# def check_core_user_exists(request, user, **kwargs):
#     try:
#         core_user = CoreUser.objects.get(email=user.email)
#     except CoreUser.DoesNotExist:
#         logout(request)
#         messages.error(request, "User with this email does not exist in our records.")
#         return redirect('login')

@receiver(social_account_added)
def handle_social_signup(sender, request, sociallogin, **kwargs):
    """
    Custom handler for social signup.
    Redirects to a specific page on first-time signup.
    """
    if not sociallogin.is_existing:
        # Redirect the user after signup; replace 'welcome' with your signup page route name
        return redirect('welcome')
