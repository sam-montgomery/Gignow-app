import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../../artist_cards/swipe_feed_page.dart';
import '../../net/firebase_service.dart';
import '../../net/firebase_service.dart';
import '../userAccount/user_account_screen.dart';

class VenueNavbar extends StatefulWidget {
  @override
  _VNavBarState createState() => _VNavBarState();
}

class _VNavBarState extends State<VenueNavbar> {
  int _currentIndex = 0;

  final FirebaseAuth auth = FirebaseAuth.instance;
  FirebaseService _firebaseService = FirebaseService();

  @override
  Widget build(BuildContext context) {
    final tabs = [
      Center(child: SwipeFeedPage()),
      Center(child: Text('Home Video Feed')),
      Center(child: Text('Events')),
      Center(child: Text('Connections')),
      Center(child: _firebaseService.getFirstView(auth.currentUser.uid))
    ];
    return Scaffold(
      body: tabs[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
          currentIndex: _currentIndex,
          type: BottomNavigationBarType.fixed,
          items: [
            BottomNavigationBarItem(
              icon: Icon(CupertinoIcons.eye_fill),
              label: ("Discover"),
            ),
            BottomNavigationBarItem(
              icon: Icon(CupertinoIcons.home),
              label: ("Home"),
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.calendar_today_rounded),
              label: ("Events"),
            ),
            BottomNavigationBarItem(
              icon: Icon(CupertinoIcons.chat_bubble),
              label: ("Connections"),
            ),
            BottomNavigationBarItem(
              icon: Icon(CupertinoIcons.profile_circled),
              label: ("Profile"),
            )
          ],
          onTap: (index) {
            setState(() {
              _currentIndex = index;
            });
          }),
    );
  }
}
