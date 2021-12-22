import 'dart:convert';
import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:gignow/model/event.dart';
import 'package:gignow/model/user.dart';
import 'package:gignow/model/video_post.dart';
import 'package:gignow/net/globals.dart';
import 'package:gignow/net/video_ranking_service.dart';
import 'package:gignow/ui/chats/chats_screen.dart';
import 'package:gignow/ui/chats/conversation_screen.dart';
import 'package:gignow/ui/createProfile/create_profile_screen.dart';
import 'package:gignow/ui/events/events_screen.dart';
import 'package:gignow/ui/events/new_events_screen.dart';
import 'package:gignow/ui/userAccount/user_account_screen.dart';
import 'package:gignow/ui/loading.dart';
import 'package:gignow/widgets/video_post_widget.dart';
import '../model/user.dart';
import 'package:path/path.dart' as path;
import 'package:http/http.dart' as http;
import 'package:geolocator/geolocator.dart';
import '../model/user.dart';
import '../model/user.dart';
import 'database.dart';

class FirebaseService {
  FirebaseFirestore firestoreInstance;
  // final firestoreInstance = FirebaseFirestore.instance;
  // final FirebaseAuth auth = FirebaseAuth.instance;
  FirebaseAuth auth;
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

  Future<int> getIncrForVenue(String uid) async {
    List<Event> events = await getAllEventsForVenue(uid);
    int highestI = 0;
    for (Event e in events) {
      int inc = int.parse(e.eventId.split('-')[1]);
      if (inc > highestI) highestI = inc;
    }
    print(highestI);
    return highestI;
  }

  Future<UserModel> getUser(String userUid) async {
    DocumentReference docRef = users.doc(userUid);
    UserModel user;
    await updateProfileLocation(userUid);
    await docRef.get().then((snapshot) {
      if (snapshot.exists) {
        Map<String, String> socials = new Map<String, String>();
        if (snapshot.data().containsKey("socials")) {
          var x = snapshot.get('socials');
          x.keys.forEach((item) {
            // print(item);
            // print(x[item]);
            socials.addAll({item: x[item]});
          });
        }
        user = UserModel(
            snapshot.get('userUid').toString(),
            snapshot.get('name').toString(),
            snapshot.get('genres').toString(),
            snapshot.get('phoneNumber').toString(),
            snapshot.get('handle').toString(),
            snapshot.get('profile_picture_url').toString(),
            socials,
            snapshot.get('venue'),
            snapshot.get('position'),
            snapshot.get('followers'),
            snapshot.get('following'));
      }
    });

    return user;
  }

  Future<UserModel> getUserByHandle(String handle) async {
    DocumentReference docRef = users.doc(handle);
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
        }
        user = UserModel(
            snapshot.get('userUid').toString(),
            snapshot.get('name').toString(),
            snapshot.get('genres').toString(),
            snapshot.get('phoneNumber').toString(),
            snapshot.get('handle').toString(),
            snapshot.get('profile_picture_url').toString(),
            socials,
            snapshot.get('venue'),
            snapshot.get('position'),
            snapshot.get('followers'),
            snapshot.get('following'));
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

  // FutureBuilder<DocumentSnapshot> getEventsPage(String uid) {
  //   return FutureBuilder<DocumentSnapshot>(
  //       future: users.doc(uid).get(),
  //       builder:
  //           (BuildContext context, AsyncSnapshot<DocumentSnapshot> snapshot) {
  //         try {
  //           if (snapshot.hasError) {
  //             return Loading();
  //           }

  //           if (snapshot.connectionState == ConnectionState.done) {
  //             try {
  //               Map<String, dynamic> data = snapshot.data.data();
  //               if (data != null) {
  //                 return EventsScreen(data);
  //               } else {
  //                 return CreateProfileScreen();
  //               }
  //             } catch (e) {
  //               return Loading();
  //             }
  //           }

  //           return Loading();
  //         } catch (e) {
  //           return Loading();
  //         }
  //       });
  // }

