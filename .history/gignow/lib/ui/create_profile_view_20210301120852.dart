import 'package:flutter/material.dart';

class CreateProfileView extends StatefulWidget {
  @override
  _CreateProfileViewState createState() => _CreateProfileViewState();
}

class _CreateProfileViewState extends State<CreateProfileView> {
  String _accountType;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Create Profile")),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Text("Account Type:"),
          ListTile(
            title: const Text('Artist'),
            leading: Radio(
              value: "Artist",
              groupValue: _accountType,
              onChanged: (String value) {
                setState(() {
                  _accountType = value;
                });
              },
            ),
          ),
          ListTile(
            title: const Text('Venue'),
            leading: Radio(
              value: "Venue",
              groupValue: _accountType,
              onChanged: (String value) {
                setState(() {
                  _accountType = value;
                });
              },
            ),
          ),
        ],
      ),
    );
  }
}
