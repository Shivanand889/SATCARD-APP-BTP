from django.shortcuts import render, redirect
from rest_framework.decorators import api_view
from rest_framework.response import Response
from django.contrib.auth.hashers import make_password
from .models import Users
from .serializers import UsersSerializer
from .sendOTPS import *
from django.contrib.auth import logout
from django.core.cache import cache


@api_view(['POST'])
def generateOTP(request) :
    # print(1) 
    type = request.GET.get('type','')
    
    otp = random.randint(100000,999999)
    # request.cache['otp'] = otp
    cache.set('otp', otp, timeout=5*60)
    # request.session.save()
    # print(request.session['otp'])
    
    if(type =='1'):
        # print("ss")
        receiver_email = request.data.get('email')
        name = request.data.get('name')
        password = request.data.get('password')
        # print("ss")
        if Users.objects.filter(email=receiver_email).exists():
            return Response({'status': 0}, status=500)
        # request.session['email'] = receiver_email
        print("ss")
        cache.set('vtype', 1, timeout=None)
        cache.set('name', name, timeout=None)
        cache.set('email', receiver_email, timeout=None)
        cache.set('password', password, timeout=None)
        print("ss")
        send_email('OTP', receiver_email, f'your otp is {otp}')
    
    else :
        phone = request.data.get('phone')
        
        if Users.objects.filter(phoneNumber=phone).exists():
            return Response({'status': 0}, status=400)
        # request.cache['phone'] = phone
        cache.set('vtype', 0, timeout=None)
        cache.set('phone', phone, timeout=None)
        sendSMS(phone, f'your otp is {otp}')
        # return redirect('http://localhost:62253/#/otp')
    return Response({'status': 'done', 'redirect_url': 'http://localhost:62253/#/otp'}, status=200)

    


@api_view(['POST'])
def CheckOTP(request) :
    print(cache.get('email'))
    print("aaa")
    otp = int(request.data.get('otp'))
    if(request.data.get('otp') == None) :
        return Response({'status': 0, 'message' : 'otp timeout'}, status=500)
    # otp = request.session.get('phone')
    print(otp)
    succ = 0 
    if(otp == cache.get('otp')):
        
        # return Response({'success' : 1}) 
        succ = 1
    
    else :
        # return Response({'success' : 0}) 
        succ = 0 

    if cache.get('vtype') :

       
        # hashed_password = make_password(cache.get('password'))
        
        user = Users.objects.create(
            name=cache.get('name'),
            email=cache.get('email'),
            password=cache.get('password'),  
            phoneNumber=cache.get('phone')
        )

        return Response({'success': succ, 'redirect_url': '/'}, status=200)
    
    else :
        return Response({'success': succ, 'redirect_url': '/setup-profile'}, status=200)

@api_view(['POST'])
def LoginViaEmail(request):
    email = request.data.get('email')

    if request.data.get('type')=='1' : 
        password = request.data.get('password')


        try:
            user = Users.objects.get(email=email)
        except Users.DoesNotExist:
            return Response({'message': 'Email not found', 'success' : 0}, status=404)

        # hashed_password = make_password(password)
        print(len(cache.get('password')))
        print(len(password))
        if password != user.password :
            print(1)
            return Response({'message': 'Incorrect password','success' : 0}, status=400)

        cache.set('email', email, timeout=None)
        return Response({'message': 'Login successful','success' : 1},  status=200)

    else :
        
        try:
            print("g1")
            user = Users.objects.get(email=email)
            return Response({'message': 'Login successful','success' : 1},  status=200)
        except Users.DoesNotExist:
            return Response({'message': 'Email not found', 'success' : 0}, status=404)


@api_view(['POST'])
def LoginViaPhone(request):
    phone = request.data.get('phone')
    password = request.data.get('password')


    try:
        user = Users.objects.get(phoneNumber=phone)
    except Users.DoesNotExist:
        return Response({'message': 'phone not found', 'success' : 0}, status=404)

    #  = make_password(password
    if password != user.password :
        return Response({'message': 'Incorrect password', 'success' : 0}, status=400)

    cache.set('phone', phone, timeout=None)
    return Response({'message': 'Login successful', 'success' : 1}, status=200)


@api_view(['POST'])
def gauth(request):
    
    name = request.data.get('name')
    email = request.data.get('email')
    cache.set('email', email, timeout=None)
    print(email)
    user = Users.objects.create(
        name=cache.get('name'),
        email=cache.get('email'),
        # password=cache.get('default'),  
        password = 'default',
        phoneNumber=cache.get('phone')
    )
    return Response({'success': True, 'message': 'Google authentication successful', 'email': email}, status=200)
    



