from django.http import JsonResponse
from .models import Notification
import json
from django.forms.models import model_to_dict
from rest_framework.views import APIView
from user.models import User
from trip.models import Trip
from fcm_django.models import FCMDevice
from firebase_admin.messaging import Message, Notification as RemoteNotification
from django.utils import timezone
from driver.models import Driver

# Create your views here.


class NotificationView(APIView):
    def get(self, request, id=None, user_type=None, *args, **kwargs):
        if id is not None and user_type is not None:
            receiver_type = user_type
            try:
                user = User.objects.get(id=id)
                notifications = Notification.objects.filter(
                    receiver__id=user.id, receiver_type=receiver_type)
                data = [model_to_dict(notification)
                        for notification in notifications]
                for d in data:
                    d['receiver'] = id
                    # d['trip'] = d['trip']['id']
                    if d['trip'] is not None:
                        trip = Trip.objects.get(id=d['trip'])
                        d['trip'] = model_to_dict(trip)
                        d['trip']['start_location'] = model_to_dict(
                            trip.start_location)
                        d['trip']['end_location'] = model_to_dict(
                            trip.end_location)
                return JsonResponse(data, safe=False, status=200)
            except Exception as e:
                print(str(e))
                return JsonResponse({'message': str(e)}, status=403)
        else:
            pass

    def post(self, request, *args, **kwargs):
        data = json.loads(request.body)
        receiver = User.objects.get(id=data['receiver'])
        sender = User.objects.get(id=data['sender'])
        if data['trip'] is not None:
            trip, create = Trip.objects.get_or_create(
                id=data['trip']['id'])
        else:
            trip = None
        notification = Notification.objects.create(
            title=data['title'],
            body=data['body'],
            receiver_type=data['receiver_type'],
            category=data['category'],
            sender=sender,
            trip=trip,
        )
        notification.receiver.add(receiver)
        try:
            notification.save()
            devices = FCMDevice.objects.filter(user=receiver)
            message_data = {
                'id': str(notification.id),
                'category': str(data['category']),
                'receiver': str(data['receiver']),
                'sender': str(data['sender']),
                'trip': str(trip.id) if trip is not None else None,
            }
            print(message_data)
            devices.send_message(Message(data=message_data, notification=RemoteNotification(
                title=data['title'], body=data['body'])))
            return JsonResponse({'message': 'notify success'})
        except Exception as e:
            print('Error in notification: {}\n'.format(str(e)))
            return JsonResponse({'message': str(e)})

    def put(self, request, id, *args, **kwargs):
        data = json.loads(request.body)
        receiver = User.objects.get(id=data['receiver'])
        notification = Notification.objects.get(
            receiver__id=data['receiver'], id=id)
        notification.status = 'Seen'
        notification.notice_time = timezone.now()
        # notification.save()
        notification.save()
        return JsonResponse({})
