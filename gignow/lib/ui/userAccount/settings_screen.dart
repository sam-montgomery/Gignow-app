import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class SettingsScreen extends StatefulWidget {
  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final FirebaseAuth auth = FirebaseAuth.instance;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: IconButton(
        icon: Icon(Icons.close),
        onPressed: () {
          Navigator.pop(context);
        },
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.startTop,
      body: ListView(
        children: [
          SizedBox(height: 24.0),
          Center(
              child: Text(
            "Settings",
            style: TextStyle(fontSize: 24),
          )),
          SizedBox(height: 24.0),
          Card(
            child: ListTile(
              title: Text("Change Email or Password"),
            ),
          ),
          Card(
            child: ListTile(
                title: Text("Logout"),
                onTap: () {
                  auth.signOut();
                  Navigator.pushNamed(context, '/');
                }),
          )
        ],
      ),
    );
  }
}
