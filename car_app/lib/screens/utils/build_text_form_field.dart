import 'package:flutter/material.dart';

class BuildTextFormField extends StatelessWidget {
  final _controller;
  final _hintText;
  final bool obscureText;
  final TextInputType keyboardType;
  final bool allowEmpty;
  final Widget? suffix;
  final enable;

  BuildTextFormField(
    this._controller,
    this._hintText, {
    this.obscureText = false,
    this.keyboardType = TextInputType.text,
    this.allowEmpty = false,
    this.suffix,
    this.enable = true,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      child: TextFormField(
        validator: (String? value) {
          if (!allowEmpty) {
            if (value!.isEmpty) return 'Fill this field';
          }
          return null;
        },
        keyboardType: keyboardType,
        obscureText: obscureText,
        controller: _controller,
        decoration: InputDecoration(
          labelText: _hintText,
          labelStyle: TextStyle(fontWeight: FontWeight.bold),
          // hintText: _hintText,
          suffixIcon: suffix,
        ),
        enabled: enable,
      ),
    );
  }
}
