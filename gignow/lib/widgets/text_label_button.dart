import 'package:flutter/material.dart';
import 'package:gignow/constants.dart';

class TextLabelButton extends StatelessWidget {
  const TextLabelButton({
    Key key,
    @required this.press,
    @required this.text,
  }) : super(key: key);

  final VoidCallback press;
  final String text;

  Widget build(BuildContext context) {
    return FlatButton(
      child: Text(
        'No Account? Register',
        style: TextStyle(color: kHintColor),
      ),
      onPressed: press,
    );
  }
}
