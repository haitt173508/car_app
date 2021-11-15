// import 'dart:convert';
// import 'dart:io';

import 'package:car_app/screens/root/root.dart';
import 'package:car_app/screens/signup/signup_screen.dart';
import 'package:car_app/screens/utils/build_text_form_field.dart';
import 'package:car_app/screens/utils/build_type_select_radio.dart';
import 'package:car_app/state/current_user.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
// import 'package:http/http.dart' as http;

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  int userType = 1;
  TextEditingController _accountController = TextEditingController();
  TextEditingController _passwordController = TextEditingController();

  GlobalKey<FormState> formKey = GlobalKey<FormState>();
  var listFormField = [];
  var _currentUser;
  AutovalidateMode? _validateMode;
  bool _onTap = false;

  @override
  void initState() {
    super.initState();
    _currentUser = Provider.of<CurrentUser>(context, listen: false);
  }

  @override
  void dispose() {
    _accountController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  _login(username, password, userType) {
    _currentUser.login(username, password, userType).then((value) => {
          if (value == 'success')
            {
              Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => Root()),
                  (route) => false)
            }
          else
            {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(value),
                  duration: Duration(seconds: 2),
                ),
              ),
            }
        });
  }

  var _showPassword = true;

  _toggleShowPassword() => setState(() => _showPassword = !_showPassword);

  @override
  Widget build(BuildContext context) {
    var _accountTextField = BuildTextFormField(_accountController, 'Account');
    var _visibilityPassword = IconButton(
      onPressed: _toggleShowPassword,
      splashRadius: 5.0,
      icon: _showPassword ? Icon(Icons.visibility) : Icon(Icons.visibility_off),
    );
    var _passwordTextField = BuildTextFormField(
      _passwordController,
      'Password',
      obscureText: _showPassword,
      suffix: _visibilityPassword,
    );

    return SafeArea(
      child: Scaffold(
        resizeToAvoidBottomInset: true,
        backgroundColor: Theme.of(context).primaryColor,
        body: SingleChildScrollView(
          child: Stack(
            children: [
              Container(
                margin: EdgeInsets.symmetric(vertical: 150, horizontal: 20),
                padding: EdgeInsets.symmetric(horizontal: 15),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20.0),
                  boxShadow: [
                    BoxShadow(
                      color: Theme.of(context).hintColor.withOpacity(0.2),
                      offset: Offset(0, 10),
                      blurRadius: 20.0,
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    SizedBox(
                      height: 10.0,
                    ),
                    Text(
                      'Welcome !',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w700,
                        color: Theme.of(context).primaryColor,
                      ),
                    ),
                    Form(
                      autovalidateMode: _validateMode,
                      key: formKey,
                      child: Column(
                        children: [
                          _accountTextField,
                          _passwordTextField,
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              TypeSeclectRadio(
                                  groupValue: userType,
                                  title: 'User',
                                  value: 1,
                                  onChanged: _setSelectedRadio),
                              TypeSeclectRadio(
                                  groupValue: userType,
                                  title: 'Driver',
                                  value: 2,
                                  onChanged: _setSelectedRadio),
                            ],
                          ),
                        ],
                      ),
                    ),
                    Container(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ButtonStyle(
                          shape:
                              MaterialStateProperty.all<RoundedRectangleBorder>(
                            RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15.0),
                            ),
                          ),
                        ),
                        onPressed: () => setState(() {
                          _onTap = true;
                          if (formKey.currentState!.validate() &&
                              _onTap == true) {
                            _login(_accountController.text,
                                _passwordController.text, userType);
                            _onTap = false;
                          } else
                            _validateMode = AutovalidateMode.onUserInteraction;
                        }),
                        child: const Text('Log in'),
                      ),
                    ),
                    Container(
                      margin: EdgeInsets.symmetric(vertical: 10),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text(
                            "Don't have an account?",
                            style: TextStyle(fontWeight: FontWeight.w500),
                          ),
                          const SizedBox(width: 5.0),
                          InkWell(
                            child: Text(
                              'Register',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Theme.of(context).primaryColor,
                              ),
                            ),
                            onTap: () => Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) => SignupUserScreen(),
                              ),
                            ),
                          )
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  _setSelectedRadio(val) => setState(() => userType = val);
}
