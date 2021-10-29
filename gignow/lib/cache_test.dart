import 'dart:io';

import 'package:file/src/interface/file.dart';
import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:gignow/ui/loading.dart';
import 'package:video_player/video_player.dart';

class CacheTest extends StatefulWidget {
  @override
  _CacheTestState createState() => _CacheTestState();
}

class _CacheTestState extends State<CacheTest> {
  @override
  Widget build(BuildContext context) {
    VideoPlayerController _controller;

    var vidURL =
        "https://firebasestorage.googleapis.com/v0/b/gignow-402c6.appspot.com/o/videos%2Fvideo-2021-10-21%2018%3A48%3A37.842094?alt=media&token=8a9d4f99-c35f-48fb-9e01-01b6149f1276";
    Future<File> vid = DefaultCacheManager().getSingleFile(vidURL);
    return Scaffold(
        appBar: null,
        body: Column(
          children: [
            FutureBuilder<File>(
              future: DefaultCacheManager().getSingleFile(vidURL),
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  try {
                    _controller = VideoPlayerController.file(snapshot.data);
                    _controller.initialize();
                    return AspectRatio(
                        aspectRatio: _controller.value.aspectRatio,
                        child: Stack(
                            alignment: Alignment.bottomCenter,
                            children: <Widget>[VideoPlayer(_controller)]));
                  } catch (e) {
                    return Loading();
                  }
                } else {
                  return Center(child: Text("Video Loading"));
                }
              },
            ),
          ],
        ));
  }
}
