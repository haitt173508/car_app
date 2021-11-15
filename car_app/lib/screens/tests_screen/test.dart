import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class TestScreen extends StatefulWidget {
  @override
  _TestScreenState createState() => _TestScreenState();
}

class _TestScreenState extends State<TestScreen> {
  @override
  build(context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(title: Text('Test Screen')),
      body: Column(
        children: [
          TextField(decoration: InputDecoration(icon: Icon(Icons.home))),
          Expanded(
            child: SecondScreen(),
          )
        ],
      ),
    );
  }
}

class SecondScreen extends StatefulWidget {
  @override
  _SecondScreenState createState() => _SecondScreenState();
}

class _SecondScreenState extends State<SecondScreen> {
  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              decoration: InputDecoration(icon: Icon(Icons.search)),
            ),
          ),
          Expanded(
              child: Stack(
            children: [
              GoogleMap(
                  initialCameraPosition:
                      CameraPosition(target: LatLng(21.028511, 105.804817))),
              Container(
                height: 300,
                decoration: BoxDecoration(color: Colors.black.withOpacity(0.6)),
                child: ListView.builder(
                    itemCount: 100, itemBuilder: (_, __) => Icon(Icons.home)),
              )
            ],
          )),
        ],
      ),
    );
  }
}
