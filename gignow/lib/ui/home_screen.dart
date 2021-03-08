import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:gignow/net/authentication_service.dart';
import 'package:gignow/net/firebase_service.dart';

class HomeScreen extends StatefulWidget {
  final Map<String, dynamic> profile;
  HomeScreen(this.profile);
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final FirebaseAuth auth = FirebaseAuth.instance;
  FirebaseService firebaseService = FirebaseService();

  @override
  Widget build(BuildContext context) {
    String firstName = widget.profile['firstName'];
    String lastName = widget.profile['lastName'];
    return Scaffold(
      appBar: AppBar(
        title: Text("Home"),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 20.0),
            child: GestureDetector(
              onTap: () => auth.signOut(),
              child: Icon(Icons.logout),
            ),
          )
        ],
      ),
      body: Center(
        child: Text("Hi there $firstName $lastName"),
      ),
    );
  }
}
