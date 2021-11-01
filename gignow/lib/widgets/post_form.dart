import 'dart:io';
import 'package:path/path.dart' as path;
import 'package:flutter/material.dart';
import 'package:gignow/constants.dart';
import 'package:gignow/model/user.dart';
import 'package:gignow/net/firebase_service.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:http/http.dart' as http;
import 'package:video_compress/video_compress.dart';

class PostForm extends StatefulWidget {
  // UserModel currentUser;
  // PostForm(this.currentUser);
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
    print("Original Size: ${_videoFile.lengthSync()}");
    await compressVideo(_videoFile);
    print("Compressed Size: ${_videoFile.lengthSync()}");
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

  void compressVideo(File video) async {
    await VideoCompress.setLogLevel(0);
    final MediaInfo info = await VideoCompress.compressVideo(
      video.path,
      quality: VideoQuality.MediumQuality,
      deleteOrigin: false,
      includeAudio: true,
    );
    //print("Compressed Size: ${info.filesize}}");
    if (info != null) {
      setState(() {
        _videoFile = info.file;
        //_counter = info.path!;
      });
    }
  }

  Future<String> uploadVideo(filename, url) async {
    List<int> videoBytes = _videoFile.readAsBytesSync();
    var request = http.MultipartRequest('POST', Uri.parse(url));

    request.files.add(await http.MultipartFile.fromPath('package', filename));
    Map<String, String> videoUrl = {"videoUrl": "x"};
    request.fields.addAll(videoUrl);
    var res = await request.send();
    return res.reasonPhrase;
  }

  String state = "";

  Future createPost() async {
    // firebaseService.createVideoPost(_videoFile, DateTime.now(), _desc.text);
    // String dir = path.dirname(_videoFile.path);
    // String newPath = path.join(dir, "$videoPostId.mp4");
    // _videoFile.renameSync(newPath);
    // var res =
    //     await uploadImage(_videoFile.path, "http://192.168.1.112:3000/upload");
    // setState(() {
    //   state = res;
    //   print(res);
    // });
    var now = DateTime.now();
    String fileName = "video-" + now.toString();
    firebase_storage.Reference firebaseStorageRef = firebase_storage
        .FirebaseStorage.instance
        .ref()
        .child('videos/$fileName');
    firebase_storage.UploadTask uploadTask =
        firebaseStorageRef.putFile(_videoFile);
    firebase_storage.TaskSnapshot taskSnapshot =
        await uploadTask.whenComplete(() {});
    taskSnapshot.ref.getDownloadURL().then((value) {
      print("Done: $value");
      firebaseService.createVideoPost(now, _desc.text, value);

      //   firebaseService.createVideoPost(
      //       "testemail", "testname", now, _desc.text, value);
      // });
      Navigator.pushNamed(context, '/');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButtonLocation: FloatingActionButtonLocation.startTop,
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
