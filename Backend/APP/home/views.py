from django.shortcuts import render, redirect
from rest_framework.decorators import api_view
from rest_framework.response import Response
from django.contrib.auth.hashers import make_password
from .models import Users
from .serializers import UsersSerializer
from .sendOTPS import *
from django.contrib.auth import logout




@api_view(['POST'])
def SignupViaEmail(request):
    name = request.data.get('name')
    # email = request.data.get('email')
    password = request.data.get('password')
    # phone_number = request.data.get('phoneNumber')
    
    # Check if email already exists in the Users table
    if Users.objects.filter(email=email).exists():
        return Response({'signup error': 'email already exists'}, status=400)
    
    # Hash the password before saving
    hashed_password = make_password(password)
    
    # Create and save new user with hashed password
    user = Users.objects.create(
        name=name,
        email=request.session['email'],
        password=hashed_password,  # Storing hashed password
        phoneNumber=request.session['phone']
    )
    
    # Return the user's ID or relevant data
    return Response({'id': user.id, 'name': user.name, 'email': user.email}, status=201)

@api_view(['POST'])
def generateOTP(request) :
    type = request.GET.get('type','')

    otp = random.randint(1000,9999)
    request.session['otp'] = otp
    
    
    if(type =='1'):
        receiver_email = request.data.get('email')
        request.session['email'] = receiver_email
        send_email('aa', '112101045@smail.iitpkd.ac.in', f'{otp}')
    
    else :
        phone = request.data.get('phoneNumber')
        request.session['phone'] = phone
        sendSMS(phone, f'your otp is {otp}')
    return Response({'status' : 'done'})


@api_view(['POST'])
def CheckOTP(request) :

    otp = int(request.data.get('otp'))
    
    if(otp == request.session['otp']):
        return Response({'success' : 1}) 
    
    else :
        return Response({'success' : 0}) 


@api_view(['POST'])
def LoginViaEmail(request):
    email = request.data.get('email')
    password = request.data.get('password')


    try:
        user = Users.objects.get(email=email)
    except Users.DoesNotExist:
        return Response({'message': 'Email not found'}, status=404)

    hashed_password = make_password(password)
    if password != user.password :
        return Response({'message': 'Incorrect password'}, status=400)

    return Response({'message': 'Login successful'}, status=200)
    
