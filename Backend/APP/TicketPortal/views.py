from django.shortcuts import render, redirect
from rest_framework.decorators import api_view
from rest_framework.response import Response
from django.contrib.auth.hashers import make_password
from .models import Tickets
from home.models import Users
from .serializers import TicketsSerializer
# from .sendOTPS import *
from django.contrib.auth import logout
from django.core.cache import cache


@api_view(['POST'])
def raiseIssue(request) :
    # print(1) 
    email = cache.get('email')
    issue = request.data.get('issue')
    status = "Pending"
    try:
        # Fetch the Users instance based on the email
        user = Users.objects.get(email=email)
    except Users.DoesNotExist:
        return Response({'message': 'User not found for the provided email'}, status=404)
    try :
        ticket = Tickets.objects.create(
                email=user,
                issue=issue,
                status=status,  
            )
        return Response({'message': "Issue succesfully raised"}, status=200)

    except Exception as e :
        print(f"exception is {e}")
        Response({'message': "error occured"}, status=500)

    
    

    