  FutureBuilder<UserModel> getEventsPage(String uid) {
    return FutureBuilder<UserModel>(
        future: getUser(uid),
        builder: (context, snapshot) {
          try {
            if (snapshot.hasError) {
              return Loading();
            }

            if (snapshot.connectionState == ConnectionState.done) {
              try {
                UserModel data = snapshot.data;
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
    Map<String, int> genreScores = VideoRankingService().emptyGenreScores();
    firestoreInstance.collection("Users").doc(auth.currentUser.uid).set({
      "userUid": user.uid,
      "name": name,
      "phoneNumber": phone,
      "handle": handle,
      "genres": genres,
      "profile_picture_url": profilePictureUrl,
      "venue": venue,
      "followers": 0,
      "following": [],
      "genreScores": genreScores
    }).then((value) => Navigator.pushNamed(context, '/'));
    updateProfileLocation(auth.currentUser.uid);
  }

  void updateProfileLocation(String userUid) async {
    Position userPos = await determinePosition();
    double longitude = userPos.longitude;
    double latitude = userPos.latitude;
    GeoPoint geoPoint = GeoPoint(latitude, longitude);
    firestoreInstance
        .collection("Users")
        .doc(userUid)
        .update({"position": geoPoint});
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

  void createVideoPost(
      DateTime date, String desc, String url, String thumbnailURL) {
    final user = auth.currentUser;
    List<String> genres = Global().currentUserModel.genres.split(",");
    firestoreInstance.collection("VideoPosts").add({
      "user": users.doc(user.uid),
      "postDate": date,
      "postDescription": desc,
      "genres": genres,
      "videoURL": url,
      "thumbnailURL": thumbnailURL
    }).then((docRef) {
      // String dir = path.dirname(video.path);
      // String newPath = path.join(dir, "${docRef.id}.mp4");
      // video.renameSync(newPath);
      // // uploadVideo(
      // //     docRef.id, newPath, "https://gignow-310714.ew.r.appspot.com/upload");
      // uploadVideoPHP(newPath);
      print("Video Posted");
    });
  }

  Future<Map> getIsLikedAndNumLikesAndIsFollowing(VideoPost videoPost) async {
    final user = auth.currentUser;
    bool isLiked = false;
    bool isFollowing = false;
    var doc = await firestoreInstance
        .collection("VideoPostLikes")
        .doc("${videoPost.postID}_${user.uid}")
        .get();
    if (doc.exists) {
      isLiked = true;
    }
    var res = await firestoreInstance
        .collection("VideoPostLikes")
        .where("videoPost", isEqualTo: videoPosts.doc(videoPost.postID))
        .get();

    await users.doc(user.uid).get().then((curUser) {
      var curUserFollowing = curUser.data()['following'];
      if (curUserFollowing != null) {
        if (curUserFollowing.contains(users.doc(videoPost.userUID))) {
          isFollowing = true;
        }
      }
    });
    Map map = {
      'isLiked': isLiked,
      'numLikes': res.size,
      'isFollowing': isFollowing
    };
    return map;
  }

  void likeVideo(VideoPost videoPost) {
    final user = auth.currentUser;
    firestoreInstance
        .collection("VideoPostLikes")
        .doc("${videoPost.postID}_${user.uid}")
        .set({
      "user": users.doc(user.uid),
      "videoPost": videoPosts.doc(videoPost.postID),
    });
  }

  void likeUnlikeVideo(VideoPost videoPost) async {
    final user = auth.currentUser;
    var doc = await firestoreInstance
        .collection("VideoPostLikes")
        .doc("${videoPost.postID}_${user.uid}")
        .get();
    if (doc.exists) {
      unLikeVideo(videoPost);
    } else {
      likeVideo(videoPost);
      VideoRankingService().rankLikeVideo(videoPost, user.uid);
    }
  }

  void unLikeVideo(VideoPost videoPost) {
    final user = auth.currentUser;
    firestoreInstance
        .collection("VideoPostLikes")
        .doc("${videoPost.postID}_${user.uid}")
        .delete();
  }

  void createEvent(Event newEvent) {
    final user = auth.currentUser;
    firestoreInstance.collection("Events").doc(newEvent.eventId).set({
      "eventId": newEvent.eventId,
      "eventName": newEvent.eventName,
      "eventStartTime": newEvent.eventStartTime.toString(),
      "eventDuration": newEvent.eventDuration.toString(),
      "eventPhotoURL": newEvent.eventPhotoURL,
      "genres": newEvent.genres,
      "venueId": newEvent.venueId,
      "venue": newEvent.venue,
      "applicants": "",
      "acceptedUid": "",
      "confirmed": false
    });
  }

  void applyForEvent(Event event, String applicantUid) {
    if (event.applicants == null) {
      event.applicants = [];
    }
    if (!event.applicants.contains(applicantUid)) {
      event.applicants.add(applicantUid);
      firestoreInstance.collection("Events").doc(event.eventId).set({
        "eventId": event.eventId,
        "eventName": event.eventName,
        "eventStartTime": event.eventStartTime.toString(),
        "eventDuration": event.eventDuration.toString(),
        "eventPhotoURL": event.eventPhotoURL,
        "genres": event.genres,
        "venueId": event.venueId,
        "venue": event.venue,
        "applicants": event.applicants.join(','),
        "acceptedUid": event.acceptedUid,
        "confirmed": event.confirmed
      });
    }
  }

  void acceptApplicant(Event event, String applicantUid) {
    events.doc(event.eventId).set({
      "eventId": event.eventId,
      "eventName": event.eventName,
      "eventStartTime": event.eventStartTime.toString(),
      "eventDuration": event.eventDuration.toString(),
      "eventPhotoURL": event.eventPhotoURL,
      "genres": event.genres,
      "venueId": event.venueId,
      "venue": event.venue,
      "applicants": event.applicants.join(','),
      "acceptedUid": applicantUid,
      "confirmed": event.confirmed
    });
  }

  void rejectApplicant(Event event, String applicantUid) {
    event.applicants.remove(applicantUid);
    events.doc(event.eventId).set({
      "eventId": event.eventId,
      "eventName": event.eventName,
      "eventStartTime": event.eventStartTime.toString(),
      "eventDuration": event.eventDuration.toString(),
      "eventPhotoURL": event.eventPhotoURL,
      "genres": event.genres,
      "venueId": event.venueId,
      "venue": event.venue,
      "applicants": event.applicants.join(','),
      "acceptedUid": null,
      "confirmed": event.confirmed
    });
  }

  void confirmEvent(Event event) {
    firestoreInstance.collection("Events").doc(event.eventId).set({
      "eventId": event.eventId,
      "eventName": event.eventName,
      "eventStartTime": event.eventStartTime.toString(),
      "eventDuration": event.eventDuration.toString(),
      "eventPhotoURL": event.eventPhotoURL,
      "genres": event.genres,
      "venueId": event.venueId,
      "venue": event.venue,
      "applicants": event.applicants.join(','),
      "acceptedUid": event.acceptedUid,
      "confirmed": true
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

        VideoPost post = VideoPost(
            element.id,
            userUid,
            element['postDate'],
            element['postDescription'],
            element['videoURL'],
            element.data().containsKey('thumbnailURL')
                ? element['thumbnailURL']
                : "https://cdn.shopify.com/s/files/1/2018/8867/files/play-button.png");
        posts.add(post);
      }
    });
    return posts;
  }

  Future<List<VideoPostWidget>> getVideoPostWidgets() async {
    List<VideoPostWidget> posts = new List<VideoPostWidget>();
    var result = await videoPosts.get();
    result.docs.forEach((element) async {
      if (element.data().containsKey('videoURL')) {
        DocumentReference ref = element['user'];
        String userUid = ref.id;
        VideoPost post = VideoPost(
            element.id,
            userUid,
            element['postDate'],
            element['postDescription'],
            element['videoURL'],
            element.data().containsKey('thumbnailURL')
                ? element['thumbnailURL']
                : "https://cdn.shopify.com/s/files/1/2018/8867/files/play-button.png");
        VideoPostWidget postWidget = VideoPostWidget(post);
        posts.add(postWidget);
      }
    });
    return posts;
  }

  Future<Event> getEvent(String eventId) async {
    await events.doc(eventId).get().then((value) {
      List<String> applicants;
      String acceptedUid;
      bool confirmed;
      try {
        applicants = value.data()['applicants'].split(',') ?? null;
      } on Error catch (_) {}
      try {
        acceptedUid = value.data()['acceptedUid'] ?? null;
      } on Error catch (_) {}
      try {
        confirmed = value.data()['confirmed'] ?? false;
      } on Error catch (_) {}

      Event event = Event(
          value.data()['eventId'],
          value.data()['eventName'],
          DateTime.parse(value.data()['eventStartTime']),
          parseDuration(value.data()['eventDuration']),
          value.data()['eventPhotoURL'],
          value.data()['venueId'],
          value.data()['genres'],
          value.data()['venue'],
          applicants,
          acceptedUid,
          confirmed);
      return event;
    });
  }

  Future<List<UserModel>> getEventApplicants(String eventId) async {
    DocumentReference docRef = events.doc(eventId);
    List<String> applicantUids;
    List<UserModel> applicants = [];

    await docRef.get().then((snapshot) {
      try {
        applicantUids = snapshot.get('applicants').split(',') ?? null;
      } on Error catch (_) {}
    });
    if (applicantUids != null) {
      for (String uid in applicantUids) {
        if (uid.isNotEmpty) {
          UserModel applicant = await getUser(uid);
          applicants.add(applicant);
        }
      }
    }

    return applicants;
  }

  Future<UserModel> getSelectedApplicant(String eventId) async {
    DocumentReference docRef = events.doc(eventId);
    String acceptedUid;
    UserModel applicant;
    await docRef.get().then((snapshot) {
      try {
        acceptedUid = snapshot.get('acceptedUid') ?? null;
      } on Error catch (_) {}
    });
    if (acceptedUid != null) {
      applicant = await getUser(acceptedUid);
    }

    return applicant;
  }

  void initOffers() async {
    var res = await users.get();

    res.docs.forEach((doc) async {
      if (doc['venue'] == false) {
        await users.doc(doc.id).update({"offersOpen": false});
      }
    });
  }

  void updateUserOffers(String userUid, bool offers) async {
    Position userPos = await determinePosition();
    double longitude = userPos.longitude;
    double latitude = userPos.latitude;
    GeoPoint geoPoint = GeoPoint(latitude, longitude);
    firestoreInstance
        .collection("Users")
        .doc(userUid)
        .update({"offersOpen": offers});
  }

  Future<List<Event>> getAllEvents() async {
    List<Event> returned = [];
    await events.get().then((QuerySnapshot querySnapshot) {
      querySnapshot.docs.forEach((doc) {
        List<String> applicants = new List<String>();
        String acceptedUid = null;
        bool confirmed = null;
        try {
          acceptedUid = doc['acceptedUid'] ?? null;
        } on Error catch (_) {}
        try {
          confirmed = doc['confirmed'] ?? false;
        } on Error catch (_) {}

        returned.add(Event(
            doc['eventId'],
            doc['eventName'],
            DateTime.parse(doc['eventStartTime']),
            parseDuration(doc['eventDuration']),
            doc['eventPhotoURL'],
            doc['venueId'],
            doc['genres'],
            doc['venue'],
            applicants,
            acceptedUid,
            confirmed));
      });
      print("All events: " + returned.toString());
    });
    return returned;
  }

  Future<List<Event>> getOpenEvents() async {
    List<Event> returned = [];
    await events
        .where('confirmed', isEqualTo: false)
        .get()
        .then((QuerySnapshot querySnapshot) {
      querySnapshot.docs.forEach((doc) {
        List<String> applicants = null;
        String acceptedUid = null;
        bool confirmed = null;
        try {
          applicants = doc['applicants'].split(',') ?? null;
        } on Error catch (_) {}
        try {
          acceptedUid = doc['acceptedUid'] ?? null;
        } on Error catch (_) {}
        try {
          confirmed = doc['confirmed'] ?? false;
        } on Error catch (_) {}

        returned.add(Event(
            doc['eventId'],
            doc['eventName'],
            DateTime.parse(doc['eventStartTime']),
            parseDuration(doc['eventDuration']),
            doc['eventPhotoURL'],
            doc['venueId'],
            doc['genres'],
            doc['venue'],
            applicants,
            acceptedUid,
            confirmed));
      });
      print("All open events: " + returned.toString());
    });
    return returned;
  }

  // Future<List<String>> getConnections() async {
  //   List<String> returned = [];
  //   await connections
  //       .where("users", arrayContains: Global().currentUserModel.uid)
  //       .get()
  //       .then((QuerySnapshot querySnapshot) {
  //     querySnapshot.docs.forEach((doc) {
  //       for(int i = 0; i < )
  //     });
  //   });
  //   return returned;
  // }

  Future<List<Event>> getAllEventsForVenue(String venueId) async {
    List<Event> returned = [];
    await events
        .where('venueId', isEqualTo: venueId)
        .get()
        .then((QuerySnapshot querySnapshot) {
      querySnapshot.docs.forEach((doc) {
        List<String> applicants = null;
        String acceptedUid = null;
        bool confirmed = null;
        try {
          applicants = doc['applicants'].split(',') ?? null;
        } on Error catch (_) {}
        try {
          acceptedUid = doc['acceptedUid'] ?? null;
        } on Error catch (_) {}
        try {
          confirmed = doc['confirmed'] ?? false;
        } on Error catch (_) {}

        returned.add(Event(
            doc['eventId'],
            doc['eventName'],
            DateTime.parse(doc['eventStartTime']),
            parseDuration(doc['eventDuration']),
            doc['eventPhotoURL'],
            doc['venueId'],
            doc['genres'],
            doc['venue'],
            applicants,
            acceptedUid,
            confirmed));
      });
      print("All events for venue: $venueId:" + returned.toString());
    });
    return returned;
  }

  Future<List<Event>> getOpenEventsForVenue(String venueId) async {
    List<Event> returned = [];
    await events
        .where('venueId', isEqualTo: venueId)
        .where('confirmed', isEqualTo: false)
        .get()
        .then((QuerySnapshot querySnapshot) {
      querySnapshot.docs.forEach((doc) {
        List<String> applicants = null;
        String acceptedUid = null;
        bool confirmed = null;
        try {
          applicants = doc['applicants'].split(',') ?? null;
        } on Error catch (_) {}
        try {
          acceptedUid = doc['acceptedUid'] ?? null;
        } on Error catch (_) {}
        try {
          confirmed = doc['confirmed'] ?? false;
        } on Error catch (_) {}

        returned.add(Event(
            doc['eventId'],
            doc['eventName'],
            DateTime.parse(doc['eventStartTime']),
            parseDuration(doc['eventDuration']),
            doc['eventPhotoURL'],
            doc['venueId'],
            doc['genres'],
            doc['venue'],
            applicants,
            acceptedUid,
            confirmed));
      });
      print("All open events for venue: $venueId:" + returned.toString());
    });
    return returned;
  }

  Future<List<Event>> getUpcomingEventsForVenue(String venueId) async {
    List<Event> returned = [];
    await events
        .where('venueId', isEqualTo: venueId)
        .where('confirmed', isEqualTo: true)
        .get()
        .then((QuerySnapshot querySnapshot) {
      querySnapshot.docs.forEach((doc) {
        List<String> applicants = null;
        String acceptedUid = null;
        bool confirmed = null;
        try {
          applicants = doc['applicants'].split(',') ?? null;
        } on Error catch (_) {}
        try {
          acceptedUid = doc['acceptedUid'] ?? null;
        } on Error catch (_) {}
        try {
          confirmed = doc['confirmed'] ?? false;
        } on Error catch (_) {}

        returned.add(Event(
            doc['eventId'],
            doc['eventName'],
            DateTime.parse(doc['eventStartTime']),
            parseDuration(doc['eventDuration']),
            doc['eventPhotoURL'],
            doc['venueId'],
            doc['genres'],
            doc['venue'],
            applicants,
            acceptedUid,
            confirmed));
      });
      print("Upcoming events for venue: $venueId:" + returned.toString());
    });
    return returned;
  }

  Future<List<Event>> getUpcomingEventsForArtist(String artistId) async {
    List<Event> returned = [];
    await events
        .where('acceptedUid', isEqualTo: artistId)
        .where('confirmed', isEqualTo: true)
        .get()
        .then((QuerySnapshot querySnapshot) {
      querySnapshot.docs.forEach((doc) {
        List<String> applicants = null;
        String acceptedUid = null;
        bool confirmed = null;
        try {
          applicants = doc['applicants'].split(',') ?? null;
        } on Error catch (_) {}
        try {
          acceptedUid = doc['acceptedUid'] ?? null;
        } on Error catch (_) {}
        try {
          confirmed = doc['confirmed'] ?? false;
        } on Error catch (_) {}

        returned.add(Event(
            doc['eventId'],
            doc['eventName'],
            DateTime.parse(doc['eventStartTime']),
            parseDuration(doc['eventDuration']),
            doc['eventPhotoURL'],
            doc['venueId'],
            doc['genres'],
            doc['venue'],
            applicants,
            acceptedUid,
            confirmed));
      });
      print("Upcoming events for artist: $artistId:" + returned.toString());
    });
    return returned;
  }

  Future<List<VideoPost>> getUsersVideoPosts(String uid) async {
    List<VideoPost> posts = new List<VideoPost>();
    DocumentReference userDocRef = users.doc(uid);
    var result = await videoPosts.where("user", isEqualTo: userDocRef).get();
    result.docs.forEach((element) async {
      if (element.data().containsKey('videoURL')) {
        DocumentReference ref = element['user'];
        String userUid = ref.id;
        VideoPost post = VideoPost(
            element.id,
            userUid,
            element['postDate'],
            element['postDescription'],
            element['videoURL'],
            element.data().containsKey('thumbnailURL')
                ? element['thumbnailURL']
                : "https://cdn.shopify.com/s/files/1/2018/8867/files/play-button.png");
        posts.add(post);
      }
    });
    return posts;
  }

  Future<List<VideoPost>> getFollowingVideoPosts() async {
    List<VideoPost> posts = new List<VideoPost>();
    var result = await videoPosts.get();
    var userDoc = await users.doc(auth.currentUser.uid);
    var following;
    var doc;

    await userDoc.get().then((snapshot) {
      if (snapshot.exists) {
        doc = snapshot.data();
        following = doc['following'];
        result.docs.forEach((element) async {
          if (element.data().containsKey('videoURL')) {
            DocumentReference ref = element['user'];
            String userUid = ref.id;
            if (following != null && following.contains(ref)) {
              VideoPost post = VideoPost(
                  element.id,
                  userUid,
                  element['postDate'],
                  element['postDescription'],
                  element['videoURL'],
                  element.data().containsKey('thumbnailURL')
                      ? element['thumbnailURL']
                      : "https://cdn.shopify.com/s/files/1/2018/8867/files/play-button.png");
              posts.add(post);
            }
          }
        });
      }
    });

    return posts;
  }

  Future<bool> usersAreConnected(String userUid1, String userUid2) async {
    String potentialComb1 = "${userUid1}_${userUid2}";
    String potentialComb2 = "${userUid2}_${userUid1}";
    bool exists = false;
    await connections.doc(potentialComb1).get().then((doc) {
      if (doc.exists) {
        exists = true;
      }
    });

    await connections.doc(potentialComb2).get().then((doc) {
      if (doc.exists) {
        exists = true;
      }
    });
    return exists;
  }

  Future<List<UserModel>> getArtistAccounts(List<String> genreFilters,
      double distanceFilter, List<String> connectionUids) async {
    List<UserModel> artistsCards = new List<UserModel>();
    var result = await users.where("venue", isEqualTo: false).get();
    result.docs.forEach((element) async {
      // DocumentReference ref = element['user'];
      // String userUid = ref.id;
      Map<String, String> socials = new Map<String, String>();
      if (element.data().containsKey("socials")) {
        var x = element.get('socials');
        x.keys.forEach((item) {
          // print(item);
          // print(x[item]);
          socials.addAll({item: x[item]});
        });
      }
      // print(genreFilters);
      // print(distanceFilter);
      bool connected = connectionUids.contains(element.id);
      UserModel card = UserModel(
          element.id,
          element['name'],
          element['genres'],
          element['phoneNumber'],
          element['handle'],
          element['profile_picture_url'],
          socials,
          element['venue'],
          element['position'],
          element['followers'],
          element['following']);
      bool filter = false;
      double distance = Geolocator.distanceBetween(
          Global().currentUserModel.position.latitude,
          Global().currentUserModel.position.longitude,
          card.position.latitude,
          card.position.longitude);
      for (int i = 0; i < genreFilters.length; i++) {
        if ((card.genres.contains(genreFilters[i]) &&
            distance <= distanceFilter &&
            !connected)) {
          filter = true;
          artistsCards.add(card);
          break;
        }
      }
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

  Future<UserModel> deleteEvent(Event event) async {
    DocumentReference docRef = events.doc(event.eventId);
    await docRef.delete();
  }

  Future<Position> determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return Future.error('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return Future.error(
          'Location permissions are permanently denied, we cannot request permissions.');
    }

    return await Geolocator.getCurrentPosition();
  }

  Duration parseDuration(String s) {
    int hours = 0;
    int minutes = 0;
    int micros;
    List<String> parts = s.split(':');
    if (parts.length > 2) {
      hours = int.parse(parts[parts.length - 3]);
    }
    if (parts.length > 1) {
      minutes = int.parse(parts[parts.length - 2]);
    }
    micros = (double.parse(parts[parts.length - 1]) * 1000000).round();
    return Duration(hours: hours, minutes: minutes, microseconds: micros);
  }

  void followUnfollowUser(String followedUserUid) async {
    DocumentReference currentUserDoc = users.doc(auth.currentUser.uid);
    DocumentReference followedUserDoc = users.doc(followedUserUid);
    await currentUserDoc.get().then((currentUser) async {
      var currentUserFollowing = currentUser.data()['following'];
      try {
        if (currentUserFollowing != null) {
          if (currentUserFollowing.contains(followedUserDoc)) {
            unFollowUser(currentUserDoc, followedUserDoc);
          } else {
            await followUser(currentUserDoc, followedUserDoc);
          }
        } else {
          await followUser(currentUserDoc, followedUserDoc);
        }
      } catch (e) {
        print(e.toString());
      }
    });
  }

  void followUser(DocumentReference currentUserDoc,
      DocumentReference followedUserDoc) async {
    currentUserDoc.update({
      "following": FieldValue.arrayUnion([followedUserDoc])
    });
    followedUserDoc.update({"followers": FieldValue.increment(1)});
    await followedUserDoc.get().then((res) {
      var followedUserFollowing = res.data()['following'];
      try {
        if (followedUserFollowing != null) {
          if (followedUserFollowing.contains(currentUserDoc)) {
            String connectionID = "${currentUserDoc.id}_${followedUserDoc.id}";
            connections.doc(connectionID).update({
              "users": FieldValue.arrayUnion([currentUserDoc, followedUserDoc]),
              // "users": FieldValue.arrayUnion([followedUserDoc])
            });
          }
        }
      } catch (e) {
        print(e.toString());
      }
    });
  }

  void unFollowUser(DocumentReference currentUserDoc,
      DocumentReference followedUserDoc) async {
    currentUserDoc.update({
      "following": FieldValue.arrayRemove([followedUserDoc])
    });
    followedUserDoc.update({"followers": FieldValue.increment(-1)});
    String connectionID = "${currentUserDoc.id}_${followedUserDoc.id}";
    DocumentReference connectionDoc = connections.doc(connectionID);
    await connectionDoc.get().then((doc) {
      if (doc.exists) {
        connectionDoc.delete();
      }
    });
    connectionID = "${followedUserDoc.id}_${currentUserDoc.id}";
    connectionDoc = connections.doc(connectionID);
    await connectionDoc.get().then((doc) {
      if (doc.exists) {
        connectionDoc.delete();
      }
    });
  }

  Future<int> getFollowerCount(String userUid) async {
    DocumentReference userDoc = users.doc(userUid);
    var followers =
        await users.where('following', arrayContains: userDoc).get();
    return followers.size;
  }

  Future<List<String>> getUserConnectionsUids(String curUserUid) async {
    List<String> connectionUids = [];
    // var result = await videoPosts.where("user", isEqualTo: userDocRef).get();
    // result.docs.forEach((element) async {
    DocumentReference curDocRef = users.doc(curUserUid);
    var result =
        await connections.where("users", arrayContains: curDocRef).get();
    result.docs.forEach((doc) {
      String id = doc.id;
      String connectedId = id.replaceAll("_", "");
      connectedId = connectedId.replaceAll(curUserUid, "");
      connectionUids.add(connectedId);
    });
    return connectionUids;
  }

  FirebaseService() {
    this.firestoreInstance = FirebaseFirestore.instance;
    this.auth = FirebaseAuth.instance;
  }

  FirebaseService.withInstance(
      FirebaseFirestore firestoreInstance, FirebaseAuth authInstance) {
    this.firestoreInstance = firestoreInstance;
    this.auth = authInstance;
  }
}
