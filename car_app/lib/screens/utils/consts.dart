import 'package:flutter/material.dart';

class Consts {
  static const List<String> CAB_TYPES = <String>[
    'Motorbike',
    'Car',
  ];

  static const List<Widget> CAB_TYPE_ICONS = <Widget>[
    Icon(Icons.two_wheeler),
    Icon(Icons.local_taxi),
  ];

  static const List<String> TRIP_STATUS = <String>[
    'Completed',
    'Cancelled',
    'Waiting',
    'Processing',
  ];
}
