from django.shortcuts import render, redirect
from rest_framework.decorators import api_view
from rest_framework.response import Response
from .models import Farms
from .serializers import FarmsSerializer
from django.contrib.auth import logout
from django.core.cache import cache
from home.models import Users

@api_view(['POST'])
def AddFarm(request):
    name = request.data.get('name')
    cropName = request.data.get('crop')
    # latitude = request.data.get('latitude')
    # longitude = request.data.get('longitude')
    location = request.data.get('location')
    soilType = request.data.get('soil')
    area = request.data.get('area')
    
    if Farms.objects.filter(name=name).exists():
        return Response({'message' : 'Farm already exist'}, status=500)

    email = cache.get('email')  # Retrieve the email from the cache

    try:
        # Fetch the Users instance based on the email
        user = Users.objects.get(email=email)
    except Users.DoesNotExist:
        return Response({'message': 'User not found for the provided email'}, status=404)


    farm = Farms.objects.create(
        name=name,
        cropName=cropName,
        # latitude= latitude,  
        # longitude= longitude,  
        location = location,
        soilType = soilType,
        area = area,
        email=user
    )

    return Response({'message' : 'Farm created succesfully'}, status=200)

    