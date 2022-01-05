import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:gignow/model/event.dart';
import 'package:gignow/model/user.dart';
import 'package:gignow/model/video_post.dart';
import 'package:gignow/net/authentication_service.dart';
import 'package:gignow/net/firebase_service.dart';
import 'package:gignow/net/globals.dart';
import 'package:mockito/mockito.dart';
import 'package:rxdart/subjects.dart';
import 'package:test/test.dart';

class MockFirebaseAuth extends Mock implements FirebaseAuth {}

class MockFirebaseUser extends Mock implements User {}

// class MockAuthResult extends Mock implements

void main() {
  MockFirebaseAuth _auth = MockFirebaseAuth();
  MockFirebaseUser _user = MockFirebaseUser();
  AuthenticationService authenticationService = AuthenticationService(_auth);
  setUp(() {});

  tearDown(() {});

  FakeFirebaseFirestore firestore = FakeFirebaseFirestore();

  when(_auth.currentUser).thenAnswer((realInvocation) => _user);
  when(_user.uid).thenAnswer((realInvocation) => "ABCDEFGH");

  final firebaseService = FirebaseService.withInstance(firestore, _auth);
  CollectionReference users = firestore.collection("Users");
  CollectionReference events = firestore.collection("Events");
  CollectionReference videoPosts = firestore.collection("VideoPosts");
  CollectionReference connections = firestore.collection("Connections");
  CollectionReference videoPostLikes = firestore.collection("VideoPostLikes");

  group('1. User Tests', () {
    test('1.1 Create Profile', () async {
      when(_user.uid).thenAnswer((realInvocation) => "testUser1");
      firebaseService.createProfileNoContext("Test User", "02890999000",
          "@TestUser", "Pop,Rock", "tinyurl.com/4dcv7uf7", false);

      var doc = await users.doc("testUser1").get();

      assert(doc.exists);
    });

    test('1.2 Get User', () async {
      UserModel testUser = await firebaseService.getUser("testUser1");
      assert(testUser.uid == "testUser1" &&
          testUser.name == "Test User" &&
          testUser.phone == "02890999000" &&
          testUser.handle == "@TestUser" &&
          testUser.genres == "Pop,Rock" &&
          testUser.profilePictureUrl == "tinyurl.com/4dcv7uf7" &&
          testUser.venue == false);
    });

    test('1.3 Get Profile Picture URL', () async {
      String url = await firebaseService.getProfilePicURL("testUser1");
      assert(url == "tinyurl.com/4dcv7uf7");
    });

    test('1.4 Update Socials', () async {
      Map<String, String> socialsAdd = new Map<String, String>();
      socialsAdd.addAll({
        "SpotifyURL": "https://open.spotify.com/artist/4YLtscXsxbVgi031ovDDdh",
        "SoundCloudURL": "https://soundcloud.com/calvinharris",
      });
      firebaseService.updateSocials("testUser1", socialsAdd);

      bool detailsMatch = false;
      await users.doc("testUser1").get().then((snapshot) {
        if (snapshot.exists) {
          Map<String, dynamic> dataMap =
              snapshot.data() as Map<String, dynamic>;
          Map<String, String> socials = new Map<String, String>();

          if (dataMap.containsKey("socials")) {
            var x = snapshot.get('socials');
            x.keys.forEach((item) {
              // print(item);
              // print(x[item]);
              socials.addAll({item: x[item]});
            });
          }

          if (socials["SpotifyURL"] ==
                  "https://open.spotify.com/artist/4YLtscXsxbVgi031ovDDdh" &&
              socials["SoundCloudURL"] ==
                  "https://soundcloud.com/calvinharris") {
            detailsMatch = true;
          }
        }
      });
      assert(detailsMatch);
    });

    test('1.5 Follow User', () async {
      when(_user.uid).thenAnswer((realInvocation) => "UserA");
      firebaseService.createProfileNoContext(
          "UserA",
          "02890999000", //artist account created
          "@TestUserA",
          "Pop,Rock",
          "tinyurl.com/4dcv7uf7",
          false);
      when(_user.uid).thenAnswer((realInvocation) => "UserB");
      firebaseService.createProfileNoContext(
          "UserB",
          "02890999000", //artist account created
          "@TestUserB",
          "Pop,Rock",
          "tinyurl.com/4dcv7uf7",
          false);

      when(_user.uid).thenAnswer((realInvocation) => "UserA");
      await firebaseService.followUserUid("UserA", "UserB");

      // var userA_doc = await users.doc("UserA");

      UserModel userA = await firebaseService.getUser("UserA");

      List<dynamic> following = userA.following;
      DocumentReference ref = users.doc("UserB");
      assert(following.contains(ref));
    });

    //

    test('1.6 Get Follower Count', () async {
      when(_user.uid).thenAnswer((realInvocation) => "UserC");
      firebaseService.createProfileNoContext(
          "UserC",
          "02890999000", //artist account created
          "@TestUserB",
          "Pop,Rock",
          "tinyurl.com/4dcv7uf7",
          false);

      await firebaseService.followUserUid("UserC", "UserA");
      await firebaseService.followUserUid("UserB", "UserA");

      int followerCount = await firebaseService.getFollowerCount("UserA");

      assert(followerCount == 2);
    });
  });

  group('2. Video Post Tests', () {
    test('2.1 Create Video Post', () async {
      DateTime postTime = DateTime.now();
      when(_user.uid).thenAnswer((realInvocation) => "TestVideoPostUser");
      Global().currentUserModel.genres = "Pop";
      firebaseService.createVideoPost(
          postTime,
          "Test Video Post",
          "https://www.youtube.com/watch?v=JTJKNA8EroA",
          "tinyurl.com/4dcv7uf7");

      var result = await videoPosts.get();

      bool postCreated = false;
      result.docs.forEach((element) {
        if (element.exists) {
          DocumentReference userRef = element['user'];
          String desc = element['postDescription'];
          Timestamp postDate = element['postDate'];

          if (userRef.id == "TestVideoPostUser" &&
              desc == "Test Video Post" &&
              Timestamp.fromDate(postTime) == postDate) {
            postCreated = true;
          }
        }
      });

      assert(postCreated);
    });

    DateTime postTime = DateTime.now();
    test('2.2 Like Video', () async {
      when(_user.uid).thenAnswer((realInvocation) => "TestVideoPostUser2");

      Global().currentUserModel.genres = "Pop";
      firebaseService.createVideoPost(
          postTime,
          "Test Video Post",
          "https://www.youtube.com/watch?v=JTJKNA8EroA",
          "tinyurl.com/4dcv7uf7");

      when(_user.uid).thenAnswer((realInvocation) => "TestVideoPostUser2");
      var result = await videoPosts.get();
      VideoPost post;
      result.docs.forEach((element) {
        if (element.exists) {
          Map<String, dynamic> dataMap = element.data() as Map<String, dynamic>;
          if (dataMap.containsKey('videoURL')) {
            DocumentReference ref = element['user'];
            String userUid = ref.id;

            if (userUid == "TestVideoPostUser2" &&
                element['postDescription'] == "Test Video Post" &&
                Timestamp.fromDate(postTime) == element['postDate']) {
              post = VideoPost(
                  element.id,
                  userUid,
                  element['postDate'],
                  element['postDescription'],
                  element['videoURL'],
                  dataMap.containsKey('thumbnailURL')
                      ? element['thumbnailURL']
                      : "https://cdn.shopify.com/s/files/1/2018/8867/files/play-button.png");
            }
          }
        }
      });

      //getVideoPostID
      //Like Video
      when(_user.uid).thenAnswer((realInvocation) => "likerUid");
      firebaseService.likeVideo(post);
      String likeId = "${post.postID}_likerUid";
      var likeDoc = await videoPostLikes.doc(likeId).get();
      assert(likeDoc.exists);
    });

    test('2.3 Unlike Video', () async {
      var result = await videoPosts.get();
      VideoPost post;
      result.docs.forEach((element) {
        if (element.exists) {
          Map<String, dynamic> dataMap = element.data() as Map<String, dynamic>;
          if (dataMap.containsKey('videoURL')) {
            DocumentReference ref = element['user'];
            String userUid = ref.id;

            if (userUid == "TestVideoPostUser2" &&
                element['postDescription'] == "Test Video Post" &&
                Timestamp.fromDate(postTime) == element['postDate']) {
              post = VideoPost(
                  element.id,
                  userUid,
                  element['postDate'],
                  element['postDescription'],
                  element['videoURL'],
                  dataMap.containsKey('thumbnailURL')
                      ? element['thumbnailURL']
                      : "https://cdn.shopify.com/s/files/1/2018/8867/files/play-button.png");
            }
          }
        }
      });
      //unlike video
      firebaseService.unLikeVideo(post);
      String likeId = "${post.postID}_likerUid";
      var likeDoc = await videoPostLikes.doc(likeId).get();
      assert(!likeDoc.exists);
      //check its not in collection
    });

    test('2.4 Get isLiked, Number of Likes and isFollowing', () async {
      var result = await videoPosts.get();
      VideoPost post;
      result.docs.forEach((element) {
        if (element.exists) {
          Map<String, dynamic> dataMap = element.data() as Map<String, dynamic>;
          if (dataMap.containsKey('videoURL')) {
            DocumentReference ref = element['user'];
            String userUid = ref.id;

            if (userUid == "TestVideoPostUser2" &&
                element['postDescription'] == "Test Video Post" &&
                Timestamp.fromDate(postTime) == element['postDate']) {
              post = VideoPost(
                  element.id,
                  userUid,
                  element['postDate'],
                  element['postDescription'],
                  element['videoURL'],
                  dataMap.containsKey('thumbnailURL')
                      ? element['thumbnailURL']
                      : "https://cdn.shopify.com/s/files/1/2018/8867/files/play-button.png");
            }
          }
        }
      });
      when(_user.uid).thenAnswer((realInvocation) => "likerUid");
      firebaseService.createProfileNoContext("User Liking", "02890999000",
          "@TestUser", "Pop,Rock", "tinyurl.com/4dcv7uf7", false);
      firebaseService.likeVideo(post);
      Map resultMap =
          await firebaseService.getIsLikedAndNumLikesAndIsFollowing(post);

      assert(resultMap["isLiked"] == true);
      assert(resultMap["numLikes"] == 1);
      assert(resultMap["isFollowing"] == false);
    });

    test('2.5 Get Video Posts', () async {
      bool testVid1Returned = false;
      bool testVid2Returned = false;

      String testVid1Uid = "";
      String testVid2Uid = "";

      DateTime postDate1 = DateTime.now();
      DateTime postDate2 = DateTime(2021, 10, 10, 17, 30);

      when(_user.uid).thenAnswer((realInvocation) => "TestVideoPostUser3");

      Global().currentUserModel.genres = "Pop";
      firebaseService.createVideoPost(
          postDate1,
          "Test Video Post 3",
          "https://www.youtube.com/watch?v=JTJKNA8EroA",
          "tinyurl.com/4dcv7uf7");

      when(_user.uid).thenAnswer((realInvocation) => "TestVideoPostUser4");

      Global().currentUserModel.genres = "Pop";
      firebaseService.createVideoPost(
          postDate2,
          "Test Video Post 4",
          "https://www.youtube.com/watch?v=JTJKNA8EroA",
          "tinyurl.com/4dcv7uf7");

      var result = await videoPosts.get();

      result.docs.forEach((element) {
        if (element.exists) {
          DocumentReference ref = element['user'];
          String userUid = ref.id;

          if (userUid == "TestVideoPostUser3" &&
              element['postDescription'] == "Test Video Post 3" &&
              Timestamp.fromDate(postDate1) == element['postDate']) {
            testVid1Uid = element.id;
          }

          if (userUid == "TestVideoPostUser4" &&
              element['postDescription'] == "Test Video Post 4" &&
              Timestamp.fromDate(postDate2) == element['postDate']) {
            testVid2Uid = element.id;
          }
        }
      });

      List<VideoPost> videoPostList = await firebaseService.getVideoPosts();

      videoPostList.forEach((element) {
        if (element.postID == testVid1Uid) {
          testVid1Returned = true;
        }
        if (element.postID == testVid2Uid) {
          testVid2Returned = true;
        }
      });

      assert(testVid1Returned && testVid2Returned);
    });
  });

  group('3. Connection Tests', () {
    test('3.1 Create Connection', () async {
      firebaseService.createConnectionNoChatRoom("userUidA", "userUidB");
      String connectionID = "userUidA_userUidB";
      var doc = await connections.doc(connectionID).get();

      assert(doc.exists);
    });

    test('3.2 Users are Connected', () async {
      bool connected =
          await firebaseService.usersAreConnected("userUidA", "userUidB");
      bool notConnected =
          await firebaseService.usersAreConnected("userUidA", "userUidC");

      assert(connected == true && notConnected == false);
    });

    test('3.3 Get User\'s Connection UIDs', () async {
      firebaseService.createConnectionNoChatRoom("userUidA", "userUidD");
      firebaseService.createConnectionNoChatRoom("userUidA", "userUidE");

      List<String> uids =
          await firebaseService.getUserConnectionsUids("userUidA");

      assert(uids.contains("userUidB") &&
          uids.contains("userUidD") &&
          uids.contains("userUidE"));
    });
  });
  group('4. Events Tests', () {
    test('4.1 Create Event', () async {
      when(_user.uid).thenAnswer((realInvocation) => "testVenue1");
      firebaseService.createProfileNoContext("Test Venue", "02890999000",
          "@TestVenue", "Pop,Rock", "tinyurl.com/4dcv7uf7", true);

      UserModel testVenue = await firebaseService.getUser("testVenue1");

      Event testEvent = new Event(
          'testVenue1-1',
          'eventName',
          DateTime.parse("2012-02-27 13:27:00"),
          Duration(hours: 2),
          'tinyurl.com/4dcv7uf7',
          'testVenue1',
          'Pop,Rock',
          testVenue.toJson());

      firebaseService.createEvent(testEvent);

      var doc = await events.doc("testVenue1-1").get();

      assert(doc.exists);
    });

    test('4.2 Apply for Event', () async {
      when(_user.uid).thenAnswer((realInvocation) => "testApplicant1");
      firebaseService.createProfileNoContext("Test Applicant", "02890999000",
          "@TestApplicant", "Pop,Rock", "tinyurl.com/4dcv7uf7", false);
      when(_user.uid).thenAnswer((realInvocation) => "testVenue1");
      firebaseService.createProfileNoContext("Test Venue", "02890999000",
          "@TestVenue", "Pop,Rock", "tinyurl.com/4dcv7uf7", true);
      UserModel testApplicant = await firebaseService.getUser("testApplicant1");
      UserModel testVenue = await firebaseService.getUser("testVenue1");

      Event testEvent = new Event(
          'testVenue1-1',
          'eventName',
          DateTime.parse("2012-02-27 13:27:00"),
          Duration(hours: 2),
          'tinyurl.com/4dcv7uf7',
          'testVenue1',
          'Pop,Rock',
          testVenue.toJson());

      firebaseService.applyForEvent(testEvent, testApplicant.uid);

      var doc = await events.doc("testVenue1-1").get();

      List<String> applicants = doc['applicants'].split(',');

      assert(applicants.contains(testApplicant.uid));
    });
    test('4.3 Accept applicant', () async {
      when(_user.uid).thenAnswer((realInvocation) => "testVenue1");
      firebaseService.createProfileNoContext("Test Venue", "02890999000",
          "@TestVenue", "Pop,Rock", "tinyurl.com/4dcv7uf7", true);
      UserModel testVenue = await firebaseService.getUser("testVenue1");

      Event testEvent = new Event(
          'testVenue1-1',
          'eventName',
          DateTime.parse("2012-02-27 13:27:00"),
          Duration(hours: 2),
          'tinyurl.com/4dcv7uf7',
          'testVenue1',
          'Pop,Rock',
          testVenue.toJson());

      firebaseService.applyForEvent(testEvent, "testApplicant1");
      firebaseService.acceptApplicant(testEvent, "testApplicant1");

      var doc = await events.doc("testVenue1-1").get();

      String acceptedApplicant = doc['acceptedUid'];

      assert(acceptedApplicant == "testApplicant1");
    });
    test('4.4 Reject Applicant', () async {
      when(_user.uid).thenAnswer((realInvocation) => "testApplicant1");
      firebaseService.createProfileNoContext("Test Applicant", "02890999000",
          "@TestApplicant", "Pop,Rock", "tinyurl.com/4dcv7uf7", false);
      when(_user.uid).thenAnswer((realInvocation) => "testVenue1");
      firebaseService.createProfileNoContext("Test Venue", "02890999000",
          "@TestVenue", "Pop,Rock", "tinyurl.com/4dcv7uf7", true);
      UserModel testApplicant = await firebaseService.getUser("testApplicant1");
      UserModel testVenue = await firebaseService.getUser("testVenue1");

      Event testEvent = new Event(
          'testVenue1-1',
          'eventName',
          DateTime.parse("2012-02-27 13:27:00"),
          Duration(hours: 2),
          'tinyurl.com/4dcv7uf7',
          'testVenue1',
          'Pop,Rock',
          testVenue.toJson());

      firebaseService.applyForEvent(testEvent, testApplicant.uid);
      firebaseService.rejectApplicant(testEvent, testApplicant.uid);

      var doc = await events.doc("testVenue1-1").get();

      assert(doc["applicants"] == "");
    });

    test('4.5 Confirm Event', () async {
      when(_user.uid).thenAnswer((realInvocation) => "testVenue1");
      firebaseService.createProfileNoContext("Test Venue", "02890999000",
          "@TestVenue", "Pop,Rock", "tinyurl.com/4dcv7uf7", true);
      UserModel testVenue = await firebaseService.getUser("testVenue1");

      Event testEvent = new Event(
          'testVenue1-1',
          'eventName',
          DateTime.parse("2012-02-27 13:27:00"),
          Duration(hours: 2),
          'tinyurl.com/4dcv7uf7',
          'testVenue1',
          'Pop,Rock',
          testVenue.toJson());

      firebaseService.applyForEvent(testEvent, "testApplicant1");
      firebaseService.acceptApplicant(testEvent, "testApplicant1");
      firebaseService.confirmEvent(testEvent);

      var doc = await events.doc("testVenue1-1").get();

      assert(doc['confirmed'] == true);
    });
    test('4.6 Get Open Events for Venue', () async {
      when(_user.uid).thenAnswer((realInvocation) => "testVenue1");
      firebaseService.createProfileNoContext("Test Venue", "02890999000",
          "@TestVenue", "Pop,Rock", "tinyurl.com/4dcv7uf7", true);
      UserModel testVenue = await firebaseService.getUser("testVenue1");

      Event testEvent = new Event(
          'testVenue1-1',
          'eventName',
          DateTime.parse("2012-02-27 13:27:00"),
          Duration(hours: 2),
          'tinyurl.com/4dcv7uf7',
          'testVenue1',
          'Pop,Rock',
          testVenue.toJson());

      firebaseService.createEvent(testEvent);

      List<Event> events =
          await firebaseService.getOpenEventsForVenue("testVenue1");

      assert(events.length == 1);
    });

    test('4.7 Get Upcoming Events for Venue', () async {
      when(_user.uid).thenAnswer((realInvocation) => "testVenue1");
      firebaseService.createProfileNoContext("Test Venue", "02890999000",
          "@TestVenue", "Pop,Rock", "tinyurl.com/4dcv7uf7", true);
      UserModel testVenue = await firebaseService.getUser("testVenue1");

      Event testEvent = new Event(
          'testVenue1-1',
          'eventName',
          DateTime.parse("2012-02-27 13:27:00"),
          Duration(hours: 2),
          'tinyurl.com/4dcv7uf7',
          'testVenue1',
          'Pop,Rock',
          testVenue.toJson());

      firebaseService.applyForEvent(testEvent, "testApplicant1");
      firebaseService.acceptApplicant(testEvent, "testApplicant1");
      firebaseService.confirmEvent(testEvent);

      List<Event> events =
          await firebaseService.getUpcomingEventsForVenue("testVenue1");

      assert(events.length == 1);
    });
    test('4.8 Get Open Events for Artist', () async {
      when(_user.uid).thenAnswer((realInvocation) => "testVenue1");
      firebaseService.createProfileNoContext("Test Venue", "02890999000",
          "@TestVenue", "Pop,Rock", "tinyurl.com/4dcv7uf7", true);
      UserModel testVenue = await firebaseService.getUser("testVenue1");

      Event testEvent = new Event(
          'testVenue1-1',
          'eventName',
          DateTime.parse("2012-02-27 13:27:00"),
          Duration(hours: 2),
          'tinyurl.com/4dcv7uf7',
          'testVenue1',
          'Pop,Rock',
          testVenue.toJson());

      firebaseService.createEvent(testEvent);

      List<Event> events = await firebaseService.getOpenEvents();

      assert(events.length == 1);
    });

    test('4.9 Get Upcoming Events for Artist', () async {
      when(_user.uid).thenAnswer((realInvocation) => "testVenue1");
      firebaseService.createProfileNoContext("Test Venue", "02890999000",
          "@TestVenue", "Pop,Rock", "tinyurl.com/4dcv7uf7", true);
      UserModel testVenue = await firebaseService.getUser("testVenue1");

      Event testEvent = new Event(
          'testVenue1-1',
          'eventName',
          DateTime.parse("2012-02-27 13:27:00"),
          Duration(hours: 2),
          'tinyurl.com/4dcv7uf7',
          'testVenue1',
          'Pop,Rock',
          testVenue.toJson());
      firebaseService.applyForEvent(testEvent, "testApplicant1");
      firebaseService.acceptApplicant(testEvent, "testApplicant1");
      testEvent.acceptedUid = "testApplicant1";
      firebaseService.confirmEvent(testEvent);

      List<Event> events =
          await firebaseService.getUpcomingEventsForArtist("testApplicant1");

      assert(events.length == 1);
    });
  });
}
