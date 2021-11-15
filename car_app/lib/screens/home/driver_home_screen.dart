import 'package:cached_network_image/cached_network_image.dart';
import 'package:car_app/apis/api.dart';
import 'package:car_app/models/driver.dart';
import 'package:car_app/models/notification.dart';
import 'package:car_app/screens/history_trip_screen/driver_history_trip.dart';
import 'package:car_app/screens/list_orders/valid_orders.dart';
import 'package:car_app/screens/notification_screen/notification_screen.dart';
import 'package:car_app/screens/profile/driver_profile_screen.dart';
import 'package:car_app/screens/root/root.dart';
import 'package:car_app/screens/trip_detail/driver_trip_detail.dart';
import 'package:car_app/services/notification_service.dart';
import 'package:car_app/state/current_trip.dart';
import 'package:car_app/state/current_user.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:provider/provider.dart';

class DriverHomeScreen extends StatefulWidget {
  final Driver driver;

  const DriverHomeScreen({Key? key, required this.driver}) : super(key: key);

  @override
  _DriverHomeScreenState createState() => _DriverHomeScreenState();
}

class _DriverHomeScreenState extends State<DriverHomeScreen> {
  _logout() async {
    CurrentUser currentUser = Provider.of<CurrentUser>(context, listen: false);
    await currentUser.logout();
    Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => Root()), (route) => false);
  }

  _goToWaittingOrders() => Navigator.of(context)
      .push(MaterialPageRoute(builder: (context) => ValidOrders()));

  @override
  void initState() {
    super.initState();
    NotificationService _notificationService =
        Provider.of<NotificationService>(context, listen: false);
    Api.getNotification(widget.driver.user.id!, 2)
        .then((value) => _notificationService.addNotifications(value));
  }

  @override
  Widget build(BuildContext context) {
    CurrentUser _currentUser = Provider.of<CurrentUser>(context);
    CurrentTrip _currentTrip = Provider.of<CurrentTrip>(context);
    _button(String label, IconData icon, Color color, Function() onTap) =>
        GestureDetector(
          onTap: onTap,
          child: Container(
            margin: EdgeInsets.all(5),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.withOpacity(0.2)),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.5),
                  spreadRadius: 2,
                  blurRadius: 2,
                  offset: Offset(0, 3),
                ),
              ],
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  icon,
                  // size: 30,
                  color: color,
                ),
                // SizedBox(height: 5),
                Text(
                  label,
                  style: TextStyle(
                    color: Colors.black38,
                    // fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        );

    final double _avatarRadius = 120;

    final String? _avatarUrl = _currentUser.getCurrentUser.user.avatar_url;
    final _avatar = AssetImage('assets/images/non_avatar.jpg');

    List<NotificationModel> notifications =
        Provider.of<NotificationService>(context).notifications;

    _testSendNotification() async {
      var notification = NotificationModel(
        title: 'Test notification title',
        body: 'Test notification body',
        sender: 13,
        receiver: 13,
        receiver_type: 2,
        category: 0,
      );
      await Api.sendNotification(notification);
    }

    var _appBar = AppBar(
      elevation: 0,
      leading: IconButton(
        onPressed: _logout,
        icon: Icon(Icons.exit_to_app),
      ),
      title: Text(
        widget.driver.user.name,
        style: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w300,
          fontSize: 20,
        ),
      ),
      centerTitle: true,
      actions: [
        Container(
          margin: EdgeInsets.all(8),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.white,
          ),
          child: IconButton(
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) =>
                      NotificationScreen(notifications: notifications),
                ),
              );
            },
            splashRadius: 20,
            icon: Stack(
              children: [
                Center(
                  child: Icon(
                    Icons.notifications_none_rounded,
                    color: Colors.black54,
                  ),
                ),
                // if (notifications.length != 0)
                Positioned(
                  right: 1,
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
                    ),
                    height: 15,
                    width: 15,
                    child: Center(
                      child: Text(
                        notifications
                            .where((element) => element.status == null)
                            .length
                            .toString(),
                        style: TextStyle(fontSize: 12),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );

    var _avtDecoration = BoxDecoration(
      color: Colors.transparent,
      shape: BoxShape.circle,
      image: _avatarUrl != null
          ? DecorationImage(
              image: CachedNetworkImageProvider(_avatarUrl),
              fit: BoxFit.cover,
            )
          : DecorationImage(
              image: _avatar,
              fit: BoxFit.cover,
            ),
      border: Border.all(color: Colors.white, width: 3),
    );

    _goToProfileScreen() => Navigator.of(context).push(MaterialPageRoute(
        builder: (context) => DriverHistoryTrip(driver: widget.driver)));

    _goToHistoryScreen() => Navigator.of(context).push(MaterialPageRoute(
        builder: (context) => DriverProfileScreen(driver: widget.driver)));

    var _profileButton =
        _button('Profile', Icons.person, Colors.red, _goToProfileScreen);
    var _orderButton =
        _button('Trip', Icons.add, Colors.blue, _goToWaittingOrders);
    var _historyButton =
        _button('History', Icons.history, Colors.green, _goToHistoryScreen);
    var _earningButton = _button('Earning', Icons.attach_money_rounded,
        Colors.yellowAccent.shade400, _goToHistoryScreen);
    var _feedbackButton =
        _button('Feedback', Icons.receipt, Colors.purple, () {});
    var _archivesButton =
        _button('Archives', Icons.leaderboard, Colors.orangeAccent, () {});
    List<Widget> _listButton = [
      _profileButton,
      _orderButton,
      // _settingButton,
      // _tripButton,
      _historyButton,
      _earningButton,
      _feedbackButton,
      _archivesButton,
    ];
    return Scaffold(
      appBar: _appBar,
      body: Stack(
        children: [
          Column(
            children: [
              Expanded(
                flex: 1,
                child: Stack(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        color: Theme.of(context).primaryColor,
                        borderRadius: BorderRadius.only(
                          bottomLeft: Radius.circular(50),
                          bottomRight: Radius.circular(50),
                        ),
                      ),
                    ),
                    Positioned(
                      left: 20,
                      right: 20,
                      child: Column(
                        children: [
                          Container(
                            height: _avatarRadius,
                            width: _avatarRadius,
                            decoration: _avtDecoration,
                          ),
                          SizedBox(
                            height: 5,
                          ),
                          RatingBar.builder(
                            initialRating: widget.driver.rating,
                            itemCount: 5,
                            itemSize: 25,
                            itemBuilder: (_, i) => Icon(
                              Icons.star_rate_rounded,
                              color: Colors.amber,
                            ),
                            onRatingUpdate: (value) {},
                          ),
                          SizedBox(
                            height: 5,
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.perm_phone_msg_sharp,
                                color: Colors.white,
                                size: 15,
                              ),
                              SizedBox(width: 5),
                              Text(
                                widget.driver.user.phone,
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w300,
                                  fontSize: 15,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                flex: 2,
                child: Column(
                  children: [
                    Flexible(
                      flex: 3,
                      child: Container(
                        margin:
                            EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                        padding: EdgeInsets.only(top: 10, left: 4, right: 4),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(15),
                          color: Colors.white,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.5),
                              spreadRadius: 2,
                              blurRadius: 2,
                              offset: Offset(0, 2),
                            )
                          ],
                        ),
                        child: GridView.count(
                          crossAxisCount: 2,
                          childAspectRatio: 1.8,
                          crossAxisSpacing: 10,
                          mainAxisSpacing: 15,
                          children: _listButton,
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 60,
                      child: Container(
                        margin:
                            EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _currentTrip.currentTrip != null
                              ? () {
                                  Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (_) => DriverTripDetail(
                                          trip: _currentTrip.currentTrip,
                                          driver: _currentUser.getCurrentUser),
                                    ),
                                  );
                                }
                              : null,
                          child: Text('Go to current trip'),
                        ),
                      ),
                    )
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
