import 'package:cached_network_image/cached_network_image.dart';
import 'package:car_app/apis/api.dart';
import 'package:car_app/models/driver.dart';
import 'package:car_app/models/notification.dart';
import 'package:car_app/models/trip.dart';
import 'package:car_app/models/user.dart';
import 'package:car_app/screens/trip_detail/driver_trip_detail.dart';
import 'package:car_app/screens/utils/order_detail_card.dart';
import 'package:car_app/state/current_trip.dart';
import 'package:car_app/state/current_user.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:provider/provider.dart';

class OrderDetail extends StatefulWidget {
  final Trip trip;
  final Driver? driver;

  const OrderDetail({Key? key, required this.trip, this.driver})
      : super(key: key);
  @override
  _OrderDetailState createState() => _OrderDetailState();
}

class _OrderDetailState extends State<OrderDetail> {
  late TextStyle _style;
  late Widget _emoji;
  double? _rating;
  late Color _color;
  TextEditingController _reviewController = TextEditingController();
  GlobalKey _key = GlobalKey();
  double? _x, _y;
  double? _width, _height;
  bool _isShowRateBar = false;

  @override
  void initState() {
    super.initState();
    _rating = widget.trip.user_rating ?? 5.0;
    _reviewController.text = widget.trip.user_review ?? '';
    if (widget.driver != null)
      WidgetsBinding.instance?.addPostFrameCallback((timeStamp) {
        _getOffset(_key);
      });
  }

  void _getOffset(GlobalKey key) {
    RenderBox box = _key.currentContext!.findRenderObject() as RenderBox;
    Offset position = box.localToGlobal(Offset.zero);
    setState(() {
      _width = box.size.width;
      _height = box.size.height;
      _x = position.dx;
      _y = position.dy;
    });
  }

