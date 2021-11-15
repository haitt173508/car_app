import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

class UserAvatar extends StatefulWidget {
  final String? url;
  final double size;

  const UserAvatar({Key? key, this.url, this.size = 60}) : super(key: key);
  @override
  _UserAvatarState createState() => _UserAvatarState();
}

class _UserAvatarState extends State<UserAvatar> {
  final _avatar = AssetImage('assets/images/non_avatar.jpg');
  @override
  Widget build(BuildContext context) {
    var _avtDecoration = BoxDecoration(
      color: Colors.transparent,
      shape: BoxShape.circle,
      image: widget.url != null
          ? DecorationImage(
              image: CachedNetworkImageProvider(widget.url!),
              fit: BoxFit.cover,
            )
          : DecorationImage(
              image: _avatar,
              fit: BoxFit.cover,
            ),
      border: Border.all(color: Colors.white, width: 3),
    );
    return Container(
      height: widget.size,
      width: widget.size,
      decoration: _avtDecoration,
    );
  }
}
