from django.db import models

# Create your models here.


class Notification(models.Model):
    CATEGORIES = [
        (0, 'System'),
        (1, 'User cancel the trip'),
        (2, 'Driver accept the trip'),
        (3, 'Driver cancel the trip'),
        (4, 'The trip completed')
    ]

    title = models.TextField(null=True)
    body = models.TextField(null=True)
    notice_time = models.DateTimeField(null=True)
    status = models.CharField(null=True, max_length=10)
    receiver = models.ManyToManyField("user.User")
    sender = models.ForeignKey(
        "user.User", null=True, on_delete=models.CASCADE, related_name='FK_USER_NOTIFICATION')
    receiver_type = models.SmallIntegerField(null=True)
    category = models.SmallIntegerField(choices=CATEGORIES, default=0)
    trip = models.ForeignKey("trip.Trip", null=True, on_delete=models.CASCADE,related_name='FK_TRIP_NOTIFICATION')
