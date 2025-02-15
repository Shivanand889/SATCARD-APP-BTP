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
def RaiseIssue(request) :
    # print(1) 
    email = cache.get('email')
    issue = request.data.get('issue')
    status = "Pending"
    category = request.data.get("category")
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
                category=  category,
            )
        return Response({'message': "Issue succesfully raised"}, status=200)

    except Exception as e :
        print(f"exception is {e}")
        Response({'message': "error occured"}, status=500)

@api_view(['GET'])
def GetTickets(request):
    email = cache.get('email')
    try:
        # Fetch the Users instance based on the email
        user = Users.objects.get(email=email)
    except Users.DoesNotExist:
        return Response({'message': 'User not found for the provided email'}, status=404)

    try:
        # Get all tickets associated with the user
        tickets = Tickets.objects.filter(email=user)  # Fix this line, you need to filter Tickets, not Users

        data = []
        for ticket in tickets:
            data.append({
                'id': ticket.id,
                'issue': ticket.issue,
                'category': ticket.category,
                'issueDate': ticket.issueDate,
                'status': ticket.status,
                'email': ticket.email.email  # Fetch the email field from ForeignKey
            })

        return Response({'message': "Tickets fetched successfully", "data": data}, status=200)

    except Exception as e:
        print(f"Exception: {e}")
        return Response({'message': "An error occurred"}, status=500)  # Add return here


    
    

    


