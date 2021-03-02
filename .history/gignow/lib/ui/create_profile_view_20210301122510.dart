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
              ? CreateArtistColumn(_firstNameField, _lastNameField)
              : CreateVenueColumn(_venueNameField),
        ],
      ),
    );
  }
}

Column CreateVenueColumn(TextEditingController venueController) {
  return Column(
    children: [
      TextFormField(
        controller: venueController,
        decoration: InputDecoration(
            hintText: 'Joe',
            labelText: 'First Name',
            labelStyle: TextStyle(
              color: Colors.white,
            )),
      ),
    ],
  );
}

Column CreateArtistColumn(TextEditingController firstNameController,
    TextEditingController lastNameController) {
  Column(
    children: [
      TextFormField(
        controller: firstNameController,
        decoration: InputDecoration(
            hintText: 'Joe',
            labelText: 'First Name',
            labelStyle: TextStyle(
              color: Colors.white,
            )),
      ),
      TextFormField(
        controller: lastNameController,
        decoration: InputDecoration(
            hintText: 'Joe',
            labelText: 'Last Name',
            labelStyle: TextStyle(
              color: Colors.white,
            )),
      ),
    ],
  );
}
