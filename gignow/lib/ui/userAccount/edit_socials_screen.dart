import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:gignow/model/user.dart';
import 'package:gignow/net/firebase_service.dart';
import 'package:gignow/ui/loading.dart';

import '../../constants.dart';

class EditSocialsScreen extends StatefulWidget {
  UserModel userModel;
  EditSocialsScreen(this.userModel);
  @override
  _EditSocialsScreenState createState() => _EditSocialsScreenState();
}

class _EditSocialsScreenState extends State<EditSocialsScreen> {
  FirebaseService firebaseService = FirebaseService();
  FirebaseAuth auth = FirebaseAuth.instance;
  static TextEditingController _spotifyCont = TextEditingController();
  static TextEditingController _soundcloudCont = TextEditingController();
  static TextEditingController _instaCont = TextEditingController();
  static TextEditingController _facebookCont = TextEditingController();
  Map<String, String> socials = new Map<String, String>();

  TextFormField spotifyField = generateFormField(
      _spotifyCont, '23fqKkggKUBHNkbKtXEls4', 'Spotify Artist Code');
  TextFormField soundcloudField =
      generateFormField(_soundcloudCont, 'calvinharris', 'SoundCloud Username');
  TextFormField instaField =
      generateFormField(_instaCont, 'kanyewest', 'Instagram @');
  TextFormField facebookField = generateFormField(_facebookCont,
      'https://www.facebook.com/ronanmcsorleymusic/', 'Facebook URL');

  updateSocials() {
    if (_spotifyCont.text.isNotEmpty) {
      socials.addAll({
        "SpotifyURL": "https://open.spotify.com/artist/" + _spotifyCont.text
      });
    }
    if (_soundcloudCont.text.isNotEmpty) {
      socials.addAll(
          {"SoundCloudURL": "https://soundcloud.com/" + _soundcloudCont.text});
    }
    if (_instaCont.text.isNotEmpty) {
      String instaURL = "https://www.instagram.com/${_instaCont.text}";
      Map<String, String> instaMap = {"InstaURL": instaURL};
      // socials.addAll(instaMap);
      socials
          .addAll({"InstaURL": "https://www.instagram.com/${_instaCont.text}"});
    }
    if (_facebookCont.text.isNotEmpty) {
      socials.addAll({"FacebookURL": _facebookCont.text});
    }
    firebaseService.updateSocials(widget.userModel.uid, socials);
  }

  @override
  Widget build(BuildContext context) {
    _instaCont.clear();
    _facebookCont.clear();
    _spotifyCont.clear();
    _soundcloudCont.clear();
    return FutureBuilder(
        future: firebaseService.getUser(auth.currentUser.uid),
        builder: (context, snapshot) {
          if (snapshot.hasData &&
              snapshot.connectionState == ConnectionState.done) {
            UserModel user = snapshot.data;
            Map<String, String> userSocials = user.socials;
            if (userSocials.containsKey("SpotifyURL")) {
              _spotifyCont.text = userSocials['SpotifyURL']
                  .split("https://open.spotify.com/artist/")[1];
            }
            if (userSocials.containsKey("SoundCloudURL")) {
              _soundcloudCont.text = userSocials['SoundCloudURL']
                  .split("https://soundcloud.com/")[1];
            }
            if (userSocials.containsKey("InstaURL")) {
              _instaCont.text = userSocials['InstaURL']
                  .split("https://www.instagram.com/")[1];
            }
            if (userSocials.containsKey("FacebookURL")) {
              _facebookCont.text = userSocials['FacebookURL'];
            }
            return Scaffold(
              appBar: AppBar(
                iconTheme: IconThemeData(color: Colors.black),
                title: Text(
                  widget.userModel.name + "'s Socials",
                  style: TextStyle(color: Colors.black),
                ),
                centerTitle: true,
                backgroundColor: Colors.white,
              ),
              body: Column(
                children: [
                  Padding(
                      padding: const EdgeInsets.all(8.0), child: spotifyField),
                  Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: soundcloudField),
                  Padding(
                      padding: const EdgeInsets.all(8.0), child: instaField),
                  Padding(
                      padding: const EdgeInsets.all(8.0), child: facebookField),
                  RaisedButton(
                    shape: RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(kButtonCircularPadding),
                    ),
                    onPressed: () {
                      updateSocials();
                      Navigator.pop(context);
                    },
                    padding: EdgeInsets.all(kButtonAllPadding),
                    color: kButtonBackgroundColour,
                    child: Text('Update Socials',
                        style: TextStyle(color: kButtonTextColour)),
                  ),
                ],
              ),
            );
          } else {
            return Loading();
          }
        });
  }
}

TextFormField generateFormField(_cont, _hint, _label) {
  return TextFormField(
    controller: _cont,
    keyboardType: TextInputType.emailAddress,
    autofocus: false,
    decoration: InputDecoration(
      hintText: _hint,
      labelText: _label,
      contentPadding: EdgeInsets.fromLTRB(kDefaultPadding, kHalfDefaultPadding,
          kDefaultPadding, kHalfDefaultPadding),
      border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(kFormBorderRadius)),
    ),
  );
}
