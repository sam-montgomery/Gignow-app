import 'package:flutter/material.dart';
import 'package:gignow/model/video_post.dart';
import 'package:gignow/net/firebase_service.dart';
import 'package:gignow/ui/loading.dart';
import 'package:gignow/widgets/video_post_widget.dart';
import '../model/user.dart';
import 'profile_card_alignment.dart';

class ProfileView extends StatefulWidget {
  UserModel artist;
  ProfileView(this.artist);
  @override
  _ProfileViewState createState() => _ProfileViewState();
}

class _ProfileViewState extends State<ProfileView> {
  FirebaseService firebaseService = FirebaseService();
  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: firebaseService.getUsersVideoPosts(widget.artist.uid),
        builder: (builder, snapshot) {
          if (snapshot.hasData &&
              snapshot.connectionState == ConnectionState.done) {
            List<VideoPost> posts = snapshot.data;
            return Scaffold(
              body: ListView(
                padding: EdgeInsets.all(16),
                children: [
                  buildImageCard(),
                  buildQuoteCard(),
                  buildVideoCard(posts)
                ],
              ),
            );
          } else {
            return Loading();
          }
        });
  }

  Widget buildImageCard() => Card(
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            Ink.image(
              image: NetworkImage(widget.artist.profilePictureUrl),
              child: InkWell(
                onTap: () {},
              ),
              height: 240,
              fit: BoxFit.cover,
            ),
            Text(
              widget.artist.name,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.white,
                fontSize: 24,
              ),
              textAlign: TextAlign.left,
            ),
          ],
        ),
      );

  Widget buildQuoteCard() => Card(
        child: Padding(
          padding: EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.artist.genres,
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
            ],
          ),
        ),
      );

  Widget buildVideoCard(List<VideoPost> posts) => Card(
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
        child: posts.length > 0
            ? VideoPostWidget(posts[0])
            : Stack(
                alignment: Alignment.center,
                children: [
                  Text(
                    'No video post available',
                    style: TextStyle(
                      fontWeight: FontWeight.normal,
                      color: Colors.black,
                      fontSize: 20,
                    ),
                  ),
                  const SizedBox(height: 240),
                ],
              ),
      );
}
