import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:gignow/ui/chats/chats_screen.dart';
import 'package:gignow/widgets/post_form.dart';
import 'package:gignow/widgets/video_post_list.dart';
import '../../artist_cards/swipe_feed_page.dart';
import '../../net/firebase_service.dart';

class ArtistNavbar extends StatefulWidget {
  int prev;

  ArtistNavbar(int i) {
    prev = i;
  }

  @override
  _ANavBarState createState() => _ANavBarState();
}

class _ANavBarState extends State<ArtistNavbar> {
  final FirebaseAuth auth = FirebaseAuth.instance;
  FirebaseService _firebaseService = FirebaseService();

  @override
  Widget build(BuildContext context) {
    int _currentIndex = widget.prev;
    final tabs = [
      Center(key: ValueKey("ArtistHomeFeed"), child: VideoPostList()),
      Center(
          key: ValueKey("EventsPage"),
          child: _firebaseService.getEventsPage(auth.currentUser.uid)),
      Center(child: PostForm()),
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
              icon: Icon(
                CupertinoIcons.home,
                key: ValueKey("NavBarHomeBtn"),
              ),
              label: ("Home"),
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.calendar_today_rounded,
                  key: ValueKey("NavBarEventsBtn")),
              label: ("Events"),
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.add, key: ValueKey("NavBarPostBtn")),
              label: ("New Post"),
            ),
            BottomNavigationBarItem(
              icon: Icon(CupertinoIcons.chat_bubble,
                  key: ValueKey("NavBarChatBtn")),
              label: ("Chats"),
            ),
            BottomNavigationBarItem(
              icon: Icon(CupertinoIcons.profile_circled,
                  key: ValueKey("NavBarProfileBtn")),
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
