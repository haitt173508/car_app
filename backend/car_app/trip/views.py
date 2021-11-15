from django.http import JsonResponse
from django.views import View
from rest_framework.views import APIView
import json
from django.forms.models import model_to_dict
from django.db import IntegrityError, DatabaseError, transaction
from .models import Trip
from user.models import User
from driver.models import Driver
from location.models import Location
from django.db.models import Q
from django.utils import timezone, dateparse

# Create your views here.


class TripView(APIView):
    def get(self, request, status=None, cab_type=None, *args, **kwargs):
        if status != None and cab_type != None:
            ''' get valid trips'''
            try:
                trips = Trip.objects.filter(status=status, cab_type=cab_type)
                data = [model_to_dict(trip) for trip in trips]
                for d, trip in zip(data, trips):
                    d['user'] = trip.user.id
                    d['start_location'] = model_to_dict(trip.start_location)
                    d['end_location'] = model_to_dict(trip.end_location)
                return JsonResponse(data, safe=False, status=200)
            except Exception as e:
                return JsonResponse({'message': str(e)}, status=500)
        else:
            return JsonResponse({})

    def post(self, request, status=None, cab_type=None, *args, **kwargs):
        try:
            with transaction.atomic():
                user = request.user
                ''' add a trip '''
                data = json.loads(request.body)
                start_location, start_location_created = Location.objects.get_or_create(
                    lat=data['start_location']['lat'],
                    lng=data['start_location']['lng'],)
                end_location, end_location_created = Location.objects.get_or_create(
                    lat=data['end_location']['lat'],
                    lng=data['start_location']['lng'],)
                trip = Trip.objects.create(
                    user=user,
                    start_location=start_location,
                    end_location=end_location,
                    order_time=data['order_time'],
                    start_time=data['start_time'],
                    end_time=data['end_time'],
                    price=data['price'],
                    user_rating=data['user_rating'],
                    user_review=data['user_review'],
                    status=data['status'],
                    cab_type=data['cab_type']
                )
                trip.save()
                data['id'] = trip.id
                return JsonResponse({'message': 'success', 'data': data})
        except DatabaseError as e:
            transaction.rollback()
            return JsonResponse({'message': str(e)})


class TripAcceptView(APIView):
    def get(self, request, id=None):
        if id is not None:
            trip = Trip.objects.get(id=id)
            data = model_to_dict(trip)
            data['start_location'] = model_to_dict(trip.start_location)
            data['end_location'] = model_to_dict(trip.end_location)
            data['user'] = trip.user.id
            return JsonResponse(data,status=200)
        else:
            return JsonResponse({})
        

    def put(self, request, id=None, *args, **kwargs):
        message = 'success'
        user = request.user
        try:
            trip = Trip.objects.get(id=id)
            if trip.status == 'Waitting':
                try:
                    with transaction.atomic():
                        driver = Driver.objects.get(user=user)
                        trip.driver = driver
                        trip.status = 'Processing'
                        trip.save()
                        return JsonResponse({'message': message})
                except Exception as e:
                    transaction.rollback()
                    message = e
                    return JsonResponse({'message': message})
            else:
                return JsonResponse({'message': 'Your trip was accepted by onther driver', 'code': 1}, status=404)
        except Exception as e:
            return JsonResponse({'message': 'Error occur', 'code': 3})
        except Trip.DoesNotExist as e:
            message = 'This trip no longer exist'
            return JsonResponse({'message': message, 'code': 2}, status=404)


class CurrentTripView(View):
    def get(self, request, uid, *args, **kwargs):
        user = User.objects.get(id=uid)
        trips = Trip.objects.filter(
            Q(status='Waitting') | Q(status='Processing'), user=user)
        data = [model_to_dict(trip) for trip in trips]
        for d, trip in zip(data, trips):
            d['user'] = user.id
            d['start_location'] = model_to_dict(trip.start_location)
            d['end_location'] = model_to_dict(trip.end_location)
        return JsonResponse(data, safe=False)


class AllTrip(View):
    def get(self, request, uid, *args, **kwargs):
        user = User.objects.get(id=uid)
        trips = Trip.objects.filter(user=user)
        data = [model_to_dict(trip) for trip in trips]
        for d, trip in zip(data, trips):
            d['user'] = user.id
            d['start_location'] = model_to_dict(trip.start_location)
            d['end_location'] = model_to_dict(trip.end_location)
        return JsonResponse(data, safe=False)


class DriverCurrentTripView(View):
    def get(self, request, id, status, *args, **kwargs):
        try:
            driver = Driver.objects.get(id=id)
            trip = Trip.objects.get(driver=driver, status=status)
            data = model_to_dict(trip)
            data['user'] = trip.user.id
            data['start_location'] = model_to_dict(trip.start_location)
            data['end_location'] = model_to_dict(trip.end_location)
            return JsonResponse({'data': data}, status=200)
        except Exception as e:
            return JsonResponse({'message': str(e)})


class TripEndView(APIView):
    def put(self, request, id=None):
        user = request.user
        data = json.loads(request.body)
        trip = Trip.objects.get(id=id)
        print(data['start_time'])
        trip.end_time = dateparse.parse_datetime(data['end_time'])
        trip.start_time = dateparse.parse_datetime(data['start_time'])
        trip.status = data['status']
        trip.user_review = data['user_review']
        trip.user_rating = data['user_rating']
        try:
            trip.save()
            return JsonResponse({'message':'success','code':201},status=201)
        except Exception as e:
            print(str(e))
            return JsonResponse({'message':str(e)})