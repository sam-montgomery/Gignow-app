import 'package:flutter/material.dart';

class CreateProfileView extends StatefulWidget {
  @override
  _CreateProfileViewState createState() => _CreateProfileViewState();
}

class _CreateProfileViewState extends State<CreateProfileView> {
  String _accountType = "Artist";
  TextEditingController _firstNameField;
  TextEditingController _lastNameField;
  TextEditingController _venueNameField;

  //   );
  //   Column CreateVenueColumn() {
  //     return Column(
  //       children: [
  //         TextFormField(
  //           controller: _firstNameField,
  //           decoration: InputDecoration(
  //               hintText: 'Joe',
  //               labelText: 'First Name',
  //               labelStyle: TextStyle(
  //                 color: Colors.white,
  //               )),
  //         ),
  //       ],
  //     );
  //   }

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
          _accountType == "Artist"
              ? Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    TextFormField(
                      controller: _firstNameField,
                      decoration: InputDecoration(
                          hintText: 'Joe',
                          labelText: 'First Name',
                          labelStyle: TextStyle(
                            color: Colors.blue,
                          )),
                    ),
                    TextFormField(
                      controller: _lastNameField,
                      decoration: InputDecoration(
                          enabledBorder: OutlineInputBorder(
                            borderRadius:
                                BorderRadius.all(Radius.circular(10.0)),
                            borderSide: BorderSide(color: Colors.grey),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius:
                                BorderRadius.all(Radius.circular(10.0)),
                            borderSide: BorderSide(color: Colors.grey),
                          ),
                          hintText: 'Bloggs',
                          labelText: 'Last Name',
                          labelStyle: TextStyle(
                            color: Colors.blue,
                          )),
                    ),
                  ],
                )
              : Column(
                  children: [
                    TextFormField(
                      controller: _venueNameField,
                      decoration: InputDecoration(
                          hintText: 'Your Venue',
                          labelText: 'Venue Name',
                          labelStyle: TextStyle(
                            color: Colors.blue,
                          )),
                    ),
                  ],
                )
        ],
      ),
    );
  }
}
