from django.db import models

# Create your models here.
from home.models import Users
class Farms(models.Model):
    name = models.CharField(max_length=50, primary_key=True)
    location = models.CharField(max_length=50, null=False)
    latitude = models.FloatField()  # Use BigIntegerField
    longitude = models.FloatField()  # Use BigIntegerField
    email = models.ForeignKey(Users, on_delete=models.CASCADE, to_field='email')
    cropName  = models.CharField(max_length=50, default='crop')
    