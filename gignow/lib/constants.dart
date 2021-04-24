import 'package:flutter/material.dart';

const kPrimaryColor = Color(0xFF00BF6D);
const kSecondaryColor = Color(0xFFFE9901);
const kHintColor = Colors.black54;
const kErrorColor = Color(0xFFF03738);
const kBackgroundColour = Colors.white;

const kDefaultPadding = 20.0;
const kHalfDefaultPadding = 10.0;

const kLogoRadius = 48.0;

const kFormBorderRadius = 32.0;

const kButtonTextColour = Colors.white;
const kButtonBackgroundColour = Colors.lightBlueAccent;
const kButtonVerticalPadding = 16.0;
const kButtonCircularPadding = 24.0;
const kButtonAllPadding = 12.0;

TextFormField generateFormField(_cont, _hint, _label) {
  return TextFormField(
    controller: _cont,
    keyboardType: TextInputType.emailAddress,
    autofocus: false,
    decoration: InputDecoration(
      hintText: _hint,
      labelText: _label,
      contentPadding: EdgeInsets.fromLTRB(kDefaultPadding, kHalfDefaultPadding,
          kDefaultPadding, kHalfDefaultPadding),
      border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(kFormBorderRadius)),
    ),
  );
}
