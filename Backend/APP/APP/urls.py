"""
URL configuration for APP project.

The `urlpatterns` list routes URLs to views. For more information please see:
    https://docs.djangoproject.com/en/5.1/topics/http/urls/
Examples:
Function views
    1. Add an import:  from my_app import views
    2. Add a URL to urlpatterns:  path('', views.home, name='home')
Class-based views
    1. Add an import:  from other_app.views import Home
    2. Add a URL to urlpatterns:  path('', Home.as_view(), name='home')
Including another URLconf
    1. Import the include() function: from django.urls import include, path
    2. Add a URL to urlpatterns:  path('blog/', include('blog.urls'))
"""
from django.contrib import admin
from django.urls import path, include
from home.views import *
from django.views.generic.base import RedirectView

urlpatterns = [
    path('signup',Signup, name = 'Signup'),
    path('otp',generateOTP, name = 'generateOTP'),
    path('verifyOTP',CheckOTP, name = 'CheckOTP'),
    path('loginEmail',LoginViaEmail, name = 'LoginViaEmail'),
     path('loginPhone',LoginViaPhone, name = 'LoginViaPhone'),
    path('admin/', admin.site.urls),
    # path("", include('googleauthentication.urls')),
    path("accounts/", include("allauth.urls")),
    path('', RedirectView.as_view(url='http://localhost:62253/', permanent=False), name='home_redirect'),
]
