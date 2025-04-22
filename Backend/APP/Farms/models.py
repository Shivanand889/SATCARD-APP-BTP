from django.db import models

# Create your models here.
from home.models import Users
class Farms(models.Model):
    id = models.AutoField(primary_key=True)
    name = models.CharField(max_length=50,null = False)
    location = models.CharField(max_length=50, null=False)
    # latitude = models.FloatField()  # Use BigIntegerField
    # longitude = models.FloatField()  # Use BigIntegerField
    email = models.ForeignKey(Users, on_delete=models.CASCADE, to_field='email')
    cropName  = models.CharField(max_length=50, default='crop')
    soilType  = models.CharField(max_length=50, default='crop')
    area = models.IntegerField(default=0)
    workerEmail = models.EmailField(max_length=200, null=False)
    
    