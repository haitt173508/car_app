"""car_app URL Configuration

The `urlpatterns` list routes URLs to views. For more information please see:
    https://docs.djangoproject.com/en/3.2/topics/http/urls/
Examples:
Function views
    1. Add an import:  from my_app import views
    2. Add a URL to urlpatterns:  path('', views.home, name='home')
Class-based views
    1. Add an import:  from other_app.views import Home
    2. Add a URL to urlpatterns:  path('', Home.as_view(), name='home')
Including another URLconf
    1. Import the include() function: from django.urls import include, path
    2. Add a URL to urlpatterns:  path('blog/', include('blog.urls'))
"""
from django.contrib import admin
from django.urls import path, include
from user.views import UserLoginView

urlpatterns = [
    path('admin/', admin.site.urls),
    path('user/', include('user.urls')),
    path('driver/', include('driver.urls')),
    path('trip/', include('trip.urls')),
    path('login/', UserLoginView.as_view(), name='login'),
    path('oauth/', include('oauth.urls')),
    path('notification/', include('notification.urls')),
    path('fcm/', include('fcm_manager.urls')),
    path('apis/', include('apis.urls')),
]
