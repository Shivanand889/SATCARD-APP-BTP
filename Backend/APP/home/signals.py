from django.dispatch import receiver
from allauth.account.signals import user_logged_in
from django.contrib.sessions.models import Session


@receiver(user_logged_in)
def store_email_in_session(sender, request, user, **kwargs):
    
    request.session['email'] = user.email
    print(f"Email {user.email} stored in session")
