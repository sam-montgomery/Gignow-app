import 'package:flutter/material.dart';
import 'package:gignow/model/user.dart';
import 'package:url_launcher/url_launcher.dart';

class SocialsScreen extends StatefulWidget {
  UserModel userModel;
  SocialsScreen(this.userModel);
  @override
  _SocialsScreenState createState() => _SocialsScreenState();
}

class _SocialsScreenState extends State<SocialsScreen> {
  List<ListTile> socialTiles = [];
  @override
  Widget build(BuildContext context) {
    socialTiles.clear();
    Map<String, String> userSocials = widget.userModel.socials;
    if (userSocials.containsKey("SpotifyURL")) {
      socialTiles.add(linkTile("spotify", userSocials['SpotifyURL']));
    }
    if (userSocials.containsKey("SoundCloudURL")) {
      socialTiles.add(linkTile("soundcloud", userSocials['SoundcloudURL']));
    }
    if (userSocials.containsKey("InstaURL")) {
      socialTiles.add(linkTile("instagram", userSocials['InstaURL']));
    }
    if (userSocials.containsKey("FacebookURL")) {
      socialTiles.add(linkTile("facebook", userSocials['FacebookURL']));
    }
    return Scaffold(
        appBar: AppBar(
            backgroundColor: Colors.white,
            title: Text(
              widget.userModel.name + "'s Socials",
              style: TextStyle(color: Colors.black),
            ),
            centerTitle: true,
            iconTheme: IconThemeData(
              color: Colors.black,
            )),
        body: ListView.builder(
            itemCount: socialTiles.length,
            itemBuilder: (context, index) {
              return Card(child: socialTiles[index]);
            }));
  }
}

ListTile linkTile(String platform, String url) {
  return ListTile(
      tileColor: Colors.white,
      leading: Image.asset('assets/$platform.png'),
      onTap: () {
        _launchURL(url);
      },
      title: Text(
        '${platform[0].toUpperCase()}${platform.substring(1)}',
        style: TextStyle(color: Colors.black),
      ) //Capitalises First Letter of Platform
      );
}

void _launchURL(String _url) async =>
    await canLaunch(_url) ? await launch(_url) : throw 'Could not launch $_url';
