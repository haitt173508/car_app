from django.http import JsonResponse
import json
from django.forms.models import model_to_dict
from rest_framework.views import APIView
from fcm_django.models import FCMDevice
from user.models import User

# Create your views here.


class FCMManagerView(APIView):
    def post(self, request, token=None, *args, **kwargs):
        data = json.loads(request.body)
        data['name'] = str(data['name'])
        data['user'] = User.objects.get(id=data['user'])
        device, created = FCMDevice.objects.get_or_create(**data)
        if not created: # created is not None
            return JsonResponse({}, status=200)
        else:
            try:
                device.save()
                return JsonResponse({}, status=200)
            except Exception as e:
                return JsonResponse({'message': e})

    def delete(self, request, token, *args, **kwargs):
        try:
            FCMDevice.objects.filter(registration_id=token).delete()
            return JsonResponse({}, status=200)
        except Exception as e:
            return JsonResponse({'message': str(e)})
