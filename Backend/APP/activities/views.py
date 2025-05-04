from django.shortcuts import render, redirect
from rest_framework.decorators import api_view
from rest_framework.response import Response
from .models import *
from .serializers import *
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
from django.utils import timezone
from datetime import date, timedelta, datetime
from tensorflow.keras.preprocessing import image as keras_image
from tensorflow.keras.models import load_model
from tensorflow.keras import layers, Sequential
from PIL import Image
import numpy as np
import io
import tensorflow as tf

# from keras.models import load_model
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
        email = request.data.get('email')
        if not email:
            return Response({"error": "User is not logged in or session expired"}, status=401)

        farmName = request.data.get('name')
        activities = request.data.get('activities')  # Ensure this is a list

        # Step 2: Verify that the user is valid
        user = Users.objects.filter(email=email).first()
        if not user:
            return Response({"error": "User not found"}, status=404)

        # Step 3: Create an Activity for each item in the activities list
        if activities and isinstance(activities, list):  # Check if activities is a list
            for activity_name in activities:
                Suggestions.objects.create(
                    farmName = farmName,
                    assignedDate = timezone.now(),
                    activityName = activity_name,
                    email = user
                )
            return Response({"message": "Activities added successfully"}, status=200)
        else:
            return Response({"error": "Invalid activities list"}, status=400)

    except Exception as e:
        return Response({"error": str(e)}, status=500)



@api_view(['POST'])
def Suggestion(request):
    features = ['GDD', 'Soil Type', 'Rainfall', 'Land Area','humidity', 'Wind speed']
    activities = {'Sowing' :6, 'Spray':7, 'Irrigation':8, 'Scouting':9, 'Plowing':10, 'Fertilizing':11, 
              'Pruning':12, 'Transplantation':13, 'Mulching':14, 'Harvesting':15, 'Weeding':16}

    Soil = {'red' : 0, 'black' : 1,   'Red' : 0, 'Black' : 1}
    try:
        # Step 1: Get the email from the cache (session)
        email = request.data.get('email')
        print(email)
        if not email:
            return Response({"error": "User is not logged in or session expired"}, status=401)

        
        farmName = request.data.get('name')
        print(farmName)
        if not farmName:
            return Response({"error": "Farm name is required"}, status=400)

        # Step 2: Verify that the user is valid
        user = Users.objects.filter(email=email).first()
        
        workers = Users.objects.filter(managerEmail=email)
        suggest =[]
        workerNames = []
        for i in workers : 
           
            workerNames.append([i.name, i.email])
        
        print(1)
        # try :
        suggestion  = Suggestions.objects.filter(
                farmName=farmName,
                assignedDate=timezone.now(),
                email = user
            )
        
        # except Exception as e :
        #     print(e)
        print(2)
        for i in suggestion :
            suggest.append([i.activityName,i.status])
        print(suggest)
        print(workerNames)
        if(len(suggest) !=0) : 
            return Response({"data": suggest, 'workerNames' : workerNames}, status=200)
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
        print("work1")
        last_4_dates = set()

        for i in workers : 
            try :
                print(1)
                distinct_dates = (
                    Tasks.objects.filter(Q(email=i) & Q(farmName=farmName) & Q(status = "Completed"))
                    .order_by('-completionDate')  # Order by date descending
                    .values_list('completionDate', flat=True)  # Get only the date column
                    .distinct()  # Ensure distinct dates
                )
                print(2)
                last_4_dates.update(distinct_dates)

            except Exception as e :
                print(e)
        print("z")
        last_4_dates = sorted(list(last_4_dates))[:4]
        print("work2")
        
        print(len(last_4_dates))
        if len(last_4_dates)==0 :
            newSuggestion = Suggestions.objects.create(
                                farmName = farmName,
                                assignedDate = timezone.now(),
                                activityName = 'ploughing',
                                email = user
            )
            newSuggestion = Suggestions.objects.create(
                                farmName = farmName,
                                assignedDate = timezone.now(),
                                activityName = 'mulching',
                                email = user
            )
            return Response({"data": [['ploughing','Pending'],['mulching','Pending']], 'workerNames' : workerNames}, status=200)
        if len(last_4_dates)==1 :
            newSuggestion = Suggestions.objects.create(
                                farmName = farmName,
                                assignedDate = timezone.now(),
                                activityName = 'sowing',
                                email = user
            )
            return Response({"data": [['sowing','Pending']], 'workerNames' : workerNames}, status=200)

        if len(last_4_dates)<4 :
            newSuggestion = Suggestions.objects.create(
                                farmName = farmName,
                                assignedDate = timezone.now(),
                                activityName = 'irrigation',
                                email = user
            )
            return Response({"data": [['irrigation','Pending']], 'workerNames' : workerNames}, status=200)

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
            Tasks.objects.filter(Q(email=email) & Q(farmName=farmName) & Q(status = "Completed"))
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
                work.append([activityList[i], "Pending"])

        for i in work :
            newSuggestion = Suggestions.objects.create(
                                farmName = farmName,
                                assignedDate = timezone.now(),
                                activityName = i[0],
                                email = user
            )
        print(work)
        # except Exception as e:
        #     print(e)
        return Response({"data": work, 'workerNames' : workerNames}, status=200)

    except Exception as e:
        return Response({"error": str(e)}, status=500)


