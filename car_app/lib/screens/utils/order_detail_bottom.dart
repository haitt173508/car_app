import 'package:flutter/material.dart';

class OrderDetailBottom extends StatefulWidget {
  const OrderDetailBottom({
    Key? key,
    this.bottomExtend,
    required this.duration,
    required this.distance,
    required this.height,
    required this.cabIcon,
    required this.address,
  }) : super(key: key);

  final String? duration;
  final String address;
  final String? distance;
  final double height;
  final Icon cabIcon;
  final Widget? bottomExtend;

  @override
  _OrderDetailBottomState createState() => _OrderDetailBottomState();
}

class _OrderDetailBottomState extends State<OrderDetailBottom> {
  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          height: MediaQuery.of(context).size.height / 2.5,
          child: Column(
            children: [
              Flexible(
                flex: 3,
                child: Container(
                  color: Theme.of(context).primaryColor,
                  child: ListTile(
                    title: Text(
                      widget.address,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    subtitle: Text(
                      '',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 15,
                        fontWeight: FontWeight.w300,
                      ),
                    ),
                    trailing: Container(
                      margin: EdgeInsets.only(top: 10),
                      child: Text(
                        widget.duration ?? '20 mins',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              Flexible(
                flex: 5,
                child: Container(
                  margin: EdgeInsets.symmetric(horizontal: 8),
                  child: ListView(
                    children: [
                      TextField(
                        readOnly: true,
                        decoration: InputDecoration(
                          hintText: 'Current location',
                          icon: Icon(
                            Icons.location_on,
                            color: Theme.of(context).primaryColor,
                          ),
                          border: InputBorder.none,
                        ),
                      ),
                      TextField(
                        readOnly: true,
                        decoration: InputDecoration(
                          hintText: widget.distance ?? '30 km',
                          icon: Icon(
                            Icons.follow_the_signs,
                            color: Theme.of(context).primaryColor,
                          ),
                          border: InputBorder.none,
                        ),
                      ),
                      TextField(
                        readOnly: true,
                        decoration: InputDecoration(
                          hintText: '35.000 VND',
                          icon: Icon(
                            Icons.monetization_on_outlined,
                            color: Theme.of(context).primaryColor,
                          ),
                          border: InputBorder.none,
                        ),
                      )
                    ],
                  ),
                ),
              ),
              if (widget.bottomExtend != null) widget.bottomExtend!,
            ],
          ),
        ),
        Positioned(
          top: -widget.height / 2,
          right: 20,
          child: Container(
            width: widget.height,
            height: widget.height,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white,
            ),
            child: Center(
              child: widget.cabIcon,
            ),
          ),
        ),
      ],
    );
  }
}
