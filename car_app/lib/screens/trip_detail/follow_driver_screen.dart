import 'package:car_app/models/driver.dart';
import 'package:car_app/models/trip.dart';
import 'package:flutter/material.dart';

class FollowDriverScreen extends StatefulWidget {
  final Trip trip;
  final Driver driver;

  const FollowDriverScreen({Key? key, required this.trip, required this.driver})
      : super(key: key);
  @override
  _FollowDriverScreenState createState() => _FollowDriverScreenState();
}

class _FollowDriverScreenState extends State<FollowDriverScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: BackButton(),
      ),
    );
  }
}
