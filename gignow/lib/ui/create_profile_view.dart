import 'dart:io';
import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:gignow/main.dart';
import 'package:gignow/net/authentication_service.dart';
import 'package:gignow/net/firebase_service.dart';
import 'package:gignow/ui/home_view.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:flutter/widgets.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter/foundation.dart';

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
  String imageUrl;
  File _imageFile;
  final picker = ImagePicker();
  String downloadURL;
  FirebaseService firebaseService = FirebaseService();

  Future getImage() async {
    final pickedFile = await picker.getImage(source: ImageSource.camera);

    setState(() {
      if (pickedFile != null) {
        _imageFile = File(pickedFile.path);
        print(pickedFile.path);
      } else {
        print('No image selected.');
      }
    });
  }

  Future createProfileAndUploadImageToFirebase(
      BuildContext context, String userUid) async {
    //final firebaseUser = context.watch<User>();
    String fileName = "profile_picture_" + userUid;
    firebase_storage.Reference firebaseStorageRef = firebase_storage
        .FirebaseStorage.instance
        .ref()
        .child('profile_pictures/$fileName');
    firebase_storage.UploadTask uploadTask =
        firebaseStorageRef.putFile(_imageFile);
    firebase_storage.TaskSnapshot taskSnapshot =
        await uploadTask.whenComplete(() => null);
    taskSnapshot.ref.getDownloadURL().then(
      (value) {
        print("Done: $value");
        firebaseService.createArtistProfile(_firstNameField.text,
            _lastNameField.text, _phoneField.text, _genreField.text, value);
      },
    );
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => AuthenticationWrapper()),
      (Route<dynamic> route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final firebaseUser = context.watch<User>();

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
              ? Expanded(
                  child: ListView(
                    //mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: <Widget>[
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
                            getImage();
                          },
                          child: Text("Select Profile Picture"),
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
                            createProfileAndUploadImageToFirebase(
                                context, firebaseUser.uid);
                          },
                          child: Text("Create Profile"),
                        ),
                      )
                    ],
                  ),
                )
              : Expanded(
                  child: ListView(
                    children: <Widget>[
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
                          onPressed: () {
                            getImage();
                          },
                          child: Text("Select Profile Picture"),
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
                            //uploadImageToFirebase(context);
                            Navigator.push(context,
                                MaterialPageRoute(builder: (context) {
                              return HomeView();
                            }));
                          },
                          child: Text("Create Profile"),
                        ),
                      )
                    ],
                  ),
                ),
        ],
      ),
    );
  }
}

class ImageSelector extends StatefulWidget {
  @override
  _ImageSelectorState createState() => _ImageSelectorState();
}

class _ImageSelectorState extends State<ImageSelector> {
  String imageUrl;
  File _imageFile;
  final picker = ImagePicker();

  Future getImage() async {
    final pickedFile = await picker.getImage(source: ImageSource.gallery);

    setState(() {
      if (pickedFile != null) {
        _imageFile = File(pickedFile.path);
        print(pickedFile.path);
      } else {
        print('No image selected.');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Upload Image')),
      body: Column(
        children: <Widget>[
          (imageUrl != null)
              ? Image.network(imageUrl)
              : Placeholder(
                  fallbackHeight: 200.0, fallbackWidth: double.infinity),
          SizedBox(
            height: 20.0,
          ),
          RaisedButton(
            child: Text('Upload Image'),
            color: Colors.lightBlue,
            onPressed: getImage,
          )
        ],
      ),
    );
  }

  Future uploadImageToFirebase(BuildContext context) async {
    String fileName = _imageFile.path;
    firebase_storage.Reference firebaseStorageRef = firebase_storage
        .FirebaseStorage.instance
        .ref()
        .child('uploads/$fileName');
    firebase_storage.UploadTask uploadTask =
        firebaseStorageRef.putFile(_imageFile);
    firebase_storage.TaskSnapshot taskSnapshot =
        await uploadTask.whenComplete(() => null);
    taskSnapshot.ref.getDownloadURL().then(
          (value) => print("Done: $value"),
        );
  }

  // uploadImage() async {
  //   final _storage = FirebaseStorage.instance;
  //   final _picker = ImagePicker();
  //   PickedFile image;

  //   //Check Permissions
  //   await Permission.photos.request();

  //   var permissionStatus = await Permission.photos.status;

  //   if (permissionStatus.isGranted) {
  //     //Select Image
  //     image = await _picker.getImage(source: ImageSource.gallery);
  //     var file = File(image.path);

  //     if (image != null) {
  //       //Upload to Firebase
  //       var snapshot = await _storage
  //           .ref()
  //           .child('folderName/imageName')
  //           .putFile(file)
  //           .whenComplete(() => null);

  //       var downloadUrl = await snapshot.ref.getDownloadURL();

  //       setState(() {
  //         imageUrl = downloadUrl;
  //       });
  //     } else {
  //       print('No Path Received');
  //     }
  //   } else {
  //     print('Grant Permissions and try again');
  //   }
  // }
}
