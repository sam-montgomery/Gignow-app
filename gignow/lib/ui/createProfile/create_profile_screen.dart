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
import 'package:gignow/constants.dart';
import 'package:gignow/ui/createProfile/create_profile_consts.dart';
import 'package:multi_select_flutter/multi_select_flutter.dart';

class CreateProfileScreen extends StatefulWidget {
  @override
  CreateProfileScreenState createState() => CreateProfileScreenState();
}

class CreateProfileScreenState extends State<CreateProfileScreen> {
  String _accountType = "Artist";

  CircleAvatar profilePicture = CircleAvatar(
    radius: 60.0,
    backgroundImage: AssetImage('assets/no-profile-picture.png'),
    backgroundColor: Colors.white,
  );

  static TextEditingController _nameCont = TextEditingController();
  static TextEditingController _phoneCont = TextEditingController();
  static TextEditingController _handleCont = TextEditingController();

  TextFormField nameField = generateFormField(_nameCont, 'Joe Bloggs', 'Name');
  TextFormField phoneField =
      generateFormField(_phoneCont, '0300 123 6600', 'Phone Number');
  TextFormField handleField =
      generateFormField(_handleCont, '@GigNow', 'Handle');

  String imageUrl;
  File _imageFile;
  final picker = ImagePicker();
  String downloadURL;
  FirebaseService firebaseService = FirebaseService();

  // static List<Genre> _genres = [
  //   Genre(id: 1, genre: "Pop"),
  //   Genre(id: 2, genre: "Rock"),
  //   Genre(id: 3, genre: "Metal"),
  //   Genre(id: 4, genre: "Accoustic"),
  //   Genre(id: 5, genre: "Folk")
  // ];
  static List<String> _genres = ["Pop", "Rock", "Metal", "Accoustic", "Folk"];

  static List<String> selectedGenres;

  void cleanControllers() {
    _nameCont.text = "";
    _phoneCont.text = "";
    _handleCont.text = "";
  }

  final genreSelector = MultiSelectChipField(
    items:
        _genres.map((genre) => MultiSelectItem<String>(genre, genre)).toList(),
    title: Text("Genres:"),
    headerColor: Colors.blue.withOpacity(0.5),
    decoration: BoxDecoration(
      border: Border.all(color: kButtonBackgroundColour, width: 1.8),
    ),
    selectedChipColor: Colors.blue.withOpacity(0.5),
    selectedTextStyle: TextStyle(color: Colors.blue[800]),
    onTap: (values) {
      selectedGenres = values;
    },
  );

  void updatePhoto() {
    profilePicture =
        CircleAvatar(radius: 60.0, backgroundImage: FileImage(_imageFile));
  }

  Future getImage() async {
    final pickedFile = await picker.getImage(source: ImageSource.gallery);

    setState(() {
      if (pickedFile != null) {
        _imageFile = File(pickedFile.path);
        updatePhoto();
        print(pickedFile.path);
      } else {
        print('No image selected.');
      }
    });
  }

  Future getVideo() async {
    final pickedFile = await picker.getVideo(source: ImageSource.gallery);

    if (pickedFile != null) {
      String fileName = pickedFile.path;
      firebase_storage.Reference firebaseStorageRef = firebase_storage
          .FirebaseStorage.instance
          .ref()
          .child('profile_pictures/$fileName');
      firebase_storage.UploadTask uploadTask =
          firebaseStorageRef.putFile(File(pickedFile.path));
      firebase_storage.TaskSnapshot taskSnapshot =
          await uploadTask.whenComplete(() => null);
      taskSnapshot.ref.getDownloadURL().then((value) {
        print("Done: $value");
      });
    } else {
      print('No image selected.');
    }
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
        if (_accountType == "Venue") {
          firebaseService.createVenueProfile(_nameCont.text, _phoneCont.text,
              _handleCont.text, selectedGenres.toList().join(","), value);
        } else if (_accountType == "Artist") {
          firebaseService.createArtistProfile(_nameCont.text, _phoneCont.text,
              _handleCont.text, selectedGenres.toList().join(","), value);
        }
        cleanControllers();
      },
    );
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => AuthenticationWrapper()),
      (Route<dynamic> route) => false,
    );
  }

  final logo = Hero(
    tag: 'hero',
    child: ClipRRect(
      borderRadius: BorderRadius.circular(20.0), //or 15.0
      child: Container(
        height: 90.0,
        width: 175.0,
        color: Colors.transparent,
        child: Image.asset('assets/logo-blue-black-trimmed.png'),
      ),
    ),
  );

  @override
  Widget build(BuildContext context) {
    final firebaseUser = context.watch<User>();
    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: <Widget>[
          SizedBox(height: 50),
          logo,
          Text("Are you a... ",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          SizedBox(height: 15),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Text("Artist: "),
              Radio(
                value: "Artist",
                groupValue: _accountType,
                onChanged: (String value) {
                  setState(() {
                    _accountType = value;
                  });
                },
              ),
              Text(" or a "),
              Text("Venue: "),
              Radio(
                value: "Venue",
                groupValue: _accountType,
                onChanged: (String value) {
                  setState(() {
                    _accountType = value;
                  });
                },
              ),
            ],
          ),
          SizedBox(height: 15),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              profilePicture,
              TextButton(
                  child: Text(
                    'Upload Image',
                    style: TextStyle(color: kHintColor),
                  ),
                  onPressed: () {
                    getImage();
                  }),
            ],
          ),
          Expanded(
            child: ListView(
              //mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                Padding(padding: const EdgeInsets.all(8.0), child: nameField),
                Padding(padding: const EdgeInsets.all(8.0), child: phoneField),
                Padding(padding: const EdgeInsets.all(8.0), child: handleField),
                Padding(
                    padding: const EdgeInsets.all(8.0), child: genreSelector),
                Padding(
                  padding:
                      EdgeInsets.symmetric(vertical: kButtonVerticalPadding),
                  child: RaisedButton(
                    shape: RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(kButtonCircularPadding),
                    ),
                    onPressed: () {
                      createProfileAndUploadImageToFirebase(
                          context, firebaseUser.uid);
                    },
                    padding: EdgeInsets.all(kButtonAllPadding),
                    color: kButtonBackgroundColour,
                    child: Text('Register Account',
                        style: TextStyle(color: kButtonTextColour)),
                  ),
                ),
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
