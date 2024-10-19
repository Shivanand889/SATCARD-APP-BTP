from django.db import models

# Create your models here.

class Users(models.Model):
    name = models.CharField(max_length=50, null=False)
    phoneNumber = models.BigIntegerField(unique=True)  # Use BigIntegerField
    email = models.EmailField(max_length=200, primary_key=True)
    # username = models.CharField(max_length=50, unique=True, default='default_user')
    password = models.CharField(max_length=100, null=False)
    # is_active = models.BooleanField(default=True)


