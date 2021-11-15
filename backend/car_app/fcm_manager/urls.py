from django.urls import path, include
from .views import FCMManagerView

urlpatterns = [
    path('', include([
        path('', FCMManagerView.as_view(),),
        path('<str:token>', FCMManagerView.as_view(),),
    ]))
]
