from django.shortcuts import render, redirect
from rest_framework.decorators import api_view
from rest_framework.response import Response
from .models import Activity
from .serializers import ActivitySerializer
from django.contrib.auth import logout
from django.core.cache import cache
from home.models import Users
from Farms.models import Farms
import json
import requests 


@api_view(['POST'])
def AddActivity(request):
    try:
        # Step 1: Get the email from the cache (session)
        email = cache.get('email')
        if not email:
            return Response({"error": "User is not logged in or session expired"}, status=401)

        farmName = request.data.get('name')
        activities = request.data.get('activities')  # Ensure this is a list
        date = request.data.get('date')

        # Step 2: Verify that the user is valid
        user = Users.objects.filter(email=email).first()
        if not user:
            return Response({"error": "User not found"}, status=404)

        # Step 3: Create an Activity for each item in the activities list
        if activities and isinstance(activities, list):  # Check if activities is a list
            for activity_name in activities:
                Activity.objects.create(
                    farmName=farmName,
                    email=user,
                    activityName=activity_name,
                    date=date if date else timezone.now()  # Use provided date or current date if not provided
                )
            return Response({"message": "Activities added successfully"}, status=200)
        else:
            return Response({"error": "Invalid activities list"}, status=400)

    except Exception as e:
        return Response({"error": str(e)}, status=500)

