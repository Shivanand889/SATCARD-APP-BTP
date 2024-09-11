from django.shortcuts import render
from rest_framework.decorators import api_view
from rest_framework.response import Response
from .models import Users 
from .serializers import UsersSerializer
# Create your views here.

@api_view(['POST'])
def Signup(request):
    print(request.data)
    return Response({'id':'1'})