@api_view(['POST'])
def AddTasks(request):
    try:
        # Step 1: Get the email from the cache (session)
        # email = request.data.get('email')
        workerEmail = request.data.get('workerEmail')
        email = request.data.get('email')
        print(workerEmail)
        user1 = Users.objects.filter(email=email).first()
        if not workerEmail:
            return Response({"error": "User is not logged in or session expired"}, status=401)

        farmName = request.data.get('farmName')
        print(farmName)
        activity = request.data.get('activity')  # Ensure this is a list
        print(activity)
        # Step 2: Verify that the user is valid
        user = Users.objects.filter(email=workerEmail).first()
        if not user:
            return Response({"error": "User not found"}, status=404)

       
       
        Tasks.objects.create(
            farmName=farmName,
            email=user,
            activityName=activity,
            
        )

        suggest  = Suggestions.objects.filter(
            farmName=farmName,
            email=user1,
            assignedDate=timezone.now(),
            activityName=activity,
        )

        for i in suggest :
            i.status = "Assigned"
            i.save()

        work = []
        suggest  = Suggestions.objects.filter(
            farmName=farmName,
            email=user1,
            assignedDate=timezone.now(),
            
        )
        for i in suggest :
            work.append([i.activityName,i.status])
        return Response({"message": "Task added successfully", "data" : work}, status=200)
       
    except Exception as e:
        return Response({"error": str(e)}, status=500)


@api_view(['POST'])
def UpdateTasks(request):
    try:
        # Step 1: Get the email from the cache (session)
        # email = request.data.get('email')
        workerEmail = request.data.get('workerEmail')
        if not workerEmail:
            return Response({"error": "User is not logged in or session expired"}, status=401)

        id = int(request.data.get('activityId'))
        farmName = request.data.get('name')
        # activity = request.data.get('activity')  # Ensure this is a list
        # dateAssigned = request.data.get('date')
        # Step 2: Verify that the user is valid
        user = Users.objects.filter(email=workerEmail).first()
        user1 = Users.objects.filter(email=user.managerEmail).first()
        try :
            farm = Farms.objects.filter(email=user1, name=farmName).first()
        except Exception as e:
            print(e)
        print(1)
        
        if not user:
            return Response({"error": "User not found"}, status=404)
        print(2)
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
       
        task = Tasks.objects.get(
            id = id
        )
        task.completionDate = timezone.now()
        task.gdd = weather_data["temperature"]
        task.rain = weather_data["rain"]
        task.humidity = weather_data["humidity"]
        task.wind = weather_data["wind"]
        task.status = "Completed"
        task.save()

        allTasks = Tasks.objects.filter(email=workerEmail, status = "Pending")
        
        taskList = []
        for task in allTasks:
            # Format the date as ISO string for easy parsing in Flutter
            taskList.append([
                task.activityName,
                task.farmName,
                task.assignedDate.isoformat() , # Convert DateTime to ISO string
                str(task.id)
            ])
        return Response({"message": "Task updated successfully","Tasks" : taskList}, status=200)
       
    except Exception as e:
        return Response({"error": str(e)}, status=500)

