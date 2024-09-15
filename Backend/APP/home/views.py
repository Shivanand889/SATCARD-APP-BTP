from django.shortcuts import render, redirect
from rest_framework.decorators import api_view
from rest_framework.response import Response
from django.contrib.auth.hashers import make_password
from .models import Users
from .serializers import UsersSerializer
from .sendOTPS import *
from django.contrib.auth import logout




@api_view(['POST'])
def Signup(request):
    name = request.data.get('name')
    # email = request.data.get('email')
    password = request.data.get('password')
    # phone_number = request.data.get('phoneNumber')
    
    hashed_password = make_password(password)
    
    user = Users.objects.create(
        name=name,
        email=request.session['email'],
        password=hashed_password,  
        phoneNumber=request.session['phone']
    )
    

    return Response({'id': user.id, 'name': user.name, 'email': user.email}, status=201)

@api_view(['POST'])
def generateOTP(request) :
    type = request.GET.get('type','')

    otp = random.randint(1000,9999)
    request.session['otp'] = otp
    
    
    if(type =='1'):

        receiver_email = request.data.get('email')
        if Users.objects.filter(email=receiver_email).exists():
            return Response({'status': 0}, status=400)
        request.session['email'] = receiver_email
        send_email('OTP', receiver_email, f'your otp is {otp}')
    
    else :
        phone = request.data.get('phoneNumber')
        if Users.objects.filter(phoneNumber=phone).exists():
            return Response({'status': 0}, status=400)
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
    
