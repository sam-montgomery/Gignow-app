import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:gignow/model/user.dart';
import 'package:gignow/net/firebase_service.dart';
import 'package:gignow/ui/createProfile/create_profile_screen.dart';
import 'package:gignow/ui/userAccount/user_account_screen.dart';

import 'loading.dart';
import 'navBar/artist_nav_bar.dart';
import 'navBar/venue_nav_bar.dart';

class HomeView extends StatefulWidget {
  @override
  _HomeViewState createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  final FirebaseAuth auth = FirebaseAuth.instance;
  FirebaseService firebaseService = FirebaseService();

  @override
  Widget build(BuildContext context) {
    //auth.signOut();
    //return ArtistNavbar();
    return FutureBuilder<UserModel>(
      future: firebaseService.getUser(auth.currentUser.uid),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          if (snapshot.hasData) {
            UserModel user = snapshot.data;
            if (user.venue) {
              return VenueNavbar();
            } else {
              return ArtistNavbar();
            }
          } else {
            return CreateProfileScreen();
          }
        } else {
          return Loading();
        }
      },
    );
  }
}
