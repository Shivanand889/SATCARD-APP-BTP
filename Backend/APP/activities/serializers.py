from rest_framework import serializers

from .models import *

class ActivitySerializer(serializers.ModelSerializer) :
    class Meta :
        model  = Activity 
        fields = ['id','activityName', 'date','farmName', 'email','gdd', 'rain', 'humidity', 'wind']

class TaskSerializer(serializers.ModelSerializer):
    class Meta:
        model = Tasks
        fields = '__all__'
