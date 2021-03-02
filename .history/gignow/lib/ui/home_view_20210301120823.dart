import 'package:flutter/material.dart';
import 'package:gignow/ui/create_profile_view.dart';

class HomeView extends StatefulWidget {
  @override
  _HomeViewState createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  @override
  Widget build(BuildContext context) {
    // return Material(
    //   child: Center(
    //     child: Text("Home View"),
    //   ),
    // );
    return CreateProfileView();
  }
}
