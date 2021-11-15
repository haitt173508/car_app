import 'package:car_app/models/driver.dart';
import 'package:flutter/material.dart';

class DriverProfileScreen extends StatefulWidget {
  final Driver driver;

  const DriverProfileScreen({Key? key, required this.driver}) : super(key: key);
  @override
  _DriverProfileScreenState createState() => _DriverProfileScreenState();
}

class _DriverProfileScreenState extends State<DriverProfileScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: BackButton(),
      ),
    );
  }
}
