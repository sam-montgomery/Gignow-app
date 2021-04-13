import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:gignow/constants.dart';

class Loading extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      color: kButtonTextColour,
      child: Center(
        child: SpinKitChasingDots(
          color: kButtonBackgroundColour,
          size: 50.0,
        ),
      ),
    );
  }
}
