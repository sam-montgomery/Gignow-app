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
import 'package:duration_picker/duration_picker.dart';
import 'package:multi_select_flutter/multi_select_flutter.dart';

class NewEventScreen extends StatefulWidget {
  UserModel profile;
  NewEventScreen(this.profile);
  @override
  NewEventScreenState createState() => NewEventScreenState();
}

class NewEventScreenState extends State<NewEventScreen> {
  final FirebaseAuth auth = FirebaseAuth.instance;
  FirebaseService firebaseService = FirebaseService();
  bool genreOffer = false;
  bool proxOffer = false;
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    DateTime eventStart;
    Duration _duration = Duration(hours: 0, minutes: 0);

    Container detailsCont = new Container(
      child: Column(
        children: [
          Padding(
            padding: EdgeInsets.all(8.0),
            child: TextButton(
                onPressed: () {
                  DatePicker.showDateTimePicker(context,
                      showTitleActions: true,
                      minTime: DateTime.now(),
                      maxTime: DateTime.now().add(Duration(days: 7)),
                      onChanged: (eventStart) {}, onConfirm: (eventStart) {
                    print('confirm $eventStart');
                  }, currentTime: DateTime.now(), locale: LocaleType.en);
                },
                child: Text('Event Start Time')),
          ),
          Padding(
            padding: EdgeInsets.all(8.0),
            child: TextButton(
                onPressed: () async {
                  _duration = await showDurationPicker(
                    context: context,
                    initialTime: Duration(hours: 1),
                  );
                  ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Duration: $_duration')));
                },
                child: Text('Event Duration')),
          ),
        ],
      ),
    );

    List<String> _genres = ["Pop", "Rock", "Metal", "Accoustic", "Folk"];

    List<String> selectedGenres;

    final genreSelector = MultiSelectChipField(
      items: _genres
          .map((genre) => MultiSelectItem<String>(genre, genre))
          .toList(),
      title: Text("Genres:"),
      headerColor: Colors.blue.withOpacity(0.5),
      decoration: BoxDecoration(
        border: Border.all(color: kButtonBackgroundColour, width: 1.8),
      ),
      selectedChipColor: Colors.blue.withOpacity(0.5),
      selectedTextStyle: TextStyle(color: Colors.blue[800]),
      onTap: (values) {
        selectedGenres = values;
      },
    );

    Container disabledGS = new Container(
      child: genreSelector,
      foregroundDecoration: BoxDecoration(
        color: Colors.grey,
        backgroundBlendMode: BlendMode.saturation,
      ),
    );

    Container offersCont = new Container(
      child: Column(
        children: [
          Padding(
            padding: EdgeInsets.all(8.0),
            child: SwitchListTile(
              title: const Text("Send event offers based on genres:"),
              value: genreOffer,
              onChanged: (offer) {
                setState(() {
                  genreOffer = offer;
                  print(genreOffer);
                });
              },
              activeTrackColor: Colors.grey,
              activeColor: Colors.blue,
            ),
          ),
          Padding(
            padding: EdgeInsets.all(8.0),
            child: Visibility(
              child: genreSelector,
              maintainSize: true,
              maintainAnimation: true,
              maintainState: true,
              visible: genreOffer,
            ),
          ),
          Padding(
            padding: EdgeInsets.all(8.0),
            child: SwitchListTile(
              title: const Text("Send event offers based on genres:"),
              value: proxOffer,
              onChanged: (prox) {
                setState(() {
                  genreOffer = prox;
                  print(genreOffer);
                });
              },
              activeTrackColor: Colors.grey,
              activeColor: Colors.blue,
            ),
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
                    views: [detailsCont, offersCont],
                    onChange: (index) => print(index),
                  ),
                )),
          ],
        ),
      ),
    );
  }
}
