from django.urls import path, include
from .views import UserView

urlpatterns = [
    path('', include([
        path('', UserView.as_view()),
        path('<int:id>', UserView.as_view()),
    ]))
]
