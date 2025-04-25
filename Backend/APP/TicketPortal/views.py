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
from datetime import timedelta


@api_view(['POST'])
def RaiseIssue(request) :
    # print(1) 
    # email = cache.get('email')
    email = request.data.get('email')
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
    email = request.GET.get('email')
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


@api_view(['POST'])
def TicketAnalytics(request) :
    email = request.data.get('email')

    try:
        # Get all users who report to the manager
        workers = Users.objects.filter(managerEmail=email)
    except Exception as e:
        print(f"Worker fetch error: {e}")
        return Response({'message': 'Error occurred while fetching workers'}, status=404)

    try:
        resolution = {}
        resolvedCount = 0
        openCount = 0
        ticketsOverTime = {}
        for worker in workers:
            # Since email is a foreign key, we can query using the user object
            resolved_tickets = Tickets.objects.filter(email_id=worker, status="Solved")

            for ticket in resolved_tickets:
                if str(ticket.issueDate) not in ticketsOverTime.keys() : 
                    ticketsOverTime[str(ticket.issueDate)] = 1

                else : 
                    ticketsOverTime[str(ticket.issueDate)] += 1
                resolvedCount +=1
                duration = ticket.closingDate - ticket.issueDate
                t_hours = int(duration.total_seconds() // (24*3600))  # convert to hours

                resolution[t_hours] = resolution.get(t_hours, 0) + 1

        for worker in workers:
            # Since email is a foreign key, we can query using the user object
            nonresolved_tickets = Tickets.objects.filter(email=worker, status="Pending")
            
            for ticket in nonresolved_tickets:
                if str(ticket.issueDate) not in ticketsOverTime.keys() : 
                    ticketsOverTime[str(ticket.issueDate)] = 1

                else : 
                    ticketsOverTime[str(ticket.issueDate)] += 1
                openCount +=1
               

        return Response({'resolution': resolution,'resolvedCount' : resolvedCount,'openCount':openCount, 'ticketsOverTime' : ticketsOverTime }, status=200, )

    except Exception as e:
        print(f"Exception is: {e}")
        return Response({'message': "Error occurred while processing tickets"}, status=500)