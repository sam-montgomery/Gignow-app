import 'package:flutter/material.dart';
import 'package:gignow/model/user.dart';
import 'package:gignow/model/event.dart';
import 'package:gignow/ui/events/events_screen_consts.dart';
import 'package:gignow/net/firebase_service.dart';
import 'package:gignow/ui/loading.dart';
import 'package:intl/intl.dart';
import 'package:gignow/widgets/event_widget.dart';

class EventWidget extends StatefulWidget {
  Event event;
  EventWidget(this.event);
  @override
  _EventWidgetState createState() => _EventWidgetState(event);
}

class _EventWidgetState extends State<EventWidget> {
  Event event;
  _EventWidgetState(this.event);

  FirebaseService firebaseService = FirebaseService();

  @override
  Widget build(BuildContext context) {
    return Container(
        child: FutureBuilder<Event>(
      future: firebaseService.getEvent(event.eventId),
      builder: (BuildContext context, AsyncSnapshot<Event> snapshot) {
        if (snapshot.hasData) {
          Event event = snapshot.data;
          return generateOpenEventTile(context, event);
        } else {
          return Loading();
        }
      },
    ));
  }
}
