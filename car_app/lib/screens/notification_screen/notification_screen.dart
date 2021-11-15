import 'package:car_app/apis/api.dart';
import 'package:car_app/models/notification.dart';
import 'package:car_app/screens/trip_detail/trip_detail_screen.dart';
import 'package:car_app/screens/utils/user_avatar.dart';
import 'package:car_app/services/notification_service.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class NotificationScreen extends StatefulWidget {
  final List<NotificationModel> notifications;

  const NotificationScreen({Key? key, required this.notifications})
      : super(key: key);
  @override
  _NotificationScreenState createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  @override
  Widget build(BuildContext context) {
    _onTap(NotificationModel notification) async {
      var notificationService =
          Provider.of<NotificationService>(context, listen: false);
      if (notification.status == null) {
        setState(() {
          notification.status = 'Seen';
          notification.notice_time = DateTime.now();
        });
        await Api.setSeenNotification(notification);
        notificationService.singleNotification = notification;
      }
      if (notification.category == 2 &&
          notification.trip!.status == 'Processing') {
        Navigator.of(context).push(MaterialPageRoute(
            builder: (_) => TripDetailScreen(trip: notification.trip!)));
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Notifications'),
        centerTitle: true,
      ),
      body: Container(
        child: ListView.builder(
          itemCount: widget.notifications.length,
          itemBuilder: (context, i) => NotificationCard(
            notification: widget.notifications[i],
            onTap: () => _onTap(widget.notifications[i]),
          ),
        ),
      ),
    );
  }
}

class NotificationCard extends StatefulWidget {
  final NotificationModel notification;
  final Function? onTap;
  const NotificationCard({Key? key, required this.notification, this.onTap})
      : super(key: key);

  @override
  _NotificationCardState createState() => _NotificationCardState();
}

class _NotificationCardState extends State<NotificationCard> {
  late Widget _image;
  late Widget _categoryAvatar;

  Widget _getImage(int? category) {
    Widget image;
    switch (category) {
      case 0:
        image = FlutterLogo();
        break;
      default:
        image = FutureBuilder<Map<String, dynamic>?>(
          future: Api.getUserInfo(widget.notification.sender!),
          builder: (context, snapshot) {
            return snapshot.data != null
                ? UserAvatar(url: snapshot.data!['avatar_url'])
                : UserAvatar();
          },
        );
    }
    return image;
  }

  @override
  void initState() {
    super.initState();
    _image = _getImage(widget.notification.category);
  }

  @override
  Widget build(BuildContext context) {
    Widget _getCategoryAvatar(int? category) {
      String char;
      Color color;
      switch (category) {
        case 1:
          char = 'Cancel';
          color = Colors.red;
          break;
        case 2:
          char = 'Accept';
          color = Colors.blue;
          break;
        case 3:
          char = 'Cancel';
          color = Colors.red;
          break;
        case 4:
          char = 'Complete';
          color = Colors.green;
          break;
        default:
          char = 'System';
          color = Colors.white;
      }
      return Container(
        height: 20,
        width: 20,
        child: Center(
          child: Text(
            char,
            style: TextStyle(
              // tSize: 15,
              color: Colors.white,
            ),
          ),
        ),
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
        ),
      );
    }

    _categoryAvatar = _getCategoryAvatar(widget.notification.category);
    return Card(
      elevation: 0,
      color:
          widget.notification.status == null ? Colors.blue[100] : Colors.white,
      child: ListTile(
        onTap: widget.onTap != null ? () => widget.onTap!() : () {},
        contentPadding: EdgeInsets.symmetric(horizontal: 5, vertical: 5),
        leading: Stack(
          children: [
            _image,
            Positioned(
              right: 1,
              bottom: 1,
              child: _categoryAvatar,
            ),
          ],
        ),
        title: Text(widget.notification.title!),
        subtitle: Text(widget.notification.body!),
      ),
    );
  }
}
