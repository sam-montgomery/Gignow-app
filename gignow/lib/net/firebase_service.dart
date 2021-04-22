import 'dart:convert';
import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:gignow/model/event.dart';
import 'package:gignow/model/user.dart';
import 'package:gignow/model/video_post.dart';
import 'package:gignow/ui/chats/chats_screen.dart';
import 'package:gignow/ui/chats/conversation_screen.dart';
import 'package:gignow/ui/createProfile/create_profile_screen.dart';
import 'package:gignow/ui/events/events_screen.dart';
import 'package:gignow/ui/userAccount/user_account_screen.dart';
import 'package:gignow/ui/loading.dart';
import '../model/user.dart';
import 'package:path/path.dart' as path;
import 'package:http/http.dart' as http;

import 'database.dart';

class FirebaseService {
  final firestoreInstance = FirebaseFirestore.instance;
  final FirebaseAuth auth = FirebaseAuth.instance;
  CollectionReference users = FirebaseFirestore.instance.collection('Users');
  CollectionReference videoPosts =
      FirebaseFirestore.instance.collection('VideoPosts');
  CollectionReference events = FirebaseFirestore.instance.collection('Events');
  CollectionReference connections =
      FirebaseFirestore.instance.collection('Connections');

  Future<String> getProfilePicURL(String userUid) async {
    DocumentReference docRef = users.doc(userUid);
    String url;
    await docRef.get().then((snapshot) {
      url = snapshot.get('profile_picture_url').toString();
    });

    return url;
  }

  Future<UserModel> getUser(String userUid) async {
    DocumentReference docRef = users.doc(userUid);
    UserModel user;
    await docRef.get().then((snapshot) {
      if (snapshot.exists) {
        Map<String, String> socials = new Map<String, String>();
        if (snapshot.data().containsKey("socials")) {
          var x = snapshot.get('socials');
          x.keys.forEach((item) {
            print(item);
            print(x[item]);
            socials.addAll({item: x[item]});
          });
          // x.values.forEach((item) {
          //   print(item);
          // });
        }
        user = UserModel(
            snapshot.get('userUid').toString(),
            snapshot.get('name').toString(),
            snapshot.get('genres').toString(),
            snapshot.get('phoneNumber').toString(),
            snapshot.get('handle').toString(),
            snapshot.get('profile_picture_url').toString(),
            socials,
            snapshot.get('venue'));
      }
    });

    return user;
  }

  Future<UserModel> getUserByHandle(String handle) async {
    DocumentReference docRef = users.doc(handle);
    UserModel user;
    await docRef.get().then((snapshot) {
      if (snapshot.exists) {
        Map<String, String> socials = {};
        if (snapshot.data().containsKey("socials")) {
          socials = snapshot.get('socials');
        }
        user = UserModel(
            snapshot.get('userUid').toString(),
            snapshot.get('name').toString(),
            snapshot.get('genres').toString(),
            snapshot.get('phoneNumber').toString(),
            snapshot.get('handle').toString(),
            snapshot.get('profile_picture_url').toString(),
            socials,
            snapshot.get('venue'));
      }
    });

    return user;
  }

  FutureBuilder<UserModel> getFirstView(String uid) {
    return FutureBuilder<UserModel>(
        future: getUser(uid),
        builder: (BuildContext context, AsyncSnapshot<UserModel> snapshot) {
          try {
            if (snapshot.hasError) {
              return Loading();
            }
            if (snapshot.connectionState == ConnectionState.done) {
              try {
                if (snapshot.hasData) {
                  UserModel user = snapshot.data;
                  return UserAccountScreen(user);
                } else {
                  return CreateProfileScreen();
                }
              } catch (e) {
                return Loading();
              }
            }

            return Loading();
          } catch (e) {
            return Loading();
          }
        });
  }

