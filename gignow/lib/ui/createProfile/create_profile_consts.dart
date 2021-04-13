import 'package:flutter/material.dart';
import 'package:gignow/constants.dart';
import 'package:multi_select_flutter/multi_select_flutter.dart';

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
