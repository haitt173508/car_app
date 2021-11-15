import 'package:car_app/models/driver.dart';
import 'package:flutter/material.dart';

class DriverHistoryTrip extends StatefulWidget {
  final Driver driver;

  const DriverHistoryTrip({Key? key, required this.driver}) : super(key: key);
  @override
  _DriverHistoryTripState createState() => _DriverHistoryTripState();
}

class _DriverHistoryTripState extends State<DriverHistoryTrip> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: BackButton(),
      ),
    );
  }
}
