import 'dart:io';

import 'package:flutter/material.dart';
import 'package:gignow/constants.dart';
import 'package:gignow/net/firebase_service.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;

class PostForm extends StatefulWidget {
  @override
  _PostFormState createState() => _PostFormState();
}

class _PostFormState extends State<PostForm> {
  TextEditingController _desc = TextEditingController();
  File _videoFile;
  final picker = ImagePicker();
  String downloadURL;
  FirebaseService firebaseService = FirebaseService();

  Future getVideo() async {
    final pickedFile = await picker.getVideo(source: ImageSource.gallery);

    setState(() {
      _videoFile = File(pickedFile.path);
    });
    // if (pickedFile != null) {
    //   var now = DateTime.now();
    //   String fileName = "video-" + now.toString();
    //   firebase_storage.Reference firebaseStorageRef = firebase_storage
    //       .FirebaseStorage.instance
    //       .ref()
    //       .child('videos/$fileName');
    //   firebase_storage.UploadTask uploadTask =
    //       firebaseStorageRef.putFile(File(pickedFile.path));
    //   firebase_storage.TaskSnapshot taskSnapshot =
    //       await uploadTask.whenComplete(() => null);
    //   taskSnapshot.ref.getDownloadURL().then((value) {
    //     print("Done: $value");
    //   });
    // } else {
    //   print('No video selected.');
    // }
  }

  Future createPost() async {
    var now = DateTime.now();
    String fileName = "video-" + now.toString();
    firebase_storage.Reference firebaseStorageRef = firebase_storage
        .FirebaseStorage.instance
        .ref()
        .child('videos/$fileName');
    firebase_storage.UploadTask uploadTask =
        firebaseStorageRef.putFile(_videoFile);
    firebase_storage.TaskSnapshot taskSnapshot =
        await uploadTask.whenComplete(() => null);
    taskSnapshot.ref.getDownloadURL().then((value) {
      print("Done: $value");

      firebaseService.createVideoPost(
          "testemail", "testname", now, _desc.text, value);
    });
    Navigator.pushNamed(context, '/');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          SizedBox(height: 100),
          TextFormField(
            controller: _desc,
            decoration: InputDecoration(
              hintText: 'Post Description',
              contentPadding: EdgeInsets.fromLTRB(kDefaultPadding,
                  kHalfDefaultPadding, kDefaultPadding, kHalfDefaultPadding),
              border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(kFormBorderRadius)),
            ),
          ),
          RaisedButton(
              child: Text("Upload Video"),
              onPressed: () {
                getVideo();
              }),
          RaisedButton(
              child: Text("Submit Post"),
              onPressed: () {
                createPost();
              }),
        ],
      ),
    );
  }
}
