import 'package:flutter/material.dart';
import 'package:gignow/net/authentication_service.dart';
import 'package:gignow/net/firebase_service.dart';
import 'package:provider/provider.dart';

class CreateProfileView extends StatefulWidget {
  @override
  _CreateProfileViewState createState() => _CreateProfileViewState();
}

class _CreateProfileViewState extends State<CreateProfileView> {
  String _accountType = "Artist";
  TextEditingController _firstNameField = TextEditingController();
  TextEditingController _lastNameField = TextEditingController();
  TextEditingController _venueNameField = TextEditingController();
  TextEditingController _phoneField = TextEditingController();
  TextEditingController _genreField = TextEditingController();
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
    FirebaseService firebaseService = FirebaseService();
    return Scaffold(
      appBar: AppBar(
        title: Text("Create Profile"),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 20.0),
            child: GestureDetector(
              onTap: () => context.read<AuthenticationService>().signOut(),
              child: Icon(Icons.logout),
            ),
          )
        ],
      ),
      body: Column(
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
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: TextFormField(
                        controller: _firstNameField,
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
                            hintText: 'Joe',
                            labelText: 'First Name',
                            labelStyle: TextStyle(
                              color: Colors.blue,
                            )),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: TextFormField(
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
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: TextFormField(
                        controller: _phoneField,
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
                            labelText: 'Phone Number',
                            labelStyle: TextStyle(
                              color: Colors.blue,
                            )),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: TextFormField(
                        controller: _genreField,
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
                            hintText: 'Pop, Rock, etc.',
                            labelText:
                                'Genres (Seperate Each Genre With A Comma)',
                            labelStyle: TextStyle(
                              color: Colors.blue,
                            )),
                      ),
                    ),
                    Container(
                      width: MediaQuery.of(context).size.width / 2,
                      height: 40,
                      decoration: BoxDecoration(
                        color: Colors.blue,
                        borderRadius: BorderRadius.circular(15.0),
                      ),
                      child: MaterialButton(
                        onPressed: () {
                          print("test");
                          firebaseService.createArtistProfile(
                              _firstNameField.text,
                              _lastNameField.text,
                              _phoneField.text,
                              _genreField.text);
                        },
                        child: Text("Create Profile"),
                      ),
                    )
                  ],
                )
              : Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: TextFormField(
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
                            hintText: 'Your Venue',
                            labelText: 'Venue Name',
                            labelStyle: TextStyle(
                              color: Colors.blue,
                            )),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: TextFormField(
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
                            labelText: 'Phone Number',
                            labelStyle: TextStyle(
                              color: Colors.blue,
                            )),
                      ),
                    ),
                    Container(
                      width: MediaQuery.of(context).size.width / 2,
                      height: 40,
                      decoration: BoxDecoration(
                        color: Colors.blue,
                        borderRadius: BorderRadius.circular(15.0),
                      ),
                      child: MaterialButton(
                        onPressed: () async {},
                        child: Text("Create Profile"),
                      ),
                    )
                  ],
                ),
        ],
      ),
    );
  }
}
