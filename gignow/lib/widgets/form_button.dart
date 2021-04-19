import 'package:flutter/material.dart';
import 'package:gignow/constants.dart';

class FormButton extends StatelessWidget {
  const FormButton({
    Key key,
    @required this.press,
    @required this.text,
  }) : super(key: key);

  final VoidCallback press;
  final String text;

  Widget build(BuildContext context) {
    return RaisedButton(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(kButtonCircularPadding),
      ),
      onPressed: press,
      padding: EdgeInsets.all(kButtonAllPadding),
      color: kButtonBackgroundColour,
      child: Text(text, style: TextStyle(color: kButtonTextColour)),
    );
  }
}
