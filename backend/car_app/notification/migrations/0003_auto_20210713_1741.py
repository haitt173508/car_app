# Generated by Django 3.2 on 2021-07-13 10:41

from django.db import migrations, models
import django.db.models.deletion


class Migration(migrations.Migration):

    dependencies = [
        ('trip', '0001_initial'),
        ('notification', '0002_auto_20210708_1340'),
    ]

    operations = [
        migrations.AddField(
            model_name='notification',
            name='trip',
            field=models.ForeignKey(null=True, on_delete=django.db.models.deletion.CASCADE, related_name='FK_TRIP_NOTIFICATION', to='trip.trip'),
        ),
        migrations.AlterField(
            model_name='notification',
            name='category',
            field=models.SmallIntegerField(choices=[(0, 'System'), (1, 'User cancel the trip'), (2, 'Driver accept the trip'), (3, 'Driver cancel the trip'), (4, 'The trip completed')], default=0),
        ),
    ]
