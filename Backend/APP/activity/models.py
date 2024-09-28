from django.db import models
from Farm.models import Farms


class Activity(models.Model):
    activityName = models.CharField(max_length=50, primary_key=True)
    date =  models.DateField(null = False)
    farmName = models.ForeignKey(Farms, on_delete=models.CASCADE, to_field='name')
    
    