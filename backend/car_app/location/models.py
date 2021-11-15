from django.db import models

# Create your models here.


class Location(models.Model):
    lat = models.FloatField()
    lng = models.FloatField()


class PlaceDetail(models.Model):
    location = models.OneToOneField(
        "location.Location", on_delete=models.CASCADE)
    id = models.CharField(max_length=255, primary_key=True)
    name = models.CharField(max_length=255)
    url = models.URLField()
