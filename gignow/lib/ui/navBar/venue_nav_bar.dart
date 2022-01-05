import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:gignow/ui/chats/chats_screen.dart';
import 'package:gignow/widgets/video_post_list.dart';
import '../../artist_cards/swipe_feed_page.dart';
import '../../net/firebase_service.dart';
import '../../net/globals.dart';
import '../userAccount/user_account_screen.dart';

class VenueNavbar extends StatefulWidget {
  int prev = 0;

  VenueNavbar(int previous) {
    prev = previous;
  }
  @override
  _VNavBarState createState() => _VNavBarState();
}

class _VNavBarState extends State<VenueNavbar> {
  final FirebaseAuth auth = FirebaseAuth.instance;
  FirebaseService _firebaseService = FirebaseService();

  @override
  Widget build(BuildContext context) {
    int _currentIndex = widget.prev;
    final tabs = [
      Center(key: ValueKey("DiscoverSwipeFeedPage"), child: SwipeFeedPage()),
      Center(key: ValueKey("VenueHomeFeed"), child: VideoPostList()),
      Center(child: _firebaseService.getEventsPage(auth.currentUser.uid)),
      Center(child: _firebaseService.getChatsScreenView(auth.currentUser.uid)),
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
              icon: Icon(Icons.calendar_today_rounded,
                  key: ValueKey("VenueNavBarEventsBtn")),
              label: ("Events"),
            ),
            BottomNavigationBarItem(
              icon: Icon(CupertinoIcons.chat_bubble,
                  key: ValueKey("VenueNavBarChatBtn")),
              label: ("Chats"),
            ),
            BottomNavigationBarItem(
              icon: Icon(CupertinoIcons.profile_circled,
                  key: ValueKey("VenueNavBarProfileBtn")),
              label: ("Profile"),
            )
          ],
          onTap: (index) {
            setState(() {
              _currentIndex = index;
              widget.prev = index;
            });
          }),
    );
  }
}
