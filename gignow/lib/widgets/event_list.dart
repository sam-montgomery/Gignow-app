import 'package:flutter/material.dart';
import 'package:gignow/model/event.dart';
import 'package:gignow/model/user.dart';
import 'package:gignow/net/firebase_service.dart';
import 'package:gignow/ui/events/events_screen_consts.dart';
import 'package:gignow/ui/loading.dart';

class EventList extends StatefulWidget {
  @override
  _EventListState createState() => _EventListState();
}

class _EventListState extends State<EventList> {
  @override
  Widget build(BuildContext context) {}
}

class VenuesEventList extends StatefulWidget {
  UserModel user;
  VenuesEventList(this.user);
  @override
  _VenuesEventListState createState() => _VenuesEventListState();
}

class _VenuesEventListState extends State<VenuesEventList> {
  @override
  Widget build(BuildContext context) {
    String uid = widget.user.uid;
    List<Event> events = [];
    return FutureBuilder(
        future: FirebaseService().getAllEventsForVenue(uid),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            events = (snapshot.data.length > 0 ? snapshot.data : events);
            return ListView.builder(
                physics: NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                itemCount: events.length,
                itemBuilder: (context, index) {
                  Event event = events[index];
                  return Padding(
                      padding: const EdgeInsets.all(8.0),
                      child:
                          generateOpenEventTile(context, event, widget.user));
                });
          } else {
            return Loading();
          }
        });
  }
}

class ArtistsEventList extends StatefulWidget {
  UserModel user;
  ArtistsEventList(this.user);
  @override
  _ArtistsEventListState createState() => _ArtistsEventListState();
}

class _ArtistsEventListState extends State<ArtistsEventList> {
  @override
  Widget build(BuildContext context) {
    String uid = widget.user.uid;
    List<Event> events = [];
    return FutureBuilder(
        future: FirebaseService().getOpenEvents(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            events = (snapshot.data.length > 0 ? snapshot.data : events);
            return ListView.builder(
                physics: NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                itemCount: events.length,
                itemBuilder: (context, index) {
                  Event event = events[index];
                  return Padding(
                      padding: const EdgeInsets.all(8.0),
                      child:
                          generateOpenEventTile(context, event, widget.user));
                });
          } else {
            return Loading();
          }
        });
  }
}

class ArtistsUpcomingEventList extends StatefulWidget {
  UserModel user;
  ArtistsUpcomingEventList(this.user);
  @override
  _ArtistsUpcomingEventListState createState() =>
      _ArtistsUpcomingEventListState();
}

class _ArtistsUpcomingEventListState extends State<ArtistsUpcomingEventList> {
  @override
  Widget build(BuildContext context) {
    String uid = widget.user.uid;
    List<Event> events = [];
    return FutureBuilder(
        future: FirebaseService().getUpcomingEventsForArtist(uid),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            events = (snapshot.data.length > 0 ? snapshot.data : events);
            return ListView.builder(
                physics: NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                itemCount: events.length,
                itemBuilder: (context, index) {
                  Event event = events[index];
                  return Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: generateUpcomingEventTile(
                          context, event, widget.user));
                });
          } else {
            return Loading();
          }
        });
  }
}

class VenuesUpcomingEventList extends StatefulWidget {
  UserModel user;

  VenuesUpcomingEventList(this.user);
  @override
  _VenuesUpcomingEventListState createState() =>
      _VenuesUpcomingEventListState();
}

class _VenuesUpcomingEventListState extends State<VenuesUpcomingEventList> {
  @override
  Widget build(BuildContext context) {
    String uid = widget.user.uid;
    List<Event> events = [];
    return FutureBuilder(
        future: FirebaseService().getUpcomingEventsForVenue(uid),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            events = (snapshot.data.length > 0 ? snapshot.data : events);
            return ListView.builder(
                physics: NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                itemCount: events.length,
                itemBuilder: (context, index) {
                  Event event = events[index];
                  return Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: generateUpcomingEventTile(
                          context, event, widget.user));
                });
          } else {
            return Loading();
          }
        });
  }
}
