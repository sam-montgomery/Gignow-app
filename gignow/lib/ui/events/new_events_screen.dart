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
import 'package:numberpicker/numberpicker.dart';
import 'package:contained_tab_bar_view/contained_tab_bar_view.dart';

class NewEventScreen extends StatefulWidget {
  UserModel profile;
  NewEventScreen(this.profile);
  @override
  NewEventScreenState createState() => NewEventScreenState();
}

class NewEventScreenState extends State<NewEventScreen> {
  final FirebaseAuth auth = FirebaseAuth.instance;
  FirebaseService firebaseService = FirebaseService();

  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    DateTime eventStart;
    int duration = 15;

    Container detailsCont = new Container(
      child: Column(
        children: [
          TextButton(
              onPressed: () {
                DatePicker.showDateTimePicker(context,
                    showTitleActions: true,
                    minTime: DateTime.now(),
                    maxTime: DateTime.now().add(Duration(days: 7)),
                    onChanged: (date) {}, onConfirm: (date) {
                  print('confirm $date');
                  eventStart = date;
                }, currentTime: DateTime.now(), locale: LocaleType.en);
              },
              child: Text('Event Start Time')),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                icon: Icon(Icons.remove),
                onPressed: () => setState(() {
                  final newValue = duration - 15;
                  duration = newValue.clamp(0, 100);
                }),
              ),
              Text('Current int value: $duration'),
              IconButton(
                icon: Icon(Icons.add),
                onPressed: () => setState(() {
                  duration = (duration + 15).clamp(0, 100);
                  print(duration);
                }),
              ),
            ],
          ),
        ],
      ),
    );

    UserModel user = widget.profile;
    String currentImgUrl = user.profilePictureUrl;
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            SizedBox(
                height: (MediaQuery.of(context).size.height * 0.25),
                child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Image(
                      image: NetworkImage(currentImgUrl),
                    ))),
            Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextFormField(
                  decoration: const InputDecoration(
                    border: UnderlineInputBorder(),
                    labelText: 'Enter an event title.',
                  ),
                )),
            SizedBox(height: (MediaQuery.of(context).size.height * 0.01)),
            Padding(
                padding: const EdgeInsets.all(8.0),
                child: Container(
                  height: (MediaQuery.of(context).size.height * 0.55),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                      color: Colors.blue[100],
                      borderRadius: BorderRadius.all(Radius.circular(10))),
                  child: ContainedTabBarView(
                    tabs: [
                      Icon(
                        Icons.format_list_bulleted,
                        color: Colors.black,
                      ),
                      Icon(
                        Icons.contact_mail,
                        color: Colors.black,
                      )
                    ],
                    views: [detailsCont, Container(color: Colors.green)],
                    onChange: (index) => print(index),
                  ),
                )),
          ],
        ),
      ),
    );
  }
}
