import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:car_app/apis/api.dart';
import 'package:car_app/models/user.dart';
import 'package:car_app/services/firebase_storage_service.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart' show basename;

class UserProfileScreen extends StatefulWidget {
  final User user;

  const UserProfileScreen({Key? key, required this.user}) : super(key: key);
  @override
  _UserProfileScreenState createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends State<UserProfileScreen> {
  TextEditingController _nameController = TextEditingController();
  TextEditingController _phoneController = TextEditingController();
  TextEditingController _accountController = TextEditingController();
  TextEditingController _passwordController = TextEditingController();
  TextEditingController _emailController = TextEditingController();
  TextEditingController _addressController = TextEditingController();
  TextEditingController _ageController = TextEditingController();
  TextEditingController _confirmPasswordController = TextEditingController();
  late String _name = widget.user.name;
  final storage = FirebaseStorageService();
  File? _file;
  final api = Api();

  @override
  void initState() {
    super.initState();
    _nameController.text = widget.user.name;
    _phoneController.text = widget.user.phone;
    _accountController.text = widget.user.username;
    _emailController.text = widget.user.email ?? '';
    _addressController.text = widget.user.address ?? '';
    _ageController.text = widget.user.age.toString();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _accountController.dispose();
    _passwordController.dispose();
    _emailController.dispose();
    _addressController.dispose();
    _ageController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Widget _field(String label, controller,
      {keyboardType = null,
      obscureText = false,
      enable = true,
      onChanged = null}) {
    var trailing = ' ' * (8 - label.length);
    return Container(
      margin: EdgeInsets.only(bottom: 8),
      height: 30,
      child: TextField(
        onChanged: (value) => onChanged != null ? onChanged(value) : null,
        keyboardType: keyboardType,
        obscureText: obscureText,
        controller: controller,
        decoration: InputDecoration(
          icon: Text(
            '$label$trailing: ',
            style: TextStyle(
              // backgroundColor: Colors.green,
              fontWeight: FontWeight.bold,
              color: Colors.black54,
              fontSize: 15,
            ),
          ),
          // fillColor: Colors.red[100],
          filled: true,
          border: OutlineInputBorder(
            borderSide: BorderSide.none,
            borderRadius: BorderRadius.circular(12),
          ),
          errorBorder: InputBorder.none,
          disabledBorder: InputBorder.none,
          contentPadding: EdgeInsets.fromLTRB(8, 2, 8, 2),
        ),
      ),
    );
  }

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
    final fileName = basename('avatar-uid${widget.user.id}.jpg');
    final destination = 'avatar/$fileName';
    UploadTask? task = await storage.uploadFile(_file!, destination);
    setState(() {});
    if (task == null) return;
    final snapshot = await task.whenComplete(() {});
    final String urlDownload = await snapshot.ref.getDownloadURL();
    final userData = widget.user.toJson();
    userData['avatar_url'] = urlDownload;
    final res = await api.updateUser(userData);
    print(res);
    return res;
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

    _onChanged(value) => setState(() => _name = value);
    return Scaffold(
      backgroundColor: Theme.of(context).primaryColor,
      // resizeToAvoidBottomInset: true,
      appBar: AppBar(
        leading: BackButton(),
        actions: [IconButton(onPressed: () {}, icon: Icon(Icons.check))],
        elevation: 0,
      ),
      body: Container(
        // padding: EdgeInsets.symmetric(vertical: 5, horizontal: 5),
        child: Column(
          children: [
            Align(
              alignment: Alignment.topCenter,
              child: Container(
                child: Align(
                  alignment: Alignment.bottomRight,
                  child: IconButton(
                    onPressed: () => _takeImage(),
                    icon: Icon(
                      Icons.camera_alt,
                      color: Colors.white,
                    ),
                  ),
                ),
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  border: Border.all(
                    width: 3,
                    color: Colors.white,
                  ),
                  shape: BoxShape.circle,
                  image: widget.user.avatar_url != null
                      ? DecorationImage(
                          image: CachedNetworkImageProvider(
                              widget.user.avatar_url!),
                        )
                      : DecorationImage(
                          image: AssetImage('assets/images/non_avatar.jpg'),
                        ),
                ),
              ),
            ),
            SizedBox(height: 5),
            Text(
              _name,
              style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w200,
                  fontSize: 30),
            ),
            SizedBox(height: 10),
            Expanded(
              child: Container(
                padding: EdgeInsets.symmetric(vertical: 30, horizontal: 20),
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(30),
                      topRight: Radius.circular(30),
                    ),
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.5),
                        spreadRadius: 5,
                        blurRadius: 5,
                        offset: Offset(0, 7),
                      ),
                    ]),
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      _field('Name', _nameController, onChanged: _onChanged),
                      _field('Phone', _phoneController,
                          keyboardType: TextInputType.phone),
                      _field('Account', _accountController, enable: false),
                      _field(
                        'Email',
                        _emailController,
                      ),
                      _field(
                        'Address',
                        _addressController,
                      ),
                      _field('Age', _ageController,
                          keyboardType: TextInputType.phone),
                      _field('Reset password', _passwordController,
                          obscureText: true),
                      _field('Confirm password', _confirmPasswordController,
                          obscureText: true),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
