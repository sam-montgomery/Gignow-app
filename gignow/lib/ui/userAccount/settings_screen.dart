import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:gignow/net/firebase_service.dart';
import 'package:gignow/net/globals.dart';

class SettingsScreen extends StatefulWidget {
  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final FirebaseAuth auth = FirebaseAuth.instance;
  bool offers = Global().currentUserModel.offersOpen;
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
          ),
          Global().currentUserModel.venue
              ? Text("")
              : Card(
                  child: SwitchListTile(
                    title:
                        const Text("Open to receiving offers based on genre: "),
                    value: offers,
                    onChanged: (offer) {
                      setState(() {
                        offers = offer;
                        FirebaseService().updateUserOffers(
                            Global().currentUserModel.uid, offers);
                      });
                    },
                    activeTrackColor: Colors.grey,
                    activeColor: Colors.blue,
                  ),
                )
        ],
      ),
    );
  }
}
