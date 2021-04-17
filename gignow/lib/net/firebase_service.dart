import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:gignow/model/user.dart';
import 'package:gignow/model/video_post.dart';
import 'package:gignow/ui/createProfile/create_profile_screen.dart';
import 'package:gignow/ui/userAccount/user_account_screen.dart';
import 'package:gignow/ui/loading.dart';
import '../model/user.dart';

class FirebaseService {
  final firestoreInstance = FirebaseFirestore.instance;
  final FirebaseAuth auth = FirebaseAuth.instance;
  CollectionReference artists =
      FirebaseFirestore.instance.collection('Artists');
  CollectionReference venues = FirebaseFirestore.instance.collection('Venues');
  CollectionReference videoPosts =
      FirebaseFirestore.instance.collection('VideoPosts');

  Future<String> getProfilePicURL(String userUid) async {
    DocumentReference docRef = artists.doc(userUid);
    String url;
    await docRef.get().then((snapshot) {
      url = snapshot.get('profile_picture_url').toString();
    });

    if (url == null) {
      docRef = venues.doc(userUid);
      await docRef.get().then((snapshot) {
        url = snapshot.get('profile_picture_url').toString();
      });
    }

    return url;
  }

  Future<UserModel> getUser(String userUid) async {
    DocumentReference docRef = artists.doc(userUid);
    UserModel user;
    await docRef.get().then((snapshot) {
      if (snapshot.exists) {
        String fullName = snapshot.get('name').toString();
        user = UserModel(
            snapshot.get('userUid').toString(),
            fullName,
            snapshot.get('genres').toString(),
            snapshot.get('phoneNumber').toString(),
            snapshot.get('handle').toString(),
            snapshot.get('profile_picture_url').toString());
      }
    });
    if (user == null) {
      docRef = venues.doc(userUid);
      await docRef.get().then((snapshot) {
        if (snapshot.exists) {
          user = UserModel(
              snapshot.get('userUid').toString(),
              snapshot.get('venueName').toString(),
              snapshot.get('genres').toString(),
              snapshot.get('phoneNumber').toString(),
              snapshot.get('handle').toString(),
              snapshot.get('profile_picture_url').toString());
        }
      });
    }

    return user;
  }

  Future getDocSnap(String uid) {
    artists.doc(uid).get().then((DocumentSnapshot documentSnapshot) {
      if (documentSnapshot.exists) {
        return true;
      }
      return false;
    });
  }

  FutureBuilder<DocumentSnapshot> getFirstView(String uid) {
    return FutureBuilder<DocumentSnapshot>(
        future: artists.doc(uid).get(),
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
                  return UserAccountScreen(data);
                } else {
                  return getFirstVenueView(uid);
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

  FutureBuilder<DocumentSnapshot> getFirstVenueView(String uid) {
    return FutureBuilder<DocumentSnapshot>(
        future: venues.doc(uid).get(),
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
                  return UserAccountScreen(data);
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

  Map<String, dynamic> getArtistProfile(String uid) {
    firestoreInstance.collection("Artists").doc(uid).get().then((value) {
      print(value.data());
      return (value.data());
    });
  }

  Map<String, dynamic> getVenueProfile(String uid) {
    firestoreInstance.collection("Venues").doc(uid).get().then((value) {
      print(value.data());
      return (value.data());
    });
  }

  void createArtistProfile(String name, String phone, String handle,
      String genres, String profilePictureUrl) {
    final user = auth.currentUser;
    firestoreInstance.collection("Artists").doc(auth.currentUser.uid).set({
      "userUid": user.uid,
      "name": name,
      "phoneNumber": phone,
      "handle": handle,
      "genres": genres,
      "profile_picture_url": profilePictureUrl
    });
  }

  void createVideoPost(String email, String fullName, DateTime date,
      String desc, String videoURL) {
    final user = auth.currentUser;
    firestoreInstance.collection("VideoPosts").doc().set({
      "user": artists.doc(user.uid),
      "postDate": date,
      "postDescription": desc,
      "videoURL": videoURL
    });
  }

  void createVenueProfile(String name, String phone, String handle,
      String genres, String profilePictureUrl) {
    final user = auth.currentUser;
    firestoreInstance.collection("Venues").doc(auth.currentUser.uid).set({
      "userUid": user.uid,
      "venueName": name,
      "phoneNumber": phone,
      "handle": handle,
      "genres": genres,
      "profile_picture_url": profilePictureUrl
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
      DocumentReference ref = element['user'];
      String userUid = ref.id;
      VideoPost post = VideoPost(element.id, userUid, element['postDate'],
          element['postDescription'], element['videoURL']);
      posts.add(post);
    });
    return posts;
  }

  Future<List<VideoPost>> getUsersVideoPosts(String uid) async {
    List<VideoPost> posts = new List<VideoPost>();
    DocumentReference userDocRef = artists.doc(uid);
    var result = await videoPosts.where("user", isEqualTo: userDocRef).get();
    result.docs.forEach((element) async {
      DocumentReference ref = element['user'];
      String userUid = ref.id;
      VideoPost post = VideoPost(element.id, userUid, element['postDate'],
          element['postDescription'], element['videoURL']);
      posts.add(post);
    });
    return posts;
  }

  Future<List<UserModel>> getArtistAccounts() async {
    List<UserModel> artistsCards = new List<UserModel>();
    var result = await artists.get();
    result.docs.forEach((element) async {
      // DocumentReference ref = element['user'];
      // String userUid = ref.id;
      UserModel card = UserModel(
          element.id,
          element['name'],
          element['genres'],
          element['phoneNumber'],
          element['handle'],
          element['profile_picture_url']);
      artistsCards.add(card);
    });
    return artistsCards;
  }

  FirebaseService();
}
