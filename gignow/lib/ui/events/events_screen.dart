import 'dart:async';
import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:gignow/constants.dart';
import 'package:gignow/model/user.dart';
import 'package:gignow/model/event.dart';
import 'package:gignow/net/authentication_service.dart';
import 'package:gignow/net/firebase_service.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:gignow/ui/events/events_screen_consts.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';
import 'package:gignow/ui/loading.dart';
import 'package:gignow/widgets/event_widget.dart';

class EventsScreen extends StatefulWidget {
  final Map<String, dynamic> profile;
  EventsScreen(this.profile);
  @override
  EventsScreenState createState() => EventsScreenState();
}

List<Event> events = [];

bool openPage = true;

Event testEvent = Event(
    "kg1WsXDKqPatkkCh2ZMKPrbhwIc2-1",
    DateTime.parse("2021-07-13 19:00:00"),
    DateTime.parse("2021-07-13 22:00:00"),
    "vuid");

class EventsScreenState extends State<EventsScreen> {
  final FirebaseAuth auth = FirebaseAuth.instance;
  FirebaseService firebaseService = FirebaseService();

  Future<void> showAddEventDialog(BuildContext context) async {
    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
            content: ListView(
              children: [
                Column(
                  children: [],
                )
              ],
            ),
            actions: <Widget>[
              TextButton(
                child: Text('Create event'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ]);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(mainAxisAlignment: MainAxisAlignment.start, children: [
        SizedBox(height: 20),
        Center(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                  width: MediaQuery.of(context).size.width * 0.50,
                  child: TextButton(
                      onPressed: () {
                        setState(() {
                          openPage = true;
                        });
                      },
                      child: Text("Open Event Applications",
                          textDirection: TextDirection.rtl,
                          style: openPage ? activeScreen : inActiveScreen))),
              SizedBox(
                  width: MediaQuery.of(context).size.width * 0.50,
                  child: TextButton(
                      onPressed: () {
                        setState(() {
                          openPage = false;
                        });
                      },
                      child: Text("Upcoming Events",
                          style: openPage ? inActiveScreen : activeScreen)))
            ],
          ),
        ),
        openPage
            ? Expanded(
                child: ListView(
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: EventWidget(testEvent),
                    ),
                  ],
                ),
              )
            : Expanded(
                child: ListView(
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      //: generateOpenEventTile(context, testEvent),
                    ),
                  ],
                ),
              )
      ]),
      floatingActionButton: openPage
          ? FloatingActionButton(
              splashColor: kButtonBackgroundColour,
              child: Icon(Icons.add),
              onPressed: () async {
                //await showAddEventDialog(context);
              },
            )
          : null,
    );
  }
}
