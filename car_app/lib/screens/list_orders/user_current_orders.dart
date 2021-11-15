import 'package:cached_network_image/cached_network_image.dart';
import 'package:car_app/apis/api.dart';
import 'package:car_app/models/driver.dart';
import 'package:car_app/models/trip.dart';
import 'package:car_app/screens/trip_detail/trip_detail_screen.dart';
import 'package:car_app/state/current_trip.dart';
import 'package:car_app/state/current_user.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class UserCurrentOrder extends StatefulWidget {
  @override
  _UserCurrentOrderState createState() => _UserCurrentOrderState();
}

class _UserCurrentOrderState extends State<UserCurrentOrder> {
  List<Trip> _orders = [];
  // List<Driver?> _drivers = [];

  Future<Driver?> _getDriverInfo(int? id) async {
    return await Api().getDriverInfo(id);
  }

  Future _getListOrder() async {
    var currentUser =
        Provider.of<CurrentUser>(context, listen: false).getCurrentUser;
    _orders = await Api.getCurrentOrders(currentUser.id);
  }

  @override
  void initState() {
    _getListOrder().then((value) => setState(() {}));
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    Widget _leading(Driver? driver) {
      if (_orders.isEmpty) {
        return Container();
      }
      if (driver != null) {
        return Container(
          height: 50,
          width: 50,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            image: driver.user.avatar_url == null
                ? DecorationImage(
                    image: AssetImage('assets/images/non_avatar.jpg'),
                  )
                : DecorationImage(
                    image: CachedNetworkImageProvider(driver.user.avatar_url!),
                  ),
          ),
        );
      } else
        return CircleAvatar(
          backgroundColor: Colors.transparent,
          child: Center(
            child: Text(
              'W',
              style: TextStyle(
                  color: Colors.green,
                  fontWeight: FontWeight.bold,
                  fontSize: 25),
            ),
          ),
        );
    }

    _goToTripDetailScreen(Trip trip, Driver? driver) =>
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => TripDetailScreen(trip: trip, driver: driver),
          ),
        );

    return Scaffold(
      appBar: AppBar(
        leading: BackButton(),
      ),
      body: Center(
        child: ListView.builder(
          itemBuilder: (context, i) => FutureBuilder<Driver?>(
            future: _getDriverInfo(_orders[i].driver),
            builder: (context, driverSnapshot) {
              return !driverSnapshot.hasError
                  ? GestureDetector(
                      onTap: () => _goToTripDetailScreen(
                          _orders[i], driverSnapshot.data),
                      child: ListTile(
                        leading: _leading(driverSnapshot.data),
                        title: Text('To: ${_orders[i].end_location}'),
                        subtitle: Text(_orders[i].status),
                      ),
                    )
                  : Center(
                      child: LinearProgressIndicator(),
                    );
            },
          ),
          itemCount: _orders.length,
        ),
      ),
    );
  }
}
