from django.db import models

# Create your models here.


class Cab(models.Model):

    CAB_TYPE_CHOICES = [
        ('Motorbike', 'Motorbike'),
        ('Car', 'Car'),
    ]

    reg_no = models.CharField(max_length=50)
    brand = models.CharField(max_length=30)
    model = models.CharField(max_length=30)
    cab_type = models.CharField(max_length=20, choices=CAB_TYPE_CHOICES)


class Driver(models.Model):

    STATUS_CHOICES = [
        ('Online', 'Online'),
        ('Busy', 'Busy'),
        ('Offline', 'Offline')
    ]

    user = models.OneToOneField("user.User", on_delete=models.CASCADE)
    cab = models.OneToOneField(Cab, on_delete=models.CASCADE)
    status = models.CharField(max_length=20, choices=STATUS_CHOICES)
    rating = models.FloatField(default=0.0)
    license_driver = models.CharField(max_length=12)
