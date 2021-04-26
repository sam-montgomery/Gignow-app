import 'dart:async';
import 'dart:collection';
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
import 'package:gignow/widgets/event_list.dart';

import '../navBar/venue_nav_bar.dart';

class EventsScreen extends StatefulWidget {
  final Map<String, dynamic> profile;
  EventsScreen(this.profile);
  @override
  EventsScreenState createState() => EventsScreenState();
}

int highestInc = 0;

bool openPage = true;

class EventsScreenState extends State<EventsScreen> {
  final FirebaseAuth auth = FirebaseAuth.instance;
  FirebaseService firebaseService = FirebaseService();
  List<Event> events = [];
  List<Event> openEvents = [];
  List<Event> upcomingEvents = [];
  bool updated = false;

  void initState() {
    super.initState();
  }

  //TextEditingController

  Future<void> getVenuesEvents() async {
    events =
        await FirebaseService().getAllEventsForVenue(widget.profile['userUid']);

    for (Event e in events) {
      e.confirmed ? upcomingEvents.add(e) : openEvents.add(e);
    }
    updated = true;
  }

  int returnNextInc() {
    int highestI = 0;
    for (Event e in events) {
      int inc = int.parse(e.eventId.split('-')[1]);
      if (inc > highestI) highestI = inc;
    }
    return highestI + 1;
  }

  Future<void> showAddEventDialog(BuildContext context) async {
    UserModel user = UserModel(
        widget.profile['userUid'].toString(),
        widget.profile['name'].toString(),
        widget.profile['genres'].toString(),
        widget.profile['phoneNumber'].toString(),
        widget.profile['handle'].toString(),
        widget.profile['profile_picture_url'].toString(),
        widget.profile['socials'],
        widget.profile['venue']);
    DateTime eventStart;
    DateTime eventEnd;
    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(10.0))),
            content: Builder(
              builder: (context) {
                return Container(
                  height: MediaQuery.of(context).size.height * 0.1,
                  child: Column(
                    children: [
                      Row(
                        children: [
                          TextButton(
                              onPressed: () {
                                DatePicker.showDateTimePicker(context,
                                    showTitleActions: true,
                                    minTime: DateTime.now(),
                                    maxTime:
                                        DateTime.now().add(Duration(days: 7)),
                                    onChanged: (date) {}, onConfirm: (date) {
                                  print('confirm $date');
                                  eventStart = date;
                                },
                                    currentTime: DateTime.now(),
                                    locale: LocaleType.en);
                              },
                              child: Text('Event Start Time')),
                          TextButton(
                              onPressed: () {
                                DatePicker.showDateTimePicker(context,
                                    showTitleActions: true,
                                    minTime: eventStart,
                                    maxTime:
                                        DateTime.now().add(Duration(days: 7)),
                                    onChanged: (date) {}, onConfirm: (date) {
                                  print('confirm $date');
                                  eventEnd = date;
                                },
                                    currentTime: DateTime.now(),
                                    locale: LocaleType.en);
                              },
                              child: Text('Event End Time'))
                        ],
                      )
                    ],
                  ),
                );
              },
            ),
            actions: <Widget>[
              TextButton(
                child: Text('Create Event'),
                onPressed: () async {
                  Event newEvent = Event(
                      (widget.profile['userUid'] +
                          '-' +
                          ((returnNextInc()).toString())),
                      eventStart,
                      eventEnd,
                      widget.profile['userUid'],
                      user.toJson(),
                      [],
                      "",
                      false);
                  firebaseService.createEvent(newEvent);
                  await getVenuesEvents();
                  Navigator.of(context).pop();
                        Navigator.of(context).push(new MaterialPageRoute(
                            builder: (BuildContext context) {
                          return new VenueNavbar(2);
                        }));
                },
              ),
            ]);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    getVenuesEvents();
    UserModel user = UserModel(
        widget.profile['userUid'].toString(),
        widget.profile['name'].toString(),
        widget.profile['genres'].toString(),
        widget.profile['phoneNumber'].toString(),
        widget.profile['handle'].toString(),
        widget.profile['profile_picture_url'].toString(),
        widget.profile['socials'],
        widget.profile['venue']);
    return Scaffold(
      body: Column(mainAxisAlignment: MainAxisAlignment.start, children: [
        SizedBox(height: 20),
        Container(
          decoration: BoxDecoration(
            color: kButtonBackgroundColour,
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.5),
                spreadRadius: 5,
                blurRadius: 7,
                offset: Offset(0, 3), // changes position of shadow
              ),
            ],
          ),
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
                    child: Center(
                      child: Text("Open Event Applications",
                          //textDirection: TextDirection.rtl,
                          textAlign: TextAlign.center,
                          style: openPage ? activeScreen : inActiveScreen),
                    ),
                  )),
              SizedBox(
                  width: MediaQuery.of(context).size.width * 0.50,
                  child: TextButton(
                    onPressed: () {
                      setState(() {
                        openPage = false;
                      });
                    },
                    child: Center(
                      child: Text("Upcoming Events",
                          style: openPage ? inActiveScreen : activeScreen),
                    ),
                  ))
            ],
          ),
        ),
        openPage
            ? user.venue
                ? Expanded(child: VenuesEventList(user))
                : Expanded(child: ArtistsEventList(user))
            : user.venue
                ? Expanded(child: VenuesUpcomingEventList(user))
                : Expanded(child: ArtistsUpcomingEventList(user))
      ]),
      floatingActionButton: openPage
          ? user.venue
              ? FloatingActionButton(
                  splashColor: kButtonBackgroundColour,
                  child: Icon(Icons.add),
                  onPressed: () async {
                    await showAddEventDialog(context);
                  },
                )
              : null
          : null,
    );
  }
}
