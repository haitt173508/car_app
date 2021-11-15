from django.shortcuts import render
from django.http import HttpResponse, JsonResponse
from django.views import View
from driver.models import Driver, Cab
from trip.models import Trip
from django.db import IntegrityError, DatabaseError, transaction
from django.core import serializers
from .models import User
from django.contrib.auth import authenticate, login
import json
from django.forms.models import model_to_dict
from rest_framework_simplejwt.serializers import TokenObtainPairSerializer
from rest_framework.views import APIView
from rest_framework.permissions import IsAuthenticated
from django.db.models import Q
# User = get_user_model()

# Create your views here.


class UserView(APIView):
    # permission_classes = (IsAuthenticated,)

    def get(self, request, id=None, *args, **kwargs):
        if id is not None:
            user = User.objects.get(id=id)
            data = model_to_dict(user)
            return JsonResponse(data)
        else:
            user = request.user
            data = model_to_dict(user)
            return JsonResponse(data)

    def post(self, request, *args, **kwargs):
        data = json.loads(request.body)
        if (data.get('user_type') is not None):
            '''Sign up an user'''
            try:
                user = User.objects.create_user(
                    username=data['username'],
                    password=data['password'],
                    name=data['name'],
                    phone=data['phone'],
                    email=data['email'],
                    age=data['age'],
                    address=data['address'],
                    user_type=data['user_type'],
                )
                # user.save()
                return JsonResponse({'message': 'success'})
            except DatabaseError as e:
                return JsonResponse({'message': str(e)})
        else:
            '''Sign up a driver'''
            cab_data = data['cab']
            try:
                with transaction.atomic():
                    user = User.objects.create_user(
                        name=data['user']['name'],
                        phone=data['user']['phone'],
                        email=data['user']['email'],
                        age=data['user']['age'],
                        address=data['user']['address'],
                        username=data['user']['username'],
                        password=data['user']['password'],
                        user_type=data['user']['user_type'],
                    )
                    cab = Cab.objects.create(
                        model=cab_data['model'],
                        cab_type=cab_data['cab_type'],
                        brand=cab_data['brand'],
                        reg_no=cab_data['reg_no'],
                    )
                    user.save()
                    cab.save()
                    driver = Driver.objects.create(
                        status='Offline',
                        license_driver=data['license_driver'],
                        rating=data['rating'],
                        cab=cab,
                        user=user,
                    )
                    driver.save()
                    return JsonResponse({'message': 'success'})
            except DatabaseError as e:
                transaction.rollback()
                return JsonResponse({'message': str(e)})

    def put(self, request, *args, **kwargs):
        user = request.user
        try:
            data = json.loads(request.body)
            User.objects.filter(id=user.id).update(
                address=data['address'],
                email=data['email'],
                avatar_url=data['avatar_url'],
                age=data['age'],
                name=data['name'],
                phone=data['phone'],
                user_type=data['user_type'],
            )
            return JsonResponse({}, status=300)
        except Exception as e:
            return JsonResponse({'message': e})


class UserLoginView(View):
    def post(self, request, *args, **kwargs):
        data = json.loads(request.body)
        user = authenticate(
            request=request,
            username=data['username'], password=data['password'])
        if user:
            refresh = TokenObtainPairSerializer.get_token(user)
            data = {
                'refresh_token': str(refresh),
                'access_token': str(refresh.access_token)
            }
            return JsonResponse(data)
        else:
            return JsonResponse({'message': 'Invalid username or password'}, status=500)
