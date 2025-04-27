from django.db import models
from django.utils import timezone  # Import timezone for default datetime values
from Farms.models import Farms
from home.models import Users

class Activity(models.Model):
    id = models.AutoField(primary_key=True)
    activityName = models.CharField(max_length=50, null=False, default='')
    date = models.DateField(null=False, default=timezone.now)  # Default value for date
    farmName = models.CharField(max_length=50, null=False, default='')
    email = models.ForeignKey(Users, on_delete=models.CASCADE, to_field='email', default='')

    gdd = models.IntegerField(default=0)
    rain = models.IntegerField(default=0)
    humidity = models.IntegerField(default=0)
    wind = models.IntegerField(default=0)
    
class Tasks(models.Model):
    id = models.AutoField(primary_key=True)
    activityName = models.CharField(max_length=50, null=False, default='')
    assignedDate = models.DateTimeField(null=False, default=timezone.now)  # Default value for date
    farmName = models.CharField(max_length=50, null=False, default='')
    email = models.ForeignKey(Users, on_delete=models.CASCADE, to_field='email', default='')
    completionDate = models.DateTimeField(null = True ,default = None)  # Default value for date
    status = models.CharField(max_length=50, null=False, default='Pending')
    gdd = models.IntegerField(default=0)
    rain = models.IntegerField(default=0)
    humidity = models.IntegerField(default=0)
    wind = models.IntegerField(default=0)