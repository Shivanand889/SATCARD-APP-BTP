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
from django.db.models import Q
import numpy as np
import numpy
import torch
import torch.nn as nn
import torch.optim as optim


class LSTMModel(nn.Module):
    def __init__(self, input_dim, hidden_dim, output_dim, num_layers, dropout_prob=0.5):
        super(LSTMModel, self).__init__()
        self.lstm = nn.LSTM(input_dim, hidden_dim, num_layers, batch_first=True, dropout=dropout_prob)
        self.fc = nn.Linear(hidden_dim, output_dim)
        self.dropout = nn.Dropout(dropout_prob)  # Dropout layer

    def forward(self, x):
        # Initialize hidden and cell states
        h0 = torch.zeros(self.lstm.num_layers, x.size(0), self.lstm.hidden_size).to(x.device)
        c0 = torch.zeros(self.lstm.num_layers, x.size(0), self.lstm.hidden_size).to(x.device)

        # Forward propagate through LSTM
        out, _ = self.lstm(x, (h0, c0))  # Shape: (batch_size, seq_len, hidden_dim)

        # Take the output corresponding to the last timestep (seq_len = 4)
        out = out[:, -1, :]  # Shape: (batch_size, hidden_dim)

        # Apply dropout regularization
        out = self.dropout(out)

        # Apply the fully connected layer
        out = self.fc(out)  # Shape: (batch_size, output_dim)
        out = torch.sigmoid(out)  # Sigmoid for multi-label classification

        return out  # Shape: (batch_size, output_dim), i.e., (1, 11)

# Accuracy calculation function
def calculate_accuracy(outputs, labels):
    outputs = (outputs > 0.5).float()  # Binarize predictions (threshold = 0.5)
    correct = (outputs == labels).float().sum()
    total = labels.numel()
    print(total)
    return correct / total





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



@api_view(['POST'])
def Suggestions(request):
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
        # print(2)
        try :
            farm = Farms.objects.filter(email=user, name=farmName).first()
        except Exception as e:
            print(e)
        # print(4)

        print(farm.name)
        # for i in farm :
        #     # for j in i :
        #     print(i)
        if not user:
            return Response({"error": "User not found"}, status=404)

        # Step 3: Query distinct dates from the Activity table
        distinct_dates = (
            Activity.objects.filter(Q(email=email) & Q(farmName=farmName))
            .order_by('-date')  # Order by date descending
            .values_list('date', flat=True)  # Get only the date column
            .distinct()  # Ensure distinct dates
        )
        
        last_4_dates = list(distinct_dates[:4])
        print(len(last_4_dates))
        if len(last_4_dates)==0 :
            return Response({"data": ['ploughing','mulching']}, status=200)

        if len(last_4_dates)==1 :
            return Response({"data": ['sowing']}, status=200)

        if len(last_4_dates)<4 :
            return Response({"data": ['irrigation']}, status=200)

        l_date = []
        for i in last_4_dates :
            l_date.append(i)
            # print(i)

        l_date.reverse()
        print(l_date)

        l = []

        
        # Step 4: Get the last 4 distinct dates
         # Take the first 4 from the ordered list

        rows = (
            Activity.objects.filter(Q(email=email) & Q(farmName=farmName))
        )
        # print(3)
        day = 0 
        final_data = []
        # print(farm)
        for i in l_date :
            temp = [0 for x in range(18)]
            
            for j in rows :
                print(1)
                # print(j.date)
                if j.date == i :
                    print(2)
                    temp[0] = j.gdd
                    print(3)
                    temp[1]= Soil[farm.soilType]
                    print(4)
                    temp[2] = j.rain
                    temp[3] = farm.area
                    print(5)
                    temp[4] = j.humidity
                    temp[5] = j.wind
                    print(6)
                    temp[activities[j.activityName]] = 1
                    # print(5)
                    temp[17] = day
            
            final_data.append(temp)
            day+=1


        print(final_data)
        input_dim = 18 
        hidden_dim = 128
        output_dim = 11  
        num_layers = 1
        num_epochs = 50
        learning_rate = 0.001
        dropout_prob = 0.5
        # try :
        lmodel = LSTMModel(input_dim, hidden_dim, output_dim, num_layers)
        lmodel.load_state_dict(torch.load('lstm_model.pth'))
        lmodel.eval() 
        x_data = torch.tensor(numpy.array(final_data), dtype=torch.float32)
        x_data = torch.tensor(x_data).float()
        x_data = x_data.unsqueeze(0) 
        print(x_data.shape)
        with torch.no_grad():
            prediction = lmodel(x_data)


        # print("Prediction for the first sequence:", prediction)

        work = []
        activityList = list(activities.keys())
        for i in range(len(activities)):
            if prediction[0][i] >= 0.4:
                work.append(activityList[i])

        print(work)
        # except Exception as e:
        #     print(e)
        return Response({"data": work}, status=200)

    except Exception as e:
        return Response({"error": str(e)}, status=500)