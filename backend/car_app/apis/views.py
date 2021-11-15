from user.models import User
from django.http import JsonResponse
from django.views import View
from rest_framework.views import APIView
import json
from django.forms.models import model_to_dict
from django.core import serializers

# Create your views here.


class UserView(APIView):
    def get(self, request, id=None, slug=None, *args, **kwargs):
        try:
            if id is not None:
                user = User.objects.filter(id=id)
                data = serializers.serialize(
                    'json', user, fields=('name', 'username'))
                return JsonResponse(json.loads(data), safe=False)
            param = request.GET
            user = User.objects.filter(**param.dict())
            data = serializers.serialize(
                'json', user, fields=('name', 'username'))
            data = json.loads(data)
            return JsonResponse(data, safe=False)
        except Exception as e:
            return JsonResponse({'error': str(e)})
