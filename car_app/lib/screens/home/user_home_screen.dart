import 'package:cached_network_image/cached_network_image.dart';
import 'package:car_app/apis/api.dart';
import 'package:car_app/models/notification.dart';
import 'package:car_app/models/user.dart';
import 'package:car_app/screens/add_order/add_order.dart';
import 'package:car_app/screens/history_trip_screen/user_history_trip.dart';
import 'package:car_app/screens/list_orders/user_current_orders.dart';
import 'package:car_app/screens/notification_screen/notification_screen.dart';
import 'package:car_app/screens/profile/user_profile_screen.dart';
import 'package:car_app/screens/root/root.dart';
import 'package:car_app/services/notification_service.dart';
import 'package:car_app/state/current_user.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class UserHomeScreen extends StatefulWidget {
  final User user;

  const UserHomeScreen({Key? key, required this.user}) : super(key: key);

  @override
  _UserHomeScreenState createState() => _UserHomeScreenState();
}

class _UserHomeScreenState extends State<UserHomeScreen> {
  _logout() async {
    CurrentUser currentUser = Provider.of<CurrentUser>(context, listen: false);
    await currentUser.logout();
    Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => Root()), (route) => false);
  }

  _goToAddOrder() => Navigator.of(context).push(
        PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) =>
              AddOrderScreen(),
          transitionDuration: Duration(milliseconds: 500),
        ),
      );

  _goToListOrders() => Navigator.of(context)
      .push(MaterialPageRoute(builder: (context) => UserCurrentOrder()));

  int _selectedBannerIndex = 0;

  @override
  void initState() {
    super.initState();
    NotificationService notificationService =
        Provider.of<NotificationService>(context, listen: false);
    Api.getNotification(widget.user.id!, 1)
        .then((value) => notificationService.notifications = value);
  }

  @override
  Widget build(BuildContext context) {
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
            child:
                Column(mainAxisAlignment: MainAxisAlignment.center, children: [
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
            ]),
          ),
        );

    final double _avatarRadius = 120;

    final String? _avatarUrl = widget.user.avatar_url;
    final _avatar = AssetImage('assets/images/non_avatar.jpg');

    NotificationService notificationService =
        Provider.of<NotificationService>(context);
    List<NotificationModel> notifications = notificationService.notifications;

    var _appBar = AppBar(
      // backgroundColor: Colors.transparent,
      elevation: 0,
      leading: IconButton(onPressed: _logout, icon: Icon(Icons.exit_to_app)),
      actions: [
        IconButton(
          onPressed: _goToAddOrder,
          icon: Center(
            child: Hero(
              tag: 'search',
              child: Icon(
                Icons.search,
              ),
            ),
          ),
        ),
        Container(
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
                  top: 3,
                  right: 3,
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

    // double _appBarHeight = _appBar.preferredSize.height;
    // // double _avatarTopPos =
    //     (MediaQuery.of(context).size.height - _appBarHeight) / 3 -
    //         _avatarRadius;

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

    _banner(String banner) => Container(
          height: 130,
          decoration: BoxDecoration(
            border: Border.all(color: Colors.redAccent, width: 0.8),
            borderRadius: BorderRadius.circular(15),
            image: DecorationImage(
              fit: BoxFit.fitWidth,
              image: AssetImage('assets/images/$banner'),
            ),
          ),
        );

    _goToProfileScreen() => Navigator.of(context).push(MaterialPageRoute(
        builder: (context) => UserProfileScreen(user: widget.user)));
    _goToHistoryScreen() => Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => UserHistoryTrip(user: widget.user)));

    var _listBanner = [_banner('banner1.jpg'), _banner('banner2.jpg')];

    var _profileButton =
        _button('Profile', Icons.person, Colors.red, _goToProfileScreen);
    var _settingButton =
        _button('Order', Icons.add, Colors.purple, _goToAddOrder);
    var _tripButton =
        _button('Trip', Icons.local_taxi, Colors.green, _goToListOrders);
    var _historyButton =
        _button('History', Icons.history, Colors.blue, _goToHistoryScreen);

    List<Widget> _listButton = [
      _profileButton,
      _settingButton,
      _tripButton,
      _historyButton
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
                      top: 10,
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
                            height: 10,
                          ),
                          Text(
                            widget.user.name,
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w200,
                              fontSize: 25,
                            ),
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
                    Flexible(
                      flex: 2,
                      child: Stack(
                        children: [
                          Container(
                            margin: EdgeInsets.symmetric(horizontal: 10),
                            child: RotatedBox(
                              quarterTurns: -1,
                              child: ListWheelScrollView(
                                onSelectedItemChanged: (value) => setState(
                                    () => _selectedBannerIndex = value),
                                itemExtent: 300,
                                children: _listBanner
                                    .map((e) =>
                                        RotatedBox(quarterTurns: 1, child: e))
                                    .toList(),
                                // useMagnifier: true,
                                // magnification: 1,
                              ),
                            ),
                          ),
                          Align(
                            alignment: Alignment.bottomCenter,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: List.generate(
                                _listBanner.length,
                                (index) => Container(
                                  margin: EdgeInsets.all(3),
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: _selectedBannerIndex == index
                                        ? Colors.red
                                        : Colors.grey,
                                  ),
                                  height: 6,
                                  width: 6,
                                ),
                              ),
                            ),
                          )
                        ],
                      ),
                    ),
                    SizedBox(
                      height: 20,
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
