from django.db import models

# Create your models here.


class Trip(models.Model):

    STATUS_CHOICES = [
        ('Completed', 'Completed'),
        ('Cancelled', 'Cancelled'),
        ('Waiting', 'Waiting'),
        ('Processing', 'Processing')
    ]

    CAB_TYPE_CHOICES = [
        ('Motorbike', 'Motorbike'),
        ('Car', 'Car'),
        ('Every types', 'Every types'),
    ]

    user = models.ForeignKey(
        "user.User", on_delete=models.CASCADE, related_name='FK_USER_TRIP')
    driver = models.ForeignKey(
        "driver.Driver", on_delete=models.CASCADE, related_name='FK_DRIVER_TRIP', null=True)
    start_location = models.ForeignKey(
        "location.Location", on_delete=models.CASCADE, related_name='FK_START_LOCATION_TRIP')
    end_location = models.ForeignKey(
        "location.Location", on_delete=models.CASCADE, related_name='FK_END_LOCATION_TRIP')
    order_time = models.DateTimeField(auto_now_add=True)
    start_time = models.DateTimeField(null=True)
    end_time = models.DateTimeField(null=True)
    price = models.IntegerField(null=True)
    user_rating = models.FloatField(null=True)
    user_review = models.TextField(null=True)
    status = models.CharField(max_length=20, choices=STATUS_CHOICES)
    cab_type = models.CharField(
        default='Motorbike', max_length=20, choices=CAB_TYPE_CHOICES)
