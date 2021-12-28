import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:gignow/model/user.dart';
import 'package:gignow/model/video_post.dart';

class VideoScore {
  VideoPost post;
  int score;

  VideoScore(VideoPost post, int score) {
    this.post = post;
    this.score = score;
  }
}

class VideoRankingService {
  FirebaseFirestore firestoreInstance;
  FirebaseAuth auth;
  CollectionReference users;
  CollectionReference videoPosts;

  static List<String> _genres = [
    "Pop",
    "Rock",
    "Metal",
    "Accoustic",
    "Folk",
    "Country",
    "Hip Hop",
    "Jazz",
    "Musical Theatre",
    "Punk Rock",
    "Heavy Metal",
    "Electronic",
    "Funk",
    "House",
    "Disco",
    "EDM",
    "Orchestra"
  ];
  Future<dynamic> getUserGenreScores(String userUid) async {
    var document = await users.doc(userUid);
    dynamic genreScores;
    await document.get().then((doc) {
      if (doc.exists) {
        genreScores = doc['genreScores'];
      }
    });
    return genreScores;
  }

  Future<List<String>> getUserGenres(String userUid) async {
    var document = await users.doc(userUid);
    List<String> genresList = [];
    await document.get().then((doc) {
      if (doc.exists) {
        String genres = doc['genres'];
        genresList = genres.split(",");
      }
    });
    return genresList;
  }

  Future<List<VideoScore>> getVideoScores(String likerUid) async {
    List<Map<VideoPost, int>> videoPostScoreMapList = [];
    List<VideoScore> videoScoreList = [];
    // var videoPostScoreMap = new SortedMap(Ordering.byValue());
    List<VideoPost> posts = [];
    List<int> scores = [];
    Map userGenreScores = await getUserGenreScores(likerUid);
    await videoPosts.get().then((QuerySnapshot querySnapshot) async {
      querySnapshot.docs.forEach((post) {
        Map<String, dynamic> dataMap = post.data() as Map<String, dynamic>;
        VideoPost vPost = VideoPost(
            post.id,
            post['user'].id,
            post['postDate'],
            post['postDescription'],
            post['videoURL'],
            dataMap.containsKey('thumbnailURL')
                ? post['thumbnailURL']
                : "https://cdn.shopify.com/s/files/1/2018/8867/files/play-button.png");
        List<dynamic> postGenres = post['genres'];
        int postScore = 0;
        // List<String> postGenres = await getUserGenres(post['user'].id);
        postGenres.forEach((genre) {
          // print(genre);
          postScore += userGenreScores[genre];
        });
        videoScoreList.add(new VideoScore(vPost, postScore));
      });
    });
    return videoScoreList;
  }

  Future<List<VideoPost>> getRankedVideos(String userUid) async {
    List<VideoScore> videoScores = await getVideoScores(userUid) ?? [];
    List<VideoPost> posts = [];

    videoScores.sort((a, b) => a.score.compareTo(b.score));

    videoScores.forEach((videoScore) {
      posts.add(videoScore.post);
    });

    return posts;
  }
  // Map<String, int> videoPostScoresMap = new Map<String, int>();
  // Map<String, dynamic> genreScores = new Map<String, dynamic>();
  // await liker.get().then((lUser) async {
  //   List<Map> list = [];
  //   genreScores = lUser.data()['genreScores'];
  //   var res = await videoPosts.get();
  //   res.docs.forEach((post) async {
  //     var postUser = post['user'];
  //     // VideoPost vPost = VideoPost(post.id, postUser.id, post['postDate'],
  //     //     post['postDescription'], post['videoURL']);
  //     int postScore = 0;
  //     var ps = {post.id: -1};
  //     List<String> vidGenres = [];
  //     await users.doc(postUser.id).get().then((vUser) {
  //       String strGenres = vUser['genres'];
  //       print(strGenres);
  //       vidGenres = strGenres.split(",");
  //       vidGenres.forEach((genre) {
  //         postScore += genreScores[genre];
  //         ps = {post.id: postScore};
  //         // list.add(ps);
  //       });
  //       print(postScore);
  //       list.add({post.id: postScore});
  //       // videoPostScoresMap.addAll({post.id: postScore});
  //     }).whenComplete(() {
  //       print('');
  //     });
  //   });
  //   await print('');
  // });

  // List<String> posts = [];
  // // list.forEach((element) {
  // //   print(element);
  // // });
  // videoPostScoresMap.forEach((post, score) {
  //   print("Adding Post: ${post}");
  //   posts.add(post);
  // });

  // List<VideoPost> rankPosts() {}

  // int getVideoScore(VideoPost post, String likerUid) async {
  //   var vidUser = users.doc(post.userUID);
  //   List<String> vidGenres = [];
  //   await vidUser.get().then((vUser) {
  //     String strGenres = vUser.data()['genres'];
  //     vidGenres = strGenres.split(",");
  //   });
  // }

  void rankLikeVideo(VideoPost post, String likerUid) async {
    //updates users genreScores based on liked video
    var vidUser = users.doc(post.userUID);
    List<String> vidGenres = [];
    await vidUser.get().then((vUser) {
      String strGenres = vUser['genres'];
      vidGenres = strGenres.split(",");
    });

    var likerUser = users.doc(likerUid);
    Map<String, dynamic> genreScores = new Map<String, dynamic>();
    await likerUser.get().then((lUser) {
      genreScores = lUser['genreScores'];
    });
    vidGenres.forEach((genre) {
      genreScores[genre] += 1;
    });
    users.doc(likerUid).update({"genreScores": genreScores});
  }

  void initScores() async {
    var res = await users.get();

    res.docs.forEach((doc) async {
      Map<String, int> genreScores = new Map<String, int>();
      _genres.forEach((genre) {
        genreScores.addAll({genre: 0});
      });
      await users.doc(doc.id).update({"genreScores": genreScores});
    });
  }

  Map<String, int> emptyGenreScores() {
    Map<String, int> genreScores = new Map<String, int>();
    _genres.forEach((genre) {
      genreScores.addAll({genre: 0});
    });
    return genreScores;
  }

  VideoRankingService.withInstance(
      FirebaseFirestore firestoreInstance, FirebaseAuth authInstance) {
    this.firestoreInstance = firestoreInstance;
    this.auth = authInstance;
    this.users = firestoreInstance.collection('Users');
    this.videoPosts = firestoreInstance.collection('VideoPosts');
  }

  VideoRankingService() {
    this.firestoreInstance = FirebaseFirestore.instance;
    this.auth = FirebaseAuth.instance;
    this.users = firestoreInstance.collection('Users');
    this.videoPosts = firestoreInstance.collection('VideoPosts');
  }
}
