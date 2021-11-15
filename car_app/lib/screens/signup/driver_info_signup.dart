import 'package:car_app/apis/api.dart';
import 'package:car_app/models/cab.dart';
import 'package:car_app/models/driver.dart';
import 'package:car_app/models/user.dart';
import 'package:car_app/screens/utils/build_text_form_field.dart';
import 'package:car_app/screens/utils/build_type_select_radio.dart';
import 'package:flutter/material.dart';

class DriverInfoSignup extends StatefulWidget {
  final User user;
  final Driver? driver;

  const DriverInfoSignup({Key? key, required this.user, this.driver})
      : super(key: key);
  @override
  _DriverInfoSignupState createState() => _DriverInfoSignupState();
}

class _DriverInfoSignupState extends State<DriverInfoSignup> {
  TextEditingController _licenseController = TextEditingController();
  TextEditingController _regNoController = TextEditingController();
  TextEditingController _brandController = TextEditingController();
  TextEditingController _modelController = TextEditingController();
  GlobalKey<FormState> formKey = GlobalKey<FormState>();
  String _cabType = 'Motorbike';
  Api api = Api();

  _signup() {
    Cab? cab = new Cab(
      brand: _brandController.text,
      model: _modelController.text,
      reg_no: _regNoController.text,
      cab_type: _cabType,
    );
    Driver driver = new Driver(
      cab: cab,
      license_driver: _licenseController.text,
      user: widget.user,
    );
    api.signup(driver).then((value) => _handleResponse(value));
  }

  _handleResponse(String value) {
    if (value == 'success')
      Navigator.of(context).pop();
    else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(value),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  @override
  void initState() {
    super.initState();
    if (widget.driver != null) {
      _licenseController..text = widget.driver!.license_driver;
      _regNoController..text = widget.driver!.cab.reg_no;
      _brandController..text = widget.driver!.cab.brand;
      _modelController..text = widget.driver!.cab.model;
    }
  }

  @override
  void dispose() {
    _licenseController.dispose();
    _regNoController.dispose();
    _brandController.dispose();
    _modelController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    _cabTypeSelected(val) => setState(() => _cabType = val);

    _routeBack() {
      Cab cab = new Cab(
        brand: _brandController.text,
        model: _modelController.text,
        reg_no: _regNoController.text,
        cab_type: _cabType,
      );
      Driver driver = new Driver(
        cab: cab,
        license_driver: _licenseController.text,
        user: widget.user,
      );
      Navigator.of(context).pop(driver);
    }

    return SafeArea(
      child: Scaffold(
        resizeToAvoidBottomInset: true,
        backgroundColor: Theme.of(context).primaryColor,
        body: Stack(
          children: [
            BackButton(
              onPressed: () => _routeBack(),
              color: Colors.white,
            ),
            Container(
              margin: EdgeInsets.fromLTRB(10, 50, 10, 10),
              padding: EdgeInsets.symmetric(horizontal: 15.0),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(18),
                color: Colors.white,
              ),
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    SizedBox(
                      height: 10,
                    ),
                    Text(
                      'Cab Info',
                      style: TextStyle(
                        color: Theme.of(context).primaryColor,
                        fontSize: 24,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Form(
                      key: formKey,
                      child: Column(
                        children: [
                          BuildTextFormField(_regNoController, 'Reg no'),
                          BuildTextFormField(_brandController, 'Brand'),
                          BuildTextFormField(_modelController, 'Model'),
                          BuildTextFormField(
                              _licenseController, 'License driver'),
                        ],
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        TypeSeclectRadio(
                            groupValue: _cabType,
                            onChanged: _cabTypeSelected,
                            title: 'Motorbike',
                            value: 'Motorbike'),
                        TypeSeclectRadio(
                            groupValue: _cabType,
                            onChanged: _cabTypeSelected,
                            title: 'Car',
                            value: 'Car'),
                      ],
                    ),
                    ElevatedButton(
                      style: ButtonStyle(
                        shape:
                            MaterialStateProperty.all<RoundedRectangleBorder>(
                          RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15.0),
                          ),
                        ),
                      ),
                      onPressed: () => setState(() {
                        if (formKey.currentState!.validate()) _signup();
                      }),
                      child: Text('Sign up'),
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
