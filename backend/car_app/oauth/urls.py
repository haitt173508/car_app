from django.urls import path, include
from rest_framework_simplejwt import views as jwt_views

urlpatterns = [
    path('token/', include([
        path('', jwt_views.TokenObtainPairView.as_view(),
             name='token_obtain_pair'),
        path('refresh', jwt_views.TokenRefreshView.as_view(), name='token_refresh'),
    ]))
]
