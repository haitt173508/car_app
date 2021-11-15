from django.db import models

# Create your models here.


class Direction(models.Model):
    bound = models.ForeignKey("direction.Bound", on_delete=models.CASCADE)
    polyline = models.TextField()
    duration = models.CharField(max_length=10)
    distance = models.CharField(max_length=10)


class Bound(models.Model):
    southwest = models.ForeignKey(
        "location.Location", on_delete=models.CASCADE,related_name='FK_SOUTHEST')
    northeast = models.ForeignKey(
        "location.Location", on_delete=models.CASCADE,related_name='FK_NORTHEAST')
