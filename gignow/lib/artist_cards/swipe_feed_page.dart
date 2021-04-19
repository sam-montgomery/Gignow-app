import 'package:flutter/material.dart';
import 'package:gignow/model/user.dart';
import 'package:gignow/net/firebase_service.dart';
import 'package:gignow/ui/loading.dart';
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
              appBar: AppBar(
                elevation: 0.0,
                centerTitle: true,
                backgroundColor: Colors.white,
                leading: IconButton(
                    onPressed: () {},
                    icon: Icon(Icons.settings, color: Colors.grey)),
                actions: <Widget>[
                  IconButton(
                      onPressed: () {},
                      icon: Icon(Icons.question_answer, color: Colors.grey)),
                ],
              ),
              backgroundColor: Colors.white,
              body: Column(children: <Widget>[
                CardsSectionAlignment(artists, context),
                buttonsRow()
              ]),
            );
          } else {
            return Loading();
          }
        });
  }

  Widget buttonsRow() {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 30.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Padding(padding: EdgeInsets.only(right: 8.0)),
          FloatingActionButton(
            onPressed: () {},
            backgroundColor: Colors.white,
            child: Icon(Icons.close, color: Colors.red),
          ),
          Padding(padding: EdgeInsets.only(right: 8.0)),
          FloatingActionButton(
            onPressed: () {},
            backgroundColor: Colors.white,
            child: Icon(Icons.star, color: Colors.blue),
          ),
        ],
      ),
    );
  }
}
