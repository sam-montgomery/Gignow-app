import 'dart:async';
import 'dart:collection';
import 'dart:convert';
import 'dart:io';
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
import 'package:flutter/services.dart';
import 'package:gignow/ui/loading.dart';
import 'package:gignow/ui/events/events_screen.dart';
import 'package:gignow/ui/navBar/venue_nav_bar.dart';
import 'package:gignow/widgets/event_list.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
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
  String eventID = "";

  bool genreOffer = false;
  bool proxOffer = false;
  final picker = ImagePicker();
  File newImage;
  void initState() {
    super.initState();
  }

  List<Event> events = [];

  DateTime eventStartTime = DateTime.now();
  bool timePicked = false;
  Duration _duration = Duration(hours: 0, minutes: 0);
  bool durationPicked = false;

  bool imagePicked = false;
  String uploadedImage;

  static TextEditingController _eventTitleCont = TextEditingController();
  TextFormField eventTitleField = new TextFormField(
    controller: _eventTitleCont,
    decoration: const InputDecoration(
      border: UnderlineInputBorder(),
      labelText: 'Enter an event title',
    ),
  );

  Future<void> getVenuesEvents(UserModel user) async {
    events = await FirebaseService().getAllEventsForVenue(user.uid);

    int highestI = 0;
    for (Event e in events) {
      int inc = int.parse(e.eventId.split('-')[1]);
      if (inc > highestI) highestI = inc;
    }

    eventID = user.uid + '-' + (highestI + 1).toString();
    print("Event ID: " + eventID);
  }

  Future getImage() async {
    final pickedFile = await picker.getImage(source: ImageSource.gallery);

    setState(() {
      if (pickedFile != null) {
        newImage = File(pickedFile.path);
        imagePicked = true;
        print(pickedFile.path);
        uploadImageToFirebase(context);
      } else {
        print('No image selected.');
      }
    });
  }

  List<String> _genres = [
    "Pop",
    "Rock",
    "Metal",
    "Accoustic",
    "Folk",
    "Country",
    "Hip Hop",
    "Jazz",
    "Musical Theatre",
    "Punk Rock",
    "Heavy Metal",
    "Electronic",
    "Funk",
    "House",
    "Disco",
    "EDM",
    "Orchestra"
  ];

  List<String> selectedGenres;

  Future uploadImageToFirebase(BuildContext context) async {
    String fileName = newImage.path;
    firebase_storage.Reference firebaseStorageRef = firebase_storage
        .FirebaseStorage.instance
        .ref()
        .child('event_pictures/$fileName');
    firebase_storage.UploadTask uploadTask =
        firebaseStorageRef.putFile(newImage);
    firebase_storage.TaskSnapshot taskSnapshot =
        await uploadTask.whenComplete(() => null);
    taskSnapshot.ref.getDownloadURL().then(
      (value) {
        setState(() {
          uploadedImage = value;
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    UserModel user = widget.profile;
    String currentImgUrl = user.profilePictureUrl;
    getVenuesEvents(user);
    Row timeGraphic = new Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Padding(
          padding: EdgeInsets.all(12.0),
          child: timePicked
              ? Row(
                  children: [
                    Container(
                      alignment: Alignment.topCenter,
                      child: Column(
                        children: [
                          SizedBox(height: 3),
                          Text(
                            moty[eventStartTime.month - 1],
                            textAlign: TextAlign.center,
                            style: monthDisplayStyle,
                          ),
                          Text(
                            eventStartTime.day.toString(),
                            textAlign: TextAlign.center,
                            style: dateDisplayStyle,
                          ),
                        ],
                      ),
                      height: MediaQuery.of(context).size.height * 0.1,
                      width: MediaQuery.of(context).size.height * 0.1,
                      decoration: BoxDecoration(
                          color: Colors.grey,
                          borderRadius: BorderRadius.all(Radius.circular(15))),
                    ),
                    SizedBox(width: 10),
                    Text(
                      DateFormat('EEEE').format(eventStartTime) +
                          " - " +
                          (eventStartTime.hour == 0
                              ? "00"
                              : eventStartTime.hour.toString()) +
                          ":" +
                          (eventStartTime.minute == 0
                              ? "00"
                              : eventStartTime.minute.toString()) +
                          " to " +
                          (eventStartTime.add(_duration).hour == 0
                              ? "00"
                              : eventStartTime.add(_duration).hour.toString()) +
                          ":" +
                          (eventStartTime.add(_duration).minute == 0
                              ? "00"
                              : eventStartTime
                                  .add(_duration)
                                  .minute
                                  .toString()),
                      textAlign: TextAlign.left,
                      style: inActiveScreen,
                    )
                  ],
                )
              : null,
        ),
      ],
    );
    Container detailsCont = new Container(
        child: Column(children: [
      Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.all(12.0),
            child: TextButton(
                onPressed: () {
                  DatePicker.showDateTimePicker(context,
                      showTitleActions: true,
                      minTime: DateTime.now(),
                      maxTime: DateTime.now().add(Duration(days: 7)),
                      onChanged: (eventStart) {}, onConfirm: (eventStart) {
                    print('confirm $eventStart');
                    timePicked = true;
                    setState(() {
                      timePicked = true;
                      eventStartTime = eventStart;
                    });
                  }, currentTime: DateTime.now(), locale: LocaleType.en);
                },
                child: Text('Event Start Time')),
          ),
          Padding(
            padding: EdgeInsets.all(12.0),
            child: TextButton(
                onPressed: () async {
                  _duration = await showDurationPicker(
                    context: context,
                    initialTime: Duration(hours: 1),
                  );
                  durationPicked = true;
                  ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Duration: $_duration')));
                },
                child: Text('Event Duration')),
          ),
        ],
      ),
      SizedBox(height: 10),
      timeGraphic,
    ]));

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
                });
              },
              activeTrackColor: Colors.grey,
              activeColor: Colors.blue,
            ),
          ),
          SizedBox(height: 10),
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
          /*  Padding(
            padding: EdgeInsets.all(8.0),
            child: SwitchListTile(
              title: const Text("Send event offers based on location:"),
              value: proxOffer,
              onChanged: (prox) {
                setState(() {
                  proxOffer = prox;
                });
              },
              activeTrackColor: Colors.grey,
              activeColor: Colors.blue,
            ),
          ), */
        ],
      ),
    );

    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            SizedBox(height: 50),
            Padding(
                padding: const EdgeInsets.all(8.0),
                child: Container(
                  height: (MediaQuery.of(context).size.height * 0.35),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                      color: Colors.grey,
                      borderRadius: BorderRadius.all(Radius.circular(10))),
                  child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Image(
                          image: imagePicked
                              ? FileImage(newImage)
                              : NetworkImage(currentImgUrl))),
                )),
            Row(
              children: [
                SizedBox(width: 10),
                Expanded(child: eventTitleField),
                IconButton(
                  iconSize: 35,
                  icon: const Icon(Icons.add_a_photo_outlined),
                  onPressed: () async {
                    getImage();
                    setState(() {});
                  },
                ),
              ],
              mainAxisAlignment: MainAxisAlignment.end,
            ),
            SizedBox(height: (MediaQuery.of(context).size.height * 0.01)),
            Padding(
                padding: const EdgeInsets.all(8.0),
                child: Container(
                  height: (MediaQuery.of(context).size.height * 0.35),
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
                  ),
                )),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                      textStyle: const TextStyle(fontSize: 18),
                      primary: Colors.blue[150]),
                  onPressed: () {
                    Event newEvent = new Event(
                        eventID,
                        _eventTitleCont.text,
                        eventStartTime,
                        _duration,
                        imagePicked ? uploadedImage : currentImgUrl,
                        user.uid,
                        genreOffer ? selectedGenres.toList().join(",") : "",
                        user.toJson());
                    firebaseService.createEvent(newEvent);
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => VenueNavbar(2)),
                    );
                  },
                  child: const Text("Create Event")),
            )
          ],
        ),
      ),
    );
  }
}
