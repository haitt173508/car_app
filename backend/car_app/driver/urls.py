from django.urls import path, include
from .views import DriverView

urlpatterns = [
    path('', include([
        path('uid=<int:uid>', DriverView.as_view()),
        path('id=<int:id>', DriverView.as_view()),
    ]))
]
