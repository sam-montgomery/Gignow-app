import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:gignow/net/firebase_service.dart';
import 'package:gignow/ui/create_profile_view.dart';
import 'package:gignow/ui/home_screen.dart';

class HomeView extends StatefulWidget {
  @override
  _HomeViewState createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  final FirebaseAuth auth = FirebaseAuth.instance;
  FirebaseService firebaseService = FirebaseService();

  @override
  Widget build(BuildContext context) {
    // return Material(
    //   child: Center(
    //     child: Text("Home View"),
    //   ),
    // );
    return Scaffold(
      body: FutureBuilder(
          future: firebaseService.getProfile(auth.currentUser.uid),
          builder: (context, snapshot) {
            return snapshot.hasData
                ? Text(snapshot.data.toString())
                : CircularProgressIndicator();
          }),
    );
  }
}
