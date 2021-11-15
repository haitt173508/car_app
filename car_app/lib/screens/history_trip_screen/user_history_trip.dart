import 'package:car_app/apis/api.dart';
import 'package:car_app/models/driver.dart';
import 'package:car_app/models/trip.dart';
import 'package:car_app/models/user.dart';
import 'package:car_app/screens/order_detail/order_detail.dart';
import 'package:flutter/material.dart';

class UserHistoryTrip extends StatefulWidget {
  final User user;
  const UserHistoryTrip({Key? key, required this.user}) : super(key: key);
  @override
  _UserHistoryTripState createState() => _UserHistoryTripState();
}

class _UserHistoryTripState extends State<UserHistoryTrip> {
  List<Trip> _trips = [];

  Future<List<Trip>?> _getTrip(User user) async {
    var res = await Api.getTrips(user);
    return res;
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Your trip history'),
      ),
      body: FutureBuilder<List<Trip>?>(
        future: _getTrip(widget.user),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            if (snapshot.data != null) _trips = snapshot.data!;
            return ListView.builder(
              itemCount: _trips.length,
              itemBuilder: (_, i) => TripWidget(trip: _trips[i]),
            );
          } else if (snapshot.hasError)
            return Center(
              child: Text('An error occur'),
            );
          else
            return Center(
              child: CircularProgressIndicator(),
            );
        },
      ),
    );
  }
}

class TripWidget extends StatefulWidget {
  final Trip trip;
  const TripWidget({
    Key? key,
    required this.trip,
  }) : super(key: key);

  @override
  _TripWidgetState createState() => _TripWidgetState();
}

class _TripWidgetState extends State<TripWidget> {
  @override
  Widget build(BuildContext context) {
    Widget _leading(String status) {
      late Color color;
      late IconData icon;
      if (status == 'Completed') {
        color = Colors.green;
        icon = Icons.done;
      } else if (status == 'Cancelled') {
        color = Colors.red;
        icon = Icons.cancel;
      } else if (status == 'Processing') {
        color = Colors.blue;
        icon = Icons.local_taxi_rounded;
      } else {
        color = Colors.orange;
        icon = Icons.timelapse;
      }
      return Icon(icon, color: color);
    }

    _goToDetailOrder(Trip trip, Driver? driver) {
      Navigator.of(context).push(MaterialPageRoute(builder: (_) => OrderDetail(trip: trip,driver: driver,),),);
    } 

    return Card(
      child: FutureBuilder<Driver?>(
        future: Api().getDriverInfo(widget.trip.driver),
        builder: (context, snapshot) {
          return !snapshot.hasError
              ? GestureDetector(
                onTap: () => _goToDetailOrder(widget.trip, snapshot.data),
                child: ListTile(
                    leading: _leading(widget.trip.status),
                    title: Text('To ${widget.trip.end_location}'),
                    subtitle: snapshot.data != null
                        ? RichText(
                            text: TextSpan(
                              style:
                                  TextStyle(color: Colors.black54, fontSize: 15),
                              children: [
                                TextSpan(text: 'Driver '),
                                TextSpan(
                                  text: snapshot.data!.user.name,
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                                TextSpan(text: ' is coming'),
                              ],
                            ),
                          )
                        : Text('Waitting a driver'),
                    trailing: Column(
                      children: [
                        Text(
                          widget.trip.price != null
                              ? '${widget.trip.price.toString()} VND'
                              : '30000 VND',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ],
                    ),
                  ),
              )
              : Center(
                  child: Text('Error'),
                );
        },
      ),
    );
  }
}