  FutureBuilder<DocumentSnapshot> getVenueEventsPage(String uid) {
    return FutureBuilder<DocumentSnapshot>(
        future: users.doc(uid).get(),
        builder:
            (BuildContext context, AsyncSnapshot<DocumentSnapshot> snapshot) {
          try {
            if (snapshot.hasError) {
              return Loading();
            }

            if (snapshot.connectionState == ConnectionState.done) {
              try {
                Map<String, dynamic> data = snapshot.data.data();
                if (data != null) {
                  return EventsScreen(data);
                } else {
                  return CreateProfileScreen();
                }
              } catch (e) {
                return Loading();
              }
            }

            return Loading();
          } catch (e) {
            return Loading();
          }
        });
  }

  FutureBuilder<UserModel> getChatsScreenView(String uid) {
    return FutureBuilder<UserModel>(
        future: getUser(uid),
        builder: (context, snapshot) {
          try {
            if (snapshot.hasError) {
              return Loading();
            }

            if (snapshot.connectionState == ConnectionState.done) {
              try {
                if (snapshot.hasData) {
                  UserModel user = snapshot.data;
                  return ChatsScreen(user);
                } else {
                  return CreateProfileScreen();
                }
              } catch (e) {
                return Loading();
              }
            }

            return Loading();
          } catch (e) {
            return Loading();
          }
        });
  }

  void createProfile(context, String name, String phone, String handle,
      String genres, String profilePictureUrl, bool venue) {
    final user = auth.currentUser;
    firestoreInstance.collection("Users").doc(auth.currentUser.uid).set({
      "userUid": user.uid,
      "name": name,
      "phoneNumber": phone,
      "handle": handle,
      "genres": genres,
      "profile_picture_url": profilePictureUrl,
      "venue": venue
    }).then((value) => Navigator.pushNamed(context, '/'));
  }

  Future<String> uploadVideo(videoID, filename, url) async {
    Map<String, String> videoUrl = {"videoID": videoID};
    String queryString = Uri(queryParameters: videoUrl).query;
    var requestUrl = url + '?' + queryString;
    var request = http.MultipartRequest('POST', Uri.parse(requestUrl));

    request.files.add(await http.MultipartFile.fromPath('package', filename));

    request.fields.addAll(videoUrl);
    var res = await request.send();
    return res.reasonPhrase;
  }

  Future uploadVideoPHP(String newPath) async {
    var uri =
        Uri.parse("https://gignow.student.davecutting.uk/upload_file.php");
    var request = new http.MultipartRequest("POST", uri);

    var multipartFile = await http.MultipartFile.fromPath("video", newPath);
    request.files.add(multipartFile);
    http.StreamedResponse response = await request.send();
    response.stream.transform(utf8.decoder).listen((value) {
      print(value);
    });
    if (response.statusCode == 200) {
      print("Video uploaded");
    } else {
      print("Video upload failed");
    }
  }

  void createVideoPost(File video, DateTime date, String desc) {
    final user = auth.currentUser;
    firestoreInstance.collection("VideoPosts").add({
      "user": users.doc(user.uid),
      "postDate": date,
      "postDescription": desc,
    }).then((docRef) {
      String dir = path.dirname(video.path);
      String newPath = path.join(dir, "${docRef.id}.mp4");
      video.renameSync(newPath);
      // uploadVideo(
      //     docRef.id, newPath, "https://gignow-310714.ew.r.appspot.com/upload");
      uploadVideoPHP(newPath);
    });
  }

  void createEvent(String name, String phone, String handle, String genres) {
    final user = auth.currentUser;
    firestoreInstance.collection("Events").doc(auth.currentUser.uid).set({
      "eventId": user.uid,
      "venueName": name,
      "phoneNumber": phone,
      "handle": handle,
      "genres": genres
    });
  }

  Future<bool> checkIfDocExists(String docId) async {
    try {
      // Get reference to Firestore collection
      var collectionRef = firestoreInstance.collection('Artists');

      var doc = await collectionRef.doc(docId).get();
      return doc.exists;
    } catch (e) {
      throw e;
    }
  }

