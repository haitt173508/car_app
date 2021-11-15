from django.shortcuts import render
from django.http import JsonResponse
from user.models import User
from .models import Driver, Cab
from django.db import IntegrityError, DatabaseError, transaction
from django.core import serializers
from django.contrib.auth import authenticate
import json
from django.forms.models import model_to_dict
from rest_framework_simplejwt.serializers import TokenObtainPairSerializer
from rest_framework.views import APIView
from rest_framework.permissions import IsAuthenticated
# Create your views here.


class DriverView(APIView):
    def get(self, request, uid=None, id=None, *args, **kwargs):
        if uid is not None:
            user = User.objects.get(id=uid)
            queryset = Driver.objects.filter(user=user)
            if queryset:
                driver = queryset[0]
                data = model_to_dict(driver)
                data['user'] = model_to_dict(user)
                data['cab'] = model_to_dict(driver.cab)
                return JsonResponse(data)
            else:
                return JsonResponse({'message': 'error'}, status=500)
        elif id is not None:
            user = request.user
            queryset = Driver.objects.filter(id=id)
            if queryset:
                driver = queryset[0]
                data = model_to_dict(driver)
                data['user'] = model_to_dict(driver.user)
                data['cab'] = model_to_dict(driver.cab)
                return JsonResponse(data)
            else:
                return JsonResponse({}, status=401)
        else:
            return JsonResponse({})
