from django.urls import path, include
from .views import TripView, TripAcceptView, CurrentTripView, AllTrip, DriverCurrentTripView, TripEndView

urlpatterns = [
    path('', include([
        path('', TripView.as_view()),
        path('driver_id=<int:id>&&status=<str:status>', DriverCurrentTripView.as_view()),
        path('status=<str:status>&&cab_type=<str:cab_type>', TripView.as_view()),
        path('accept/<int:id>', TripAcceptView.as_view()),
        path('end/<int:id>', TripEndView.as_view()),
        path('<int:id>', TripAcceptView.as_view()),
        path('current/<int:uid>', CurrentTripView.as_view()),
        path('all/<int:uid>', AllTrip.as_view()),
    ]))
]
