import 'package:car_app/apis/api.dart';
import 'package:car_app/models/driver.dart';
import 'package:car_app/models/geoapify_models/geoplace.dart';
import 'package:car_app/models/notification.dart';
import 'package:car_app/models/trip.dart';
import 'package:car_app/screens/order_detail/order_detail.dart';
import 'package:car_app/screens/trip_detail/driver_trip_detail.dart';
import 'package:car_app/screens/utils/user_avatar.dart';
import 'package:car_app/services/geoapify_service.dart';
import 'package:car_app/state/current_trip.dart';
import 'package:car_app/state/current_user.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ValidOrders extends StatefulWidget {
  @override
  _ValidOrdersState createState() => _ValidOrdersState();
}

class _ValidOrdersState extends State<ValidOrders> {
  List<Trip> _orders = [];

  Future<List<Trip>> _getValidOrders(String cabType) async {
    return await Api.getValidOrders(cabType);
  }

  Future _acceptOrder(Trip trip) async {
    Driver driver =
        Provider.of<CurrentUser>(context, listen: false).getCurrentUser;
    var res = await Api.acceptOrder(trip, driver);
    if (res != null) if (res['message'] == 'success') {
      var currentTrip = Provider.of<CurrentTrip>(context, listen: false);
      currentTrip.setCurrentTrip = trip;
      var notification = NotificationModel(
        title: 'Your trip was accepted',
        body: 'Driver ${driver.user.name} has accepted your trip',
        receiver_type: 1,
        receiver: trip.user,
        sender: driver.user.id,
        category: 2,
        trip: trip,
      );
      await Api.sendNotification(notification);
    }
    return res;
  }

  @override
  void initState() {
    super.initState();
    print(_orders);
  }

  @override
  Widget build(BuildContext context) {
    Driver driver = Provider.of<CurrentUser>(context).getCurrentUser;
    var currentTrip = Provider.of<CurrentTrip>(context);
    Widget successDialog = AlertDialog(
      content: Text('Accept success'),
      actions: [
        OutlinedButton(
          onPressed: () {
            Navigator.of(context).pop();
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(
                builder: (_) => DriverTripDetail(
                    trip: currentTrip.currentTrip, driver: driver),
              ),
            );
          },
          child: Text('Start the trip'),
        ),
      ],
    );
    Widget notSuccessDialog(String error) => AlertDialog(
          content: Text(error),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Close'),
            ),
          ],
        );
    return Scaffold(
      appBar: AppBar(
        leading: BackButton(),
      ),
      body: FutureBuilder<List<Trip>>(
        future: _getValidOrders(driver.cab.cab_type),
        builder: (context, snapshot) {
          _orders = snapshot.data ?? [];
          return Center(
            child: snapshot.hasData
                ? _orders.isNotEmpty
                    ? ListView.builder(
                        itemBuilder: (context, i) => Card(
                          clipBehavior: Clip.antiAlias,
                          child: ListTile(
                            leading: FutureBuilder<Map<String, dynamic>?>(
                              future: Api.getUserInfo(_orders[i].user),
                              builder: (context, snapshot) {
                                return snapshot.data != null
                                    ? UserAvatar(
                                        url: snapshot.data!['avatar_url'],
                                      )
                                    : UserAvatar();
                              },
                            ),
                            title: FutureBuilder<GeoPlace?>(
                                future: GeoapifyService.geoReverseGeocoding(
                                    _orders[i].end_location.lat,
                                    _orders[i].end_location.lng),
                                builder: (context, snapshot) {
                                  return snapshot.data != null
                                      ? Text(
                                          'To: ${snapshot.data!.address!.substring(0, 20)}')
                                      : Text('Destination ...');
                                }),
                            subtitle: Text(_orders[i].status),
                            onTap: () async {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (_) => OrderDetail(trip: _orders[i]),
                                ),
                              );
                            },
                            trailing: TextButton(
                              onPressed: () async {
                                var res = await _acceptOrder(_orders[i]);
                                if (res['message'] == 'success')
                                  showDialog(
                                      context: context,
                                      builder: (_) => successDialog);
                                else
                                  showDialog(
                                    context: context,
                                    builder: (_) =>
                                        notSuccessDialog(res['message']),
                                  );
                              },
                              child: Text('Accept'),
                            ),
                          ),
                        ),
                        itemCount: _orders.length,
                      )
                    : Text('Invalid orders now')
                : CircularProgressIndicator(),
          );
        },
      ),
    );
  }
}
