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
import 'package:gignow/ui/events/new_events_screen.dart';
import 'package:gignow/ui/loading.dart';
import 'package:gignow/widgets/event_list.dart';
import 'package:contained_tab_bar_view/contained_tab_bar_view.dart';

import '../../model/user.dart';
import '../navBar/venue_nav_bar.dart';

class EventsScreen extends StatefulWidget {
  final UserModel profile;
  EventsScreen(this.profile);
  @override
  EventsScreenState createState() => EventsScreenState();
}

int highestInc = 0;

bool openPage = true;

class EventsScreenState extends State<EventsScreen> {
  final FirebaseAuth auth = FirebaseAuth.instance;
  List<Event> events = [];
  List<Event> openEvents = [];
  List<Event> upcomingEvents = [];
  bool updated = false;

  void initState() {
    super.initState();
  }

  //TextEditingController

  int returnNextInc() {
    int highestI = 0;
    for (Event e in events) {
      int inc = int.parse(e.eventId.split('-')[1]);
      if (inc > highestI) highestI = inc;
    }
    return highestI + 1;
  }

  Future<void> getVenuesEvents() async {
    events = await FirebaseService().getAllEventsForVenue(widget.profile.uid);

    for (Event e in events) {
      e.confirmed ? upcomingEvents.add(e) : openEvents.add(e);
    }
    updated = true;
  }

  /* Future<void> showAddEventDialog(BuildContext context) async {
    // UserModel user = UserModel(
    //     widget.profile['userUid'].toString(),
    //     widget.profile['name'].toString(),
    //     widget.profile['genres'].toString(),
    //     widget.profile['phoneNumber'].toString(),
    //     widget.profile['handle'].toString(),
    //     widget.profile['profile_picture_url'].toString(),
    //     widget.profile['socials'],
    //     widget.profile['venue']);
    UserModel user = widget.profile;
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
                  padding: const EdgeInsets.all(0),
                  height: MediaQuery.of(context).size.height * 0.95,
                  width: MediaQuery.of(context).size.width * 0.85,
                  alignment: new AlignmentDirectional(
                      MediaQuery.of(context).size.width * 0.5,
                      MediaQuery.of(context).size.height),
                  child: Column(
                    children: [
                      SizedBox(
                        child: Image(
                            image:
                                NetworkImage(widget.profile.profilePictureUrl)),
                        height: MediaQuery.of(context).size.height,
                        width: MediaQuery.of(context).size.width,
                      )
                      /*Row(
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
                      )*/
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
                      (widget.profile.uid +
                          '-' +
                          ((returnNextInc()).toString())),
                      eventStart,
                      eventEnd,
                      widget.profile.uid,
                      user.toJson(),
                      [],
                      "",
                      false);
                  firebaseService.createEvent(newEvent);
                  await getVenuesEvents();
                  Navigator.of(context).pop();
                  Navigator.of(context).push(
                      new MaterialPageRoute(builder: (BuildContext context) {
                    return new VenueNavbar(2);
                  }));
                },
              ),
            ]);
      },
    );
  }
 */
  @override
  Widget build(BuildContext context) {
    getVenuesEvents();
    int nextInc = returnNextInc();
    UserModel user = widget.profile;
    return Scaffold(
      body: Column(mainAxisAlignment: MainAxisAlignment.start, children: [
        SizedBox(height: 45),
        Padding(
            padding: const EdgeInsets.all(8.0),
            child: Container(
              height: (MediaQuery.of(context).size.height * 0.82),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                  color: kButtonBackgroundColour,
                  borderRadius: BorderRadius.all(Radius.circular(10))),
              child: ContainedTabBarView(
                tabs: [
                  Text(
                    "Open Events",
                    style: inActiveScreen,
                  ),
                  Text(
                    "Upcoming Events",
                    style: inActiveScreen,
                  )
                ],
                views: [
                  Container(
                      color: kButtonBackgroundColour,
                      child: user.venue
                          ? VenuesEventList(user)
                          : ArtistsEventList(user)),
                  Container(
                      color: kButtonBackgroundColour,
                      child: user.venue
                          ? VenuesUpcomingEventList(user)
                          : ArtistsUpcomingEventList(user)),
                ],
              ),
            )),
        // openPage
        //     ? user.venue
        //         ? Expanded(child: VenuesEventList(user))
        //         : Expanded(child: ArtistsEventList(user))
        //     : user.venue
        //         ? Expanded(child: VenuesUpcomingEventList(user))
        //         : Expanded(child: ArtistsUpcomingEventList(user))
      ]),
      floatingActionButton: openPage
          ? user.venue
              ? FloatingActionButton(
                  splashColor: kButtonBackgroundColour,
                  child: Icon(Icons.add),
                  onPressed: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) =>
                                NewEventScreen(widget.profile)));
                  },
                )
              : null
          : null,
    );
  }
}