  Future<Map<String, dynamic>?> _acceptOrder(Trip trip) async {
    Driver driver =
        Provider.of<CurrentUser>(context, listen: false).getCurrentUser;
    var res = await Api.acceptOrder(trip, driver);
    if (res != null && res['message'] == 'success') {
      var currentTrip = Provider.of<CurrentTrip>(context, listen: false);
      currentTrip.setCurrentTrip = trip;
      var notification = NotificationModel(
        title: 'Your trip was accepted',
        body: 'Driver ${driver.user.name} has accepted your trip',
        receiver_type: 2,
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
  Widget build(BuildContext context) {
    var currentUser = Provider.of<CurrentUser>(context);
    var currentTrip = Provider.of<CurrentTrip>(context);
    _getStyle(double? rating) {
      var point = rating?.toString();
      Color color;
      IconData icon;
      switch (point) {
        case '1.0':
          color = Colors.red;
          icon = Icons.sentiment_very_dissatisfied;
          break;
        case '2.0':
          color = Colors.redAccent;
          icon = Icons.sentiment_dissatisfied;
          break;
        case '3.0':
          color = Colors.amber;
          icon = Icons.sentiment_neutral;
          break;
        case '4.0':
          color = Colors.lightGreen;
          icon = Icons.sentiment_satisfied;
          break;
        case '5.0':
          color = Colors.green;
          icon = Icons.sentiment_very_satisfied;
          break;
        default:
          color = Colors.green;
          icon = Icons.sentiment_very_satisfied;
      }
      _style =
          TextStyle(color: color, fontSize: 18, fontWeight: FontWeight.bold);
      _emoji = Icon(
        icon,
        color: color,
      );
      _color = color;
    }

    _getStyle(_rating);

    final appBarSize = AppBar().preferredSize;
    Widget successDialog = AlertDialog(
      content: Text('Accept success'),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(
                builder: (_) => DriverTripDetail(
                    trip: currentTrip.currentTrip,
                    driver: currentUser.getCurrentUser),
              ),
              (route) => route.isFirst,
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

    _onPressedAcceptButton(context) async {
      var res = await _acceptOrder(widget.trip);
      if (res != null) if (res['message'] == 'success')
        showDialog(context: context, builder: (_) => successDialog);
      else
        showDialog(
          context: context,
          builder: (_) => notSuccessDialog(res['message']),
        );
    }

    return Scaffold(
      resizeToAvoidBottomInset: true,
      // backgroundColor: Colors.white70,
      appBar: AppBar(
        elevation: 0,
        title: Text(
          'Your trip',
        ),
      ),
      body: Stack(
        children: [
          Container(
            padding: EdgeInsets.only(top: 10),
            margin: EdgeInsets.symmetric(horizontal: 5),
            child: SingleChildScrollView(
              child: Column(
                children: [
                  if (widget.driver != null)
                    Card(
                      elevation: 3,
                      child: ListTile(
                        leading: Container(
                          height: 50,
                          width: 50,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            image: widget.driver!.user.avatar_url != null
                                ? DecorationImage(
                                    image: CachedNetworkImageProvider(
                                        widget.driver!.user.avatar_url!),
                                  )
                                : DecorationImage(
                                    image: AssetImage(
                                        'assets/images/non_avatar.jpg'),
                                  ),
                          ),
                        ),
                        title: Text(
                          widget.driver!.user.name,
                          style: TextStyle(
                            fontWeight: FontWeight.w500,
                            fontSize: 20,
                          ),
                        ),
                        subtitle: Text(
                          widget.driver!.user.phone,
                          style: TextStyle(
                            fontWeight: FontWeight.w300,
                            fontSize: 15,
                          ),
                        ),
                        trailing: IconButton(
                          onPressed: () {},
                          icon: Icon(
                            Icons.phone,
                            size: 30,
                            color: Colors.indigo[900],
                          ),
                        ),
                      ),
                    ),
                  OrderDetailCard(trip: widget.trip),
                  if (currentUser.getCurrentUser.runtimeType == Driver)
                    ElevatedButton(
                      onPressed: () {
                        _onPressedAcceptButton(context);
                      },
                      child: Text('Accept this trip'),
                    ),
                  if (currentUser.getCurrentUser.runtimeType == User)
                    Card(
                      elevation: 5,
                      shadowColor: _color,
                      child: Column(
                        children: [
                          SizedBox(height: 8),
                          Row(
                            children: [
                              Container(
                                  margin: EdgeInsets.symmetric(horizontal: 8),
                                  child: _emoji),
                              RichText(
                                text: TextSpan(
                                  style: TextStyle(
                                    color: _color,
                                    fontSize: 16,
                                  ),
                                  children: [
                                    TextSpan(text: 'You rate '),
                                    widget.trip.user_rating != null
                                        ? TextSpan(
                                            text: widget.trip.user_rating!
                                                .toString(),
                                            style: _style,
                                          )
                                        : TextSpan(
                                            text: _rating.toString(),
                                            style: _style,
                                          ),
                                    TextSpan(text: ' point'),
                                  ],
                                ),
                              ),
                              Expanded(
                                child: Align(
                                  alignment: Alignment.topRight,
                                  child: GestureDetector(
                                    onTap: () {
                                      setState(() {
                                        _isShowRateBar = !_isShowRateBar;
                                      });
                                      // _getOffset(_key);
                                    },
                                    child: Container(
                                      key: _key,
                                      width: 30,
                                      child: Icon(
                                        Icons.thumb_up_alt_outlined,
                                        color: Theme.of(context).primaryColor,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          Divider(
                            color: _color,
                          ),
                          Container(
                            margin: EdgeInsets.only(top: 0),
                            child: TextField(
                              style: TextStyle(
                                color: Colors.black54,
                                fontSize: 16,
                              ),
                              controller: _reviewController,
                              decoration: InputDecoration(
                                isDense: true,
                                contentPadding: EdgeInsets.fromLTRB(8, 0, 8, 8),
                                hintText:
                                    'What do you feeling about this trip ?',
                                hintStyle: TextStyle(
                                  color: Colors.black45,
                                  fontSize: 12,
                                  fontStyle: FontStyle.italic,
                                ),
                                focusedBorder: UnderlineInputBorder(
                                  borderSide: BorderSide(color: _color),
                                ),
                              ),
                            ),
                          )
                        ],
                      ),
                    ),
                ],
              ),
            ),
          ),
          if (_x != null && _y != null && _isShowRateBar)
            Positioned(
              top: _y! - appBarSize.height - 2 * _height! - 10,
              left: _x! - 40 - 5 * _width!,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      blurRadius: 3,
                      spreadRadius: 3,
                      offset: Offset(0, 2),
                      color: Colors.grey.withOpacity(0.5),
                    ),
                  ],
                  border: Border.all(
                    color: Colors.grey.withOpacity(0.5),
                  ),
                  borderRadius: BorderRadius.circular(20),
                ),
                height: 40,
                // width: 200,
                child: RatingBar.builder(
                  initialRating: 5,
                  itemCount: 5,
                  itemBuilder: (context, index) {
                    switch (index) {
                      case 0:
                        return Icon(
                          Icons.sentiment_very_dissatisfied,
                          color: Colors.red,
                        );
                      case 1:
                        return Icon(
                          Icons.sentiment_dissatisfied,
                          color: Colors.redAccent,
                        );
                      case 2:
                        return Icon(
                          Icons.sentiment_neutral,
                          color: Colors.amber,
                        );
                      case 3:
                        return Icon(
                          Icons.sentiment_satisfied,
                          color: Colors.lightGreen,
                        );
                      case 4:
                        return Icon(
                          Icons.sentiment_very_satisfied,
                          color: Colors.lightGreen,
                        );
                      default:
                        return Icon(
                          Icons.sentiment_very_satisfied,
                          color: Colors.green,
                        );
                    }
                  },
                  onRatingUpdate: (rating) {
                    setState(() {
                      _rating = rating;
                      _isShowRateBar = !_isShowRateBar;
                    });
                  },
                ),
              ),
            ),
        ],
      ),
    );
  }
}
