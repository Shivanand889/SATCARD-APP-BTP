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

