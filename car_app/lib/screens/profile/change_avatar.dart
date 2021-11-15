import 'dart:io';

import 'package:car_app/apis/api.dart';
import 'package:car_app/models/user.dart';
import 'package:car_app/services/firebase_storage_service.dart';
import 'package:car_app/state/current_user.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:path/path.dart' show basename;

class ChangeAvatarScreen extends StatefulWidget {
  @override
  _ChangeAvatarScreenState createState() => _ChangeAvatarScreenState();
}

class _ChangeAvatarScreenState extends State<ChangeAvatarScreen> {
  File? _file;
  late User _user;
  final storage = FirebaseStorageService();
  final api = Api();

  _selectImageFromGallery(context) async {
    final FilePickerResult? result = await FilePicker.platform.pickFiles(
      allowMultiple: false,
      type: FileType.custom,
      allowedExtensions: ['jpg', 'png'],
    );
    if (result != null) {
      final String path = result.files.single.path!;
      setState(() {
        _file = File(path);
      });
      return showDialog(
        context: context,
        builder: (context) => SimpleDialog(
          children: [
            Column(
              children: [
                Container(
                  child: CircleAvatar(
                    backgroundImage: FileImage(_file!),
                  ),
                ),
                SizedBox(
                  height: 5,
                ),
                Row(
                  children: [
                    IconButton(
                      onPressed: () async {
                        await _uploadFile();
                        Navigator.pop(context);
                      },
                      icon: Icon(Icons.check),
                    ),
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: Icon(Icons.cancel),
                    ),
                  ],
                ),
              ],
            )
          ],
        ),
      );
    }
  }

  _uploadFile() async {
    if (_file == null) return;
    final fileName = basename('avatar-uid${_user.id}.jpg');
    final destination = 'avatar/$fileName';
    UploadTask? task = await storage.uploadFile(_file!, destination);
    setState(() {});
    if (task == null) return;
    final snapshot = await task.whenComplete(() {});
    final String urlDownload = await snapshot.ref.getDownloadURL();
    final userData = _user.toJson();
    userData['avatar_url'] = urlDownload;
    final res = await api.updateUser(userData);
    print(res);
    return res;
  }

  @override
  void initState() {
    super.initState();
    _user = Provider.of<CurrentUser>(context, listen: false).getCurrentUser;
  }

  @override
  Widget build(BuildContext context) {
    _takeImage() {
      return showDialog(
        context: context,
        builder: (context) {
          return SimpleDialog(
            title: Text('Choose an image',
                style: TextStyle(fontWeight: FontWeight.bold)),
            children: [
              // SimpleDialogOption(
              //   child: Text('Capture Image with Camera', style: TextStyle()),
              //   onPressed: _captureImageWithCamera,
              // ),
              SimpleDialogOption(
                child: Text('Select Image from Gallery', style: TextStyle()),
                onPressed: () => _selectImageFromGallery(context),
              ),
              SimpleDialogOption(
                child: Text('Cancel', style: TextStyle()),
                onPressed: () => Navigator.pop(context),
              )
            ],
          );
        },
      );
    }

    User _user = Provider.of<CurrentUser>(context).getCurrentUser;
    final String? _avatarUrl = _user.avatar_url;
    final _avatar = AssetImage('assets/images/non_avatar.jpg');
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        title: Text(
          'Change avatar user',
          style: TextStyle(color: Theme.of(context).primaryColor),
        ),
      ),
      body: Stack(
        children: [
          Column(
            children: [
              Expanded(
                flex: 1,
                child: Container(
                  color: Colors.white,
                ),
              ),
              Expanded(
                flex: 2,
                child: Container(
                  color: Colors.red,
                  child: Text(
                    _file != null ? _file!.path : 'No file picked',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              )
            ],
          ),
          Positioned(
            top: 120,
            left: 30,
            child: Container(
              height: 100,
              width: 100,
              child: Stack(
                children: [
                  Container(
                    height: 100,
                    width: 100,
                    child: _avatarUrl != null
                        ? CircleAvatar(
                            backgroundImage:
                                CachedNetworkImageProvider(_avatarUrl),
                          )
                        : CircleAvatar(
                            backgroundImage: _avatar,
                          ),
                  ),
                  Align(
                    alignment: Alignment.bottomRight,
                    child: IconButton(
                      onPressed: () => _takeImage(),
                      icon: Icon(
                        Icons.camera_alt,
                      ),
                    ),
                  )
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
