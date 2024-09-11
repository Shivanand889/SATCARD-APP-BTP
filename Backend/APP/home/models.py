from django.db import models

# Create your models here.

class Users(models.Model) :
    name = models.CharField(max_length=50)
    phoneNumber = models.IntegerField() 
    email = models.EmailField(max_length=200)
    password = models.CharField(max_length=100)
    