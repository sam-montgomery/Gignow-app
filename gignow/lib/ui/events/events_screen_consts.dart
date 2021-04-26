import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:gignow/constants.dart';
import 'package:gignow/model/user.dart';
import 'package:gignow/net/firebase_service.dart';
import 'package:gignow/ui/events/events_screen.dart';
import 'package:gignow/ui/loading.dart';
import 'package:gignow/ui/navBar/artist_nav_bar.dart';
import 'package:gignow/ui/navBar/venue_nav_bar.dart';
import 'package:intl/intl.dart';
import 'package:gignow/model/event.dart';
import 'dart:convert';

final List<String> moty = [
  'JAN',
  'FEB',
  'MAR',
  'APR',
  'MAY',
  'JUN',
  'JUL',
  'AUG',
  'SEP',
  'OCT',
  'NOV',
  'DEC'
];

final TextStyle activeScreen = TextStyle(
    fontSize: 18, decoration: TextDecoration.underline, color: Colors.white);

final TextStyle inActiveScreen = TextStyle(fontSize: 18, color: Colors.white);

final TextStyle monthStyle =
    TextStyle(fontSize: 16, color: Colors.white, fontWeight: FontWeight.bold);
final TextStyle dateStyle =
    TextStyle(fontSize: 30, color: Colors.white, fontWeight: FontWeight.bold);
final TextStyle dayStyle =
    TextStyle(fontSize: 22, color: Colors.white, fontWeight: FontWeight.bold);
final TextStyle timeStyle = TextStyle(fontSize: 16, color: Colors.white);

final TextStyle applicantGenreStyle = TextStyle(fontSize: 14);
final TextStyle applicantNameStyle = TextStyle(fontSize: 16);

Future<void> deleteEvent(Event event) async {
  FirebaseService().deleteEvent(event);
}

Future<void> applyForEvent(Event event, String userUid) async {
  FirebaseService().applyForEvent(event, userUid);
}

Future<void> confirmEvent(
  Event event,
) async {
  FirebaseService().confirmEvent(event);
}

Container generateApplicantTile(
    BuildContext context, Event event, UserModel applicant) {
  String name = applicant.name;
  String genres = applicant.genres.toString();
  return Container(
    height: MediaQuery.of(context).size.height * 0.1,
    width: MediaQuery.of(context).size.height * 0.25,
    decoration: BoxDecoration(
        color: kButtonBackgroundColour,
        borderRadius: BorderRadius.all(Radius.circular(15))),
    child: Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              CircleAvatar(
                backgroundColor: Colors.white70,
                minRadius: 30.0,
                child: CircleAvatar(
                  radius: 30.0,
                  backgroundImage: NetworkImage(applicant.profilePictureUrl),
                ),
              ),
              SizedBox(height: 15, width: 15),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('$name', style: applicantNameStyle),
                  Text('$genres', style: applicantGenreStyle)
                ],
              ),
              SizedBox(height: 15, width: 10),
              Expanded(
                  child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  PopupMenuButton(
                    onSelected: (value) {
                      switch (value) {
                        case 1:
                          FirebaseService()
                              .acceptApplicant(event, applicant.uid);
                          break;
                        case 2:
                          FirebaseService()
                              .rejectApplicant(event, applicant.uid);
                          break;
                      }
                      Navigator.of(context).pop();
                    },
                    child: Icon(Icons.more_vert),
                    itemBuilder: (context) => [
                      PopupMenuItem(
                          value: 1,
                          child: Row(
                            children: <Widget>[
                              Icon(Icons.check),
                              Text('Accept')
                            ],
                          )),
                      PopupMenuItem(
                          value: 2,
                          child: Row(
                            children: <Widget>[
                              Icon(Icons.do_disturb_alt_outlined),
                              Text('Reject')
                            ],
                          ))
                    ],
                  )
                ],
              )),
            ],
          ),
        ),
      ],
    ),
  );
}

Future<void> showApplicantsDialog(BuildContext context, Event event) async {
  await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          content: FutureBuilder(
            future: FirebaseService().getEventApplicants(event.eventId),
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                List<UserModel> applicants = snapshot.data;
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    applicants.length != 0
                        ? Container(
                            height: MediaQuery.of(context).size.height *
                                (0.12 * applicants.length),
                            width: MediaQuery.of(context).size.width * 0.9,
                            child: ListView.builder(
                                shrinkWrap: true,
                                itemCount: applicants.length,
                                itemBuilder: (context, index) {
                                  UserModel applicant = applicants[index];
                                  return Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: generateApplicantTile(
                                        context, event, applicant),
                                  );
                                }))
                        : Container(
                            height: MediaQuery.of(context).size.height * (0.12),
                            width: MediaQuery.of(context).size.width * 0.9,
                            child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [Text("No applicants yet!")]))
                  ],
                );
              } else {
                return Loading();
              }
            },
          ),
          actions: <Widget>[
            TextButton(
                child: Text('Done'),
                onPressed: () {
                  Navigator.of(context).pop();
                })
          ],
        );
      });
}

FutureBuilder generateUpcomingEventTile(
    BuildContext context, Event event, UserModel user) {
  bool venue = user.venue;
  String startingTime = event.eventStartTime.hour.toString() +
      ':' +
      (event.eventStartTime.minute == 0
          ? "00"
          : event.eventStartTime.minute.toString());
  String finishingTime = event.eventFinishTime.hour.toString() +
      ':' +
      (event.eventFinishTime.minute == 0
          ? "00"
          : event.eventFinishTime.minute.toString());

  String date = DateFormat('EEEE').format(event.eventStartTime).toString() +
      ' ' +
      event.eventStartTime.day.toString() +
      ' ' +
      moty[event.eventStartTime.month - 1] +
      ' :';

  return FutureBuilder(
      future: FirebaseService().getSelectedApplicant(event.eventId),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          UserModel applicant = snapshot.data;
          return Container(
            height: MediaQuery.of(context).size.height * 0.1,
            width: MediaQuery.of(context).size.height * 0.1,
            decoration: BoxDecoration(
                color: kButtonBackgroundColour,
                borderRadius: BorderRadius.all(Radius.circular(15))),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Container(
                      alignment: Alignment.center,
                      child: CircleAvatar(
                        backgroundColor: Colors.white70,
                        minRadius: 30.0,
                        child: CircleAvatar(
                          radius: 30.0,
                          backgroundImage:
                              NetworkImage(applicant.profilePictureUrl),
                        ),
                      ),
                      height: MediaQuery.of(context).size.height * 0.08,
                      width: MediaQuery.of(context).size.height * 0.08,
                    )),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        applicant.name,
                        textAlign: TextAlign.center,
                        style: dayStyle,
                      ),
                      Text(
                        "$date $startingTime - $finishingTime",
                        textAlign: TextAlign.left,
                        style: timeStyle,
                      )
                    ],
                  ),
                ),
                SizedBox(
                  width: MediaQuery.of(context).size.width * 0.05,
                ),
                venue
                    ? Expanded(
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            PopupMenuButton(
                              onSelected: (value) {
                                deleteEvent(event);
                              },
                              child: Icon(Icons.more_vert),
                              itemBuilder: (context) => [
                                PopupMenuItem(
                                    value: 1,
                                    child: Row(
                                      children: <Widget>[
                                        Icon(Icons.delete),
                                        Text('Delete')
                                      ],
                                    )),
                              ],
                            ),
                            SizedBox(
                              width: 10,
                            )
                          ],
                        ),
                      )
                    : SizedBox(
                        width: 10,
                      )
              ],
            ),
          );
        } else {
          return Loading();
        }
      });
}

Container generateOpenEventTile(
    BuildContext context, Event event, UserModel um) {
  bool venue = um.venue;
  bool applied = false;
  bool accepted = false;
  if (event.applicants.contains(um.uid) || event.acceptedUid.isNotEmpty) {
    applied = true;
  }
  if (event.acceptedUid == um.uid) {
    accepted = true;
  }
  String startingTime = event.eventStartTime.hour.toString() +
      ':' +
      (event.eventStartTime.minute == 0
          ? "00"
          : event.eventStartTime.minute.toString());
  String finishingTime = event.eventFinishTime.hour.toString() +
      ':' +
      (event.eventFinishTime.minute == 0
          ? "00"
          : event.eventFinishTime.minute.toString());
  return Container(
    height: MediaQuery.of(context).size.height * 0.1,
    width: MediaQuery.of(context).size.height * 0.1,
    decoration: BoxDecoration(
        color: kButtonBackgroundColour,
        borderRadius: BorderRadius.all(Radius.circular(15))),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Padding(
            padding: const EdgeInsets.all(8.0),
            child: Container(
              alignment: Alignment.center,
              child: ListView(
                children: [
                  Text(
                    moty[event.eventStartTime.month - 1],
                    textAlign: TextAlign.center,
                    style: monthStyle,
                  ),
                  Text(
                    event.eventStartTime.day.toString(),
                    textAlign: TextAlign.center,
                    style: dateStyle,
                  ),
                ],
              ),
              height: MediaQuery.of(context).size.height * 0.08,
              width: MediaQuery.of(context).size.height * 0.08,
              decoration: BoxDecoration(
                  color: Colors.grey,
                  borderRadius: BorderRadius.all(Radius.circular(15))),
            )),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                DateFormat('EEEE').format(event.eventStartTime),
                textAlign: TextAlign.center,
                style: dayStyle,
              ),
              Text(
                "$startingTime - $finishingTime",
                textAlign: TextAlign.left,
                style: timeStyle,
              )
            ],
          ),
        ),
        SizedBox(
          width: MediaQuery.of(context).size.width * 0.05,
        ),
        Expanded(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              venue
                  ? applied
                      ? Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              RaisedButton(
                                child: Text(
                                  'Applicant \nSelected',
                                  textAlign: TextAlign.center,
                                ),
                                color: Colors.lightBlue,
                                onPressed: () {},
                              ),
                            ],
                          ),
                        )
                      : Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              RaisedButton(
                                child: Text('Applicants'),
                                color: Colors.lightBlue,
                                onPressed: () async {
                                  await showApplicantsDialog(context, event);
                                },
                              ),
                            ],
                          ),
                        )
                  : accepted
                      ? Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              RaisedButton(
                                child: Text('Confirm'),
                                color: Colors.lightBlue,
                                onPressed: () {
                                  FirebaseService().confirmEvent(event);
                                  Navigator.of(context).push(
                                      new MaterialPageRoute(
                                          builder: (BuildContext context) {
                                    return new ArtistNavbar(1);
                                  }));
                                },
                              ),
                            ],
                          ),
                        )
                      : Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              RaisedButton(
                                child: Text(applied ? 'Applied' : 'Apply'),
                                color: Colors.lightBlue,
                                onPressed: () {
                                  if (!applied) {
                                    applyForEvent(event, um.uid);
                                    applied = true;
                                    Navigator.of(context).push(
                                        new MaterialPageRoute(
                                            builder: (BuildContext context) {
                                      return new ArtistNavbar(1);
                                    }));
                                  }
                                },
                              ),
                            ],
                          ),
                        ),
              venue
                  ? PopupMenuButton(
                      onSelected: (value) {
                        deleteEvent(event);
                        Navigator.of(context).push(new MaterialPageRoute(
                            builder: (BuildContext context) {
                          return new VenueNavbar(2);
                        }));
                      },
                      child: Icon(Icons.more_vert),
                      itemBuilder: (context) => [
                        PopupMenuItem(
                            value: 1,
                            child: Row(
                              children: <Widget>[
                                Icon(Icons.delete),
                                Text('Delete')
                              ],
                            )),
                      ],
                    )
                  : SizedBox(width: 10),
              SizedBox(
                width: 10,
              )
            ],
          ),
        ),
      ],
    ),
  );
}
