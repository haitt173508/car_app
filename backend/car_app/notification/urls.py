from django.urls import path, include
from .views import NotificationView

urlpatterns = [
    path('', include([
        path('', NotificationView.as_view()),
        path('<int:id>', NotificationView.as_view()),
        path('id=<int:id>&&user_type=<int:user_type>',
             NotificationView.as_view()),
    ]))
]
