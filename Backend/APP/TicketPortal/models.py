from django.db import models
from django.utils import timezone  # Import timezone for default datetime values
from home.models import Users

class Tickets(models.Model):
    id = models.AutoField(primary_key=True)
    issue = models.TextField(null=False, default='')
    category = models.TextField(null=False, default='')
    issueDate = models.DateField(null=False, default=timezone.now)  # Default value for date
    email = models.ForeignKey(Users,on_delete=models.CASCADE,to_field='email', db_column='email')    
    status = models.TextField(null=False, default='Pending')
    closingDate = models.DateField(null=True, default=None)
    
