import 'package:flutter/material.dart';

class TypeSeclectRadio extends StatefulWidget {
  final Object groupValue;
  final String title;
  final Object value;
  final Function(Object? value) onChanged;

  const TypeSeclectRadio(
      {Key? key,
      required this.groupValue,
      required this.title,
      required this.value,
      required this.onChanged})
      : super(key: key);

  @override
  _TypeSeclectRadioState createState() => _TypeSeclectRadioState();
}

class _TypeSeclectRadioState extends State<TypeSeclectRadio> {
  @override
  Widget build(BuildContext context) {
    return Container(
      child: Row(
      children: [
        Text(widget.title),
        SizedBox(
          width: 8.0,
        ),
        Radio(
          activeColor: Theme.of(context).accentColor,
          value: widget.value,
          groupValue: widget.groupValue,
          onChanged: (Object? val) => widget.onChanged(val),
        ),
      ],
    )
    );
  }
}
