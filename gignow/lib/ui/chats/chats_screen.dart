import 'package:flutter/material.dart';

class ChatsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Chats"),
        actions: [IconButton(icon: Icon(Icons.search), onPressed: () {})],
      ),
    );
  }
}
