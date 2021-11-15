import 'package:car_app/apis/api.dart';
import 'package:car_app/models/driver.dart';
import 'package:car_app/models/user.dart';
import 'package:car_app/screens/root/root.dart';
import 'package:car_app/screens/signup/driver_info_signup.dart';
import 'package:car_app/screens/utils/build_text_form_field.dart';
import 'package:car_app/screens/utils/build_type_select_radio.dart';
import 'package:flutter/material.dart';

class SignupUserScreen extends StatefulWidget {
  @override
  _SignupUserScreenState createState() => _SignupUserScreenState();
}

class _SignupUserScreenState extends State<SignupUserScreen> {
  TextEditingController _nameController = TextEditingController();
  TextEditingController _phoneController = TextEditingController();
  TextEditingController _accountController = TextEditingController();
  TextEditingController _passwordController = TextEditingController();
  TextEditingController _confirmPasswordController = TextEditingController();
  TextEditingController _emailController = TextEditingController();
  TextEditingController _addressController = TextEditingController();
  TextEditingController _ageController = TextEditingController();

  GlobalKey<FormState> formKey = GlobalKey<FormState>();
  var api = Api();
  int _userType = 1;
  late Widget _animatedButton;
  var _signupButton;
  var _nextButton;
  Driver? _driver;

  _goToCabInfoScreen(User user) async {
    _driver = await Navigator.of(context).push(MaterialPageRoute(
        builder: (context) => DriverInfoSignup(
              user: user,
              driver: _driver,
            )));
    print(_driver?.user);
    print(_driver?.cab);
  }

  @override
  void initState() {
    super.initState();
    BuildTextFormField(_nameController, 'Name');
    BuildTextFormField(_phoneController, 'Phone',
        keyboardType: TextInputType.phone);
    BuildTextFormField(_accountController, 'Account name');
    BuildTextFormField(_emailController, 'Email', allowEmpty: true);
    BuildTextFormField(_addressController, 'Address', allowEmpty: true);
    BuildTextFormField(_passwordController, 'Password', obscureText: true);
    BuildTextFormField(_confirmPasswordController, 'Confirm password',
        obscureText: true);
    BuildTextFormField(_ageController, 'Age',
        keyboardType: TextInputType.phone);
    _signupButton = ElevatedButton(
      style: ButtonStyle(
        shape: MaterialStateProperty.all<RoundedRectangleBorder>(
          RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15.0),
          ),
        ),
      ),
      onPressed: () => setState(() {
        if (formKey.currentState!.validate()) _signup();
      }),
      child: Text('Sign up'),
    );
    _nextButton = ElevatedButton.icon(
      style: ButtonStyle(
        shape: MaterialStateProperty.all<RoundedRectangleBorder>(
          RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15.0),
          ),
        ),
      ),
      onPressed: () async {
        if (formKey.currentState!.validate())
          setState(() {
            if (_checkMatchPassword()) {
              User user = new User(
                address: _addressController.text,
                email: _emailController.text,
                name: _nameController.text,
                username: _accountController.text,
                password: _passwordController.text,
                phone: _phoneController.text,
                age: int.parse(_ageController.text),
                user_type: _userType,
              );
              _goToCabInfoScreen(user);
            }
          });
      },
      label: Icon(
        Icons.arrow_forward,
        color: Colors.white,
      ),
      icon: Text('Next'),
    );
    _animatedButton = _signupButton;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _accountController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _emailController.dispose();
    _addressController.dispose();
    _ageController.dispose();
    super.dispose();
  }

  _signup() {
    if (_checkMatchPassword()) {
      User user = new User(
        address: _addressController.text,
        email: _emailController.text,
        name: _nameController.text,
        username: _accountController.text,
        password: _passwordController.text,
        phone: _phoneController.text,
        age: int.parse(_ageController.text),
        user_type: _userType,
      );
      api.signup(user).then((value) => _handleResponse(value));
    }
  }

  _handleResponse(String value) {
    if (value == 'success')
      Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => Root()), (route) => false);
    else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(value),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  _checkMatchPassword() {
    if (_passwordController.text != _confirmPasswordController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Confirm password not match'),
          duration: Duration(seconds: 2),
        ),
      );
      return false;
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    // _cabTypeSelected(val) {
    //   setState(() => _cabType = val);
    //   _switchToDriverInfoButton();
    // }

    _userTypeSelected(val) {
      setState(() {
        _userType = val;
        _animatedButton = _userType == 1 ? _signupButton : _nextButton;
      });
    }

    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          leading: BackButton(
            color: Colors.white,
          ),
          title: Text(
            'Sign up',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w600,
            ),
          ),
          centerTitle: true,
          elevation: 0,
        ),
        resizeToAvoidBottomInset: true,
        backgroundColor: Theme.of(context).primaryColor,
        body: Stack(
          children: [
            Container(
              margin: EdgeInsets.fromLTRB(10, 0, 10, 10),
              padding: EdgeInsets.symmetric(horizontal: 15.0),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(18),
                color: Colors.white,
              ),
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    Form(
                      key: formKey,
                      child: Column(
                        children: [
                          BuildTextFormField(_nameController, 'Name'),
                          BuildTextFormField(
                              _accountController, 'Account name'),
                          BuildTextFormField(_emailController, 'Email',
                              allowEmpty: true),
                          BuildTextFormField(_addressController, 'Address',
                              allowEmpty: true),
                          BuildTextFormField(_passwordController, 'Password',
                              obscureText: true),
                          BuildTextFormField(
                              _confirmPasswordController, 'Confirm password',
                              obscureText: true),
                          Row(
                            children: [
                              Expanded(
                                flex: 3,
                                child: BuildTextFormField(
                                    _phoneController, 'Phone',
                                    keyboardType: TextInputType.phone),
                              ),
                              Expanded(flex: 1, child: Container()),
                              Expanded(
                                flex: 2,
                                child: BuildTextFormField(_ageController, 'Age',
                                    keyboardType: TextInputType.phone),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        TypeSeclectRadio(
                            groupValue: _userType,
                            onChanged: _userTypeSelected,
                            title: 'User',
                            value: 1),
                        TypeSeclectRadio(
                            groupValue: _userType,
                            onChanged: _userTypeSelected,
                            title: 'Driver',
                            value: 2),
                      ],
                    ),
                    AnimatedSwitcher(
                      duration: Duration(milliseconds: 300),
                      transitionBuilder:
                          (Widget child, Animation<double> animation) =>
                              ScaleTransition(
                        child: child,
                        scale: animation,
                      ),
                      child: _animatedButton,
                    )
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