  Future<List<VideoPost>> getVideoPosts() async {
    List<VideoPost> posts = new List<VideoPost>();
    var result = await videoPosts.get();
    result.docs.forEach((element) async {
      if (element.data().containsKey('videoURL')) {
        DocumentReference ref = element['user'];
        String userUid = ref.id;
        VideoPost post = VideoPost(element.id, userUid, element['postDate'],
            element['postDescription'], element['videoURL']);
        posts.add(post);
      }
    });
    return posts;
  }

  Future<Event> getEvent(String eventId) async {
    firestoreInstance.collection("Events").doc(eventId).get().then((value) {
      Event event = Event(
          value.data()['eventId'],
          DateTime.parse(value.data()['eventStartTime']),
          DateTime.parse(value.data()['eventFinishTime']),
          value.data()['venueId']);
      return event;
    });
  }

  Future<List<Event>> getAllEvents() async {
    List<Event> returned = [];
    events.get().then((QuerySnapshot querySnapshot) {
      querySnapshot.docs.forEach((doc) {
        print(doc['eventId']);
        Event newEvent = Event(
            doc['eventId'],
            DateTime.parse(doc['eventStartTime']),
            DateTime.parse(doc['eventFinishTime']),
            doc['venueId']);
        returned.add(newEvent);
      });
      print("All events: " + returned.toString());
      return returned;
    });
  }

  Future<List<Event>> getAllEventsForVenue(String venueId) async {
    List<Event> returned = [];
    FirebaseFirestore.instance
        .collection('Events')
        .where('venueId', isEqualTo: venueId)
        .get()
        .then((QuerySnapshot querySnapshot) {
      querySnapshot.docs.forEach((doc) {
        returned.add(Event(
            doc['eventId'],
            DateTime.parse(doc['eventStartTime']),
            DateTime.parse(doc['eventFinishTime']),
            doc['venueId']));
      });
      print("All events for venue: $venueId:" + returned.toString());
      return returned;
    });
  }

  Future<List<VideoPost>> getUsersVideoPosts(String uid) async {
    List<VideoPost> posts = new List<VideoPost>();
    DocumentReference userDocRef = users.doc(uid);
    var result = await videoPosts.where("user", isEqualTo: userDocRef).get();
    result.docs.forEach((element) async {
      if (element.data().containsKey('videoURL')) {
        DocumentReference ref = element['user'];
        String userUid = ref.id;
        VideoPost post = VideoPost(element.id, userUid, element['postDate'],
            element['postDescription'], element['videoURL']);
        posts.add(post);
      }
    });
    return posts;
  }

  Future<List<UserModel>> getArtistAccounts() async {
    List<UserModel> artistsCards = new List<UserModel>();
    var result = await users.where("venue", isEqualTo: false).get();
    result.docs.forEach((element) async {
      // DocumentReference ref = element['user'];
      // String userUid = ref.id;

      Map<String, String> socials = {};
      if (element.data().containsKey("socials")) {
        socials = element['socials'];
      }
      UserModel card = UserModel(
          element.id,
          element['name'],
          element['genres'],
          element['phoneNumber'],
          element['handle'],
          element['profile_picture_url'],
          socials,
          element['venue']);
      artistsCards.add(card);
    });
    return artistsCards;
  }

  void createConnection(String userUidA, String userUidB) {
    String _id = "${userUidA}_${userUidB}";
    DocumentReference refA = users.doc(userUidA);
    DocumentReference refB = users.doc(userUidB);
    firestoreInstance.collection("Connections").doc(_id).set({
      "users": [refA, refB]
    });
    DatabaseMethods().createChatRoom(_id, userUidA, userUidB);
  }

  void updateSocials(String userUid, Map<String, String> socials) {
    users.doc(userUid).update({"socials": socials});
  }

  FirebaseService();
}
