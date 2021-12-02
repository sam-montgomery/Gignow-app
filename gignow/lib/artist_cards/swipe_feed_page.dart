import 'package:flutter/material.dart';
import 'package:gignow/model/user.dart';
import 'package:gignow/net/firebase_service.dart';
import 'package:gignow/ui/loading.dart';
import 'cards_section_alignment.dart';
import 'cards_section_alignment.dart';

class SwipeFeedPage extends StatefulWidget {
  @override
  _SwipeFeedPageState createState() => _SwipeFeedPageState();
}

class _SwipeFeedPageState extends State<SwipeFeedPage> {
  FirebaseService firebaseService = FirebaseService();
  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: firebaseService.getArtistAccounts(),
        builder: (builder, snapshot) {
          if (snapshot.hasData) {
            List<UserModel> artists = snapshot.data;
            return Scaffold(
              backgroundColor: Colors.grey[300],
              body: Column(children: <Widget>[
                CardsSectionAlignment(artists, context),
              ]),
            );
          } else {
            return Loading();
          }
        });
  }
}
