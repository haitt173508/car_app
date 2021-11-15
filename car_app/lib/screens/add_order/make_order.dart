import 'package:car_app/apis/api.dart';
import 'package:car_app/models/trip.dart';
import 'package:car_app/screens/home/router/home_router.dart';
import 'package:car_app/services/place_service.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class MakeOrder extends StatefulWidget {
  final Trip trip;

  const MakeOrder({Key? key, required this.trip}) : super(key: key);
  @override
  _MakeOrderState createState() => _MakeOrderState();
}

class _MakeOrderState extends State<MakeOrder> {
  _makeAnOrder(Trip trip) async {
    var message = await Api.addOrder(trip);
    return message;
  }

  @override
  Widget build(BuildContext context) {
    PlaceService _placeService = Provider.of<PlaceService>(context);

    final Dialog errorDialog = Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4.0)),
      child: Container(
        height: 200,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(10, 70, 10, 10),
          child: Column(
            children: [
              Text(
                'Warning !!!',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
              ),
              SizedBox(
                height: 5,
              ),
              Text(
                'An error was occurded!',
                style: TextStyle(fontSize: 20),
              ),
              SizedBox(
                height: 20,
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text(
                  'Okay',
                  style: TextStyle(color: Colors.white),
                ),
              )
            ],
          ),
        ),
      ),
    );

    final AlertDialog dialog = AlertDialog(
      content: Text('Confirm make an order'),
      actions: [
        ElevatedButton.icon(
          icon: Icon(Icons.done),
          onPressed: () {
            _makeAnOrder(widget.trip).then(
              (message) {
                if (message == 'success') {
                  _placeService.origin = null;
                  _placeService.destination = null;
                  _placeService.direction = null;
                  Navigator.of(context).pushAndRemoveUntil(
                      MaterialPageRoute(
                        builder: (context) => HomeRouter(),
                      ),
                      (route) => false);
                } else {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => errorDialog),
                  );
                }
              },
            );
          },
          label: Text('Confirm'),
        ),
        ElevatedButton.icon(
          icon: Icon(Icons.close),
          onPressed: () => Navigator.pop(context),
          label: Text('Cancel'),
        ),
      ],
    );

    return Scaffold(
      appBar: AppBar(
        title: Text('Order info'),
        // backgroundColor: Colors.transparent,
        elevation: 0.0,
        actions: [
          IconButton(
            onPressed: () => Navigator.of(context).pop(),
            icon: Icon(Icons.cancel_outlined),
          ),
        ],
      ),
      body: Center(
        child: Container(
          child: Column(
            children: [
              Text(
                widget.trip.toJson().toString(),
              ),
              ElevatedButton(
                onPressed: () => showDialog(
                  context: context,
                  builder: (context) => dialog,
                ),
                child: Text('Order'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