@api_view(['POST'])
def TaskAnalytics(request):
    email = request.data.get('email')
    print(email)
    try:
        # Get all users who report to the manager
        workers = Users.objects.filter(managerEmail=email)
    except Exception as e:
        print(f"Worker fetch error: {e}")
        return Response({'message': 'Error occurred while fetching workers'}, status=404)

    try:
        resolution = {}
        completed = 0
        pending = 0
        ticketsOverTime = {}
        for worker in workers:
            # Since email is a foreign key, we can query using the user object
            completed_tasks = Tasks.objects.filter(email_id=worker, status="Completed")

            for task in completed_tasks:
                # if str(ticket.issueDate) not in ticketsOverTime.keys() : 
                #     ticketsOverTime[str(ticket.issueDate)] = 1

                # else : 
                #     ticketsOverTime[str(ticket.issueDate)] += 1
                completed_tasks +=1
                # duration = ticket.closingDate - ticket.issueDate
                # t_hours = int(duration.total_seconds() // (24*3600))  # convert to hours

                # if ticket.category not in resolution.keys() :
                #     resolution[ticket.category] = {}
                #     resolution[ticket.category][t_hours] = 1


                # else :
                #     if ticket.category not in resolution[t_hours].keys() :
                #         resolution[ticket.category][t_hours] = 1

                #     else :
                #         resolution[ticket.category][t_hours] += 1

        for worker in workers:
            # Since email is a foreign key, we can query using the user object
            pending_tasks = Tasks.objects.filter(email=worker, status="Pending")
            
            for task in pending_tasks:
            #     if str(ticket.issueDate) not in ticketsOverTime.keys() : 
            #         ticketsOverTime[str(ticket.issueDate)] = 1

            #     else : 
            #         ticketsOverTime[str(ticket.issueDate)] += 1
                pending +=1
               

        return Response({'resolution': resolution,'pending' : pending,'openCount':openCount, 'completed' : completed }, status=200, )

    except Exception as e:
        print(f"Exception is: {e}")
        return Response({'message': "Error occurred while processing tickets"}, status=500)


@api_view(['POST'])
def GetTasks(request):
    try:
        workerEmail = request.data.get('workerEmail')
        print(workerEmail)
        if not workerEmail:
            return Response({"error": "User is not logged in or session expired"}, status=401)

        user = Users.objects.filter(email=workerEmail).first()
        if not user:
            return Response({"error": "User not found"}, status=404)

        allTasks = Tasks.objects.filter(email=workerEmail, status = "Pending")
        
        taskList = []
        for task in allTasks:
            # Format the date as ISO string for easy parsing in Flutter
            taskList.append([
                task.activityName,
                task.farmName,
                task.assignedDate.isoformat() , # Convert DateTime to ISO string
                str(task.id)
            ])
            
        print("Sending tasks:", taskList)
        # taskList = [["af",'afd',timezone.now()]]
        return Response({
            "message": "Tasks fetched successfully", 
            "Tasks": taskList
        }, status=200)
       
    except Exception as e:
        print("Error in GetTasks:", str(e))
        return Response({"error": str(e)}, status=500)


