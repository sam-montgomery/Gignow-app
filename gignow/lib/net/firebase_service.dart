import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:gignow/ui/create_profile_view.dart';
import 'package:gignow/ui/home_screen.dart';
import 'package:gignow/ui/loading.dart';

class FirebaseService {
  final firestoreInstance = FirebaseFirestore.instance;
  final FirebaseAuth auth = FirebaseAuth.instance;
  CollectionReference artists =
      FirebaseFirestore.instance.collection('Artists');

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
                  return HomeScreen(data);
                } else {
                  return CreateProfileView();
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

  Map<String, dynamic> getProfile(String uid) {
    firestoreInstance.collection("Artists").doc(uid).get().then((value) {
      print(value.data());
      return (value.data());
    });
  }

  void createArtistProfile(String firstName, String lastName, String phone,
      String genres, String profilePictureUrl) {
    final user = auth.currentUser;
    firestoreInstance.collection("Artists").doc(auth.currentUser.uid).set({
      "userUid": user.uid,
      "firstName": firstName,
      "lastName": lastName,
      "phoneNumber": phone,
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

  FirebaseService();
}
