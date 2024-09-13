from django.db import models

# Create your models here.

class Users(models.Model):
    name = models.CharField(max_length=50, null=False)
    phoneNumber = models.BigIntegerField(unique=True)  # Use BigIntegerField
    email = models.EmailField(max_length=200, unique=True)
    password = models.CharField(max_length=100, null=False)