@api_view(['POST'])
def CustomizedReports(request):
    try:
        fromDate = request.data.get('fromDate')
        toDate = request.data.get('toDate')
        fromDate = datetime.strptime(fromDate, '%Y-%m-%d')
        toDate = datetime.strptime(toDate, '%Y-%m-%d')
        email = request.data.get('email')
        farm = request.data.get('farm')
        dataType = request.data.get('dataType')
        fromDate = timezone.make_aware(fromDate)
        toDate = timezone.make_aware(toDate)
        user = Users.objects.filter(email=email).first()
        Farm = Farms.objects.filter(name = farm, email = user).first()
        if(dataType == "Weather Data"):
            headers = {"accept": "application/json"}
            url = f"https://api.tomorrow.io/v4/weather/forecast?location={Farm.location}&apikey=OMbq1FMmdpBv8I2bjdzFEA8zeXMCIPUT"
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
                try :
                    
                    print(len(response_dict['timelines']['daily']))
                    print("wef")
                except Exception as e :
                    print(e)
                weather_data = []
                day  = date.today()
                for i in range(len(response_dict['timelines']['daily'])):
                    weather_data.append({
                        'date': day ,
                        'rain' : response_dict['timelines']['daily'][i]['values']['rainAccumulationAvg'],
                        'wind' : response_dict['timelines']['daily'][i]['values']['windSpeedAvg'],
                        'temperature' : response_dict['timelines']['daily'][i]['values']['temperatureApparentAvg'],
                        'precipitation' : response_dict['timelines']['daily'][i]['values']['precipitationProbabilityAvg'],
                        'humidity' : response_dict['timelines']['daily'][i]['values']['humidityAvg']
                    })
                    day = day + timedelta(days = 1)
                
                return Response({ "data": weather_data}, status=200)
            except Exception as e:
                return Response({ "message": "unsuccesfull", "data" : []}, status=500)
                print(e)

        workers = Users.objects.filter(managerEmail=email)
        
        activities = []
        for worker in workers :

            allTasks = Tasks.objects.filter(
                email=worker,
                farmName=farm,
                assignedDate__gte=fromDate,
                assignedDate__lte=toDate
            )

            for task in allTasks :
                activities.append({
                    "name" : worker.name,
                    "activity" : task.activityName,
                    "farm" : task.farmName,
                    "date assigned": task.assignedDate.isoformat() , # Convert DateTime to ISO string
                    "status" : task.status
                })
        
        return Response({"data": activities }, status=200)
       
    except Exception as e:
        print("Error in GetTasks:", str(e))
        return Response({ "message": "unsuccesfull", "data" : []}, status=500)


classes = ['Apple___Apple_scab',
 'Apple___Black_rot',
 'Apple___Cedar_apple_rust',
 'Apple___healthy',
 'Blueberry___healthy',
 'Cherry_(including_sour)___Powdery_mildew',
 'Cherry_(including_sour)___healthy',
 'Corn_(maize)___Cercospora_leaf_spot Gray_leaf_spot',
 'Corn_(maize)___Common_rust_',
 'Corn_(maize)___Northern_Leaf_Blight',
 'Corn_(maize)___healthy',
 'Grape___Black_rot',
 'Grape___Esca_(Black_Measles)',
 'Grape___Leaf_blight_(Isariopsis_Leaf_Spot)',
 'Grape___healthy',
 'Orange___Haunglongbing_(Citrus_greening)',
 'Peach___Bacterial_spot',
 'Peach___healthy',
 'Pepper,_bell___Bacterial_spot',
 'Pepper,_bell___healthy',
 'Potato___Early_blight',
 'Potato___Late_blight',
 'Potato___healthy',
 'Raspberry___healthy',
 'Soybean___healthy',
 'Squash___Powdery_mildew']

@api_view(['POST'])
def DiseaseDetection(request):
    try:
        image_file = request.FILES.get('image')
        if image_file is None:
            return Response({'error': 'No image uploaded'}, status=400)

        # Read image as bytes and convert to PIL Image
        img_data = image_file.read()
        image = Image.open(io.BytesIO(img_data)).convert('RGB')  # Ensure 3 channels (RGB)

        try:
            model = load_model("activities/diseaseDetections.keras")
        except Exception as e:
            print(f"Model loading error: {e}")
            return Response({'confidence': 0}, status=500)

        # Preprocess image
        IMAGE_SIZE = 256
        img = image.resize((IMAGE_SIZE, IMAGE_SIZE))  # Resize image
        img_array = tf.keras.utils.img_to_array(img)
        img_array = tf.expand_dims(img_array, axis=0)  # Add batch dimension

        # (Optional) Display image for debugging
        # plt.imshow(img_array[0].astype("uint8"))
        # plt.show()

        # Prediction
        pred = model.predict(img_array)
        predicted_class = classes[int(np.argmax(pred))]
         
        return Response({
            'confidence': predicted_class  # Convert NumPy array to list for JSON serialization
        })

    except Exception as e:
        print(f"Error during prediction: {e}")
        return Response({'error': str(e)}, status=500)