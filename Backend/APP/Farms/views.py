from django.shortcuts import render, redirect
from rest_framework.decorators import api_view
from rest_framework.response import Response
from .models import Farms
from activities.models import Activity
# from .serializers import FarmsSerializer
from django.db.models import Q

from django.contrib.auth import logout
from django.core.cache import cache
from home.models import Users
from activities.models import Activity
import json
import requests 
from django.http import HttpResponse
import pandas as pd 

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

@api_view(['GET'])
def FarmList(request):
    try:
        # Query all farms and extract their names
        email = cache.get('email')  # Assuming email is stored in the cache during login or session
        if not email:
            return Response({"error": "User is not logged in or session expired"}, status=401)

        # Step 2: Verify that the email corresponds to a valid user
        user = Users.objects.filter(email=email).first()
        if not user:
            return Response({"error": "User not found"}, status=404)

        # Step 3: Get the list of farms associated with the user
        farms = Farms.objects.filter(email=user).values_list('name', flat=True)
        farms_list = list(farms)
        print(farms_list)
        # Step 4: Return the list of farm names
        return Response({"farms": farms_list}, status=200)
    except Exception as e:
        return Response({"error": str(e)}, status=500)

@api_view(['GET'])
def FarmData(request):
    try:
        farmName = request.GET.get('farmName')
        print(farmName)
        if not farmName:
            return Response({"error": "Farm name is required"}, status=400)

        email = cache.get('email')  # Retrieve the email stored in the cache
        if not email:
            return Response({"error": "User is not logged in or session expired"}, status=401)

        # Step 3: Verify that the email corresponds to a valid user
        user = Users.objects.filter(email=email).first()
        if not user:
            return Response({"error": "User not found"}, status=404)

        # Step 4: Query the Farms table to find the farm with the matching farmName and email
        print(2)
        farm = Farms.objects.filter(name=farmName, email=user).first()
        print(3)
        if not farm:
            return Response({"error": "Farm not found"}, status=404)

        # Step 5: Return the farm data (all fields from the Farms table)

        headers = {"accept": "application/json"}
        url = f"https://api.tomorrow.io/v4/weather/forecast?location={farm.location}&apikey=OMbq1FMmdpBv8I2bjdzFEA8zeXMCIPUT"
        print(url)
        weather_data = {'rain' : 0,
            'wind' : 0,
            'temperature' : 0,
            'precipitation' : 0,
            'humidity' : 0
            }
        try :
            response = requests.get(url, headers=headers)
            print(4)
            # Convert the response text into a dictionary
            response_dict = json.loads(response.text)

            # Print the dictionary
            print(5)
            print(response_dict)
            
            weather_data = {
                'rain' : response_dict['timelines']['daily'][0]['values']['rainAccumulationAvg'],
                'wind' : response_dict['timelines']['daily'][0]['values']['windSpeedAvg'],
                'temperature' : response_dict['timelines']['daily'][0]['values']['temperatureApparentAvg'],
                'precipitation' : response_dict['timelines']['daily'][0]['values']['precipitationProbabilityAvg'],
                'humidity' : response_dict['timelines']['daily'][0]['values']['humidityAvg']
            }

        except Exception as e:
            print(e)

        
        print(6)
        # print(response_dict['timelines']['daily'][3])
       
        farm_data = {
            "name": farm.name,
            "crop_name": farm.cropName,
            "land_area": str(farm.area),
            "location": farm.location,
            "soil_type": farm.soilType,
        }
        print(farm_data)

        act = Activity.objects.filter(farmName=farmName, email=user)
        
        active = []
        for i in act :
            print(i)
            d = {'name' : i.activityName, 'date' : i.date, 'area':str(farm.area)}
            active.append(d)

        print(active)
        return Response({"farm": farm_data, "weather" : weather_data,'activity':active}, status=200)

    except Exception as e:
        return Response({"error": str(e)}, status=500)

@api_view(['POST'])
def DownloadActivityDetails(request):
    
    print("##################################")
    features = ['GDD', 'Soil Type', 'Rainfall', 'Land Area','humidity', 'Wind speed']
    activities = {'Sowing' :6, 'Spray':7, 'Irrigation':8, 'Scouting':9, 'Plowing':10, 'Fertilizing':11, 
              'Pruning':12, 'Transplantation':13, 'Mulching':14, 'Harvesting':15, 'Weeding':16}

    Soil = {'red' : 0, 'black' : 1,   'Red' : 0, 'Black' : 1}
    try:
        # Step 1: Get the email from the cache (session)
        email = cache.get('email')
        print(email)
        if not email:
            return Response({"error": "User is not logged in or session expired"}, status=401)

        farmName = request.data.get('name')
        print(farmName)
        if not farmName:
            return Response({"error": "Farm name is required"}, status=400)

        # Step 2: Verify that the user is valid
        user = Users.objects.filter(email=email).first()
        try:
            farm = Farms.objects.filter(email=user, name=farmName).first()
        except Exception as e:
            print(e)

        if not user:
            return Response({"error": "User not found"}, status=404)

        # Step 3: Query distinct dates from the Activity table
        distinct_dates = (
            Activity.objects.filter(Q(email=email) & Q(farmName=farmName))
            .order_by('date')  # Order by date descending
            .values_list('date', flat=True)  # Get only the date column
            .distinct()  # Ensure distinct dates
        )

        l_date = []
        for i in distinct_dates:
            l_date.append(i)

        l_date.reverse()
        print(l_date)

        l = []

        # Step 4: Get the last 4 distinct dates
        print("aaaaaaaaaaaaaaaaaaaaaaaaaa")
        rows = (
            Activity.objects.filter(Q(email=email) & Q(farmName=farmName))
        )
        print("bbbbbbbbbbbbbbbbbbbbbbbbb")
        day = 0 
        final_data = []

        for i in l_date:
            temp = []
            for j in rows:
                print(1)
                if j.date == i:
                    temp.append(j.activityName)
            
            final_data.append(temp)
        
        data = []  # This should be inside the try block
        
        for i in range(len(l_date)):
            temp = {'date' : l_date[i], "activities" : final_data[i]}
            data.append(temp)

        df = pd.DataFrame(data)

        try:
            response = HttpResponse(content_type='text/csv')
            df.to_csv(path_or_buf=response, index=False)
            response['Content-Disposition'] = 'attachment; filename="data.csv"'
            
            return response

        except Exception as e:
            print(f"exception : {e}")

    except Exception as e:
        print(f"Unexpected error: {e}")
        return Response({"error": "An unexpected error occurred"}, status=500)