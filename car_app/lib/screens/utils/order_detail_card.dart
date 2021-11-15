import 'package:car_app/models/geoapify_models/geoplace.dart';
import 'package:car_app/models/trip.dart';
import 'package:car_app/services/geoapify_service.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class OrderDetailCard extends StatelessWidget {
  final Trip trip;

  const OrderDetailCard({Key? key, required this.trip}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    var duration = '';
    if (trip.end_time != null && trip.start_time != null)
      duration = trip.end_time!.difference(trip.start_time!).toString();
    return Card(
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 5),
        child: Column(
          children: [
            FutureBuilder<GeoPlace?>(
                future: GeoapifyService.geoReverseGeocoding(
                    trip.start_location.lat, trip.start_location.lng),
                builder: (context, snapshot) {
                  return FieldWidget(
                    label: 'From:',
                    data: snapshot.data?.address ?? 'Start location',
                    icon: Icons.location_on,
                  );
                }),
            FutureBuilder<GeoPlace?>(
                future: GeoapifyService.geoReverseGeocoding(
                    trip.end_location.lat, trip.end_location.lng),
                builder: (context, snapshot) {
                  return FieldWidget(
                    label: 'To:',
                    data: snapshot.data?.address ?? 'End location',
                    icon: Icons.location_on_outlined,
                  );
                }),
            FieldWidget(
              label: 'Start at:',
              data: trip.start_time != null
                  ? DateFormat('yyyy-MM-dd – kk:mm').format(trip.start_time!)
                  : '',
              icon: Icons.timer,
            ),
            FieldWidget(
              label: 'End at:',
              data: trip.end_time != null
                  ? DateFormat('yyyy-MM-dd – kk:mm').format(trip.end_time!)
                  : '',
              icon: Icons.av_timer_outlined,
            ),
            FieldWidget(
              label: 'Duration:',
              data: duration,
              icon: Icons.departure_board,
            ),
            FieldWidget(
              label: 'Price:',
              data: '30.000 VND',
              icon: Icons.attach_money,
            ),
          ],
        ),
      ),
    );
  }
}

class FieldWidget extends StatelessWidget {
  const FieldWidget({
    Key? key,
    required this.label,
    required this.data,
    required this.icon,
  }) : super(key: key);

  final String label;
  final String data;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(
          width: 65,
          child: Text(
            label,
            style: TextStyle(
              fontSize: 16,
              color: Colors.black54,
            ),
          ),
        ),
        SizedBox(
          width: 5,
        ),
        Expanded(
          child: TextField(
            readOnly: true,
            decoration: InputDecoration(
              contentPadding: EdgeInsets.symmetric(vertical: 5),
              hintText: data,
              icon: Icon(
                icon,
                size: 20,
                color: Theme.of(context).primaryColor,
              ),
              border: InputBorder.none,
            ),
          ),
        ),
      ],
    );
  }
}
