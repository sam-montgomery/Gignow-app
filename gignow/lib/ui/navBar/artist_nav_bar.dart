import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:gignow/ui/chats/chats_screen.dart';
import 'package:gignow/widgets/post_form.dart';
import 'package:gignow/widgets/video_post_list.dart';
import '../../artist_cards/swipe_feed_page.dart';
import '../../net/firebase_service.dart';

class ArtistNavbar extends StatefulWidget {
  @override
  _ANavBarState createState() => _ANavBarState();
}

class _ANavBarState extends State<ArtistNavbar> {
  int _currentIndex = 0;

  final FirebaseAuth auth = FirebaseAuth.instance;
  FirebaseService _firebaseService = FirebaseService();

  @override
  Widget build(BuildContext context) {
    final tabs = [
      Center(child: VideoPostList()),
      Center(child: _firebaseService.getEventsPage(auth.currentUser.uid)),
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
              icon: Icon(CupertinoIcons.home),
              label: ("Home"),
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.calendar_today_rounded),
              label: ("Events"),
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.add),
              label: ("New Post"),
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
