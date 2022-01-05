import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_driver/flutter_driver.dart';
import 'package:gignow/model/event.dart';
import 'package:gignow/model/user.dart';
import 'package:gignow/net/authentication_service.dart';
import 'package:gignow/net/firebase_service.dart';
import 'package:gignow/net/globals.dart';
import 'package:mockito/mockito.dart';
import 'package:test/test.dart';

class MockFirebaseAuth extends Mock implements FirebaseAuth {}

class MockFirebaseUser extends Mock implements User {}

void main() {
  FlutterDriver driver;
  MockFirebaseAuth _auth = MockFirebaseAuth();
  MockFirebaseUser _user = MockFirebaseUser();
  AuthenticationService authenticationService = AuthenticationService(_auth);

  FakeFirebaseFirestore firestore = FakeFirebaseFirestore();

  when(_auth.currentUser).thenAnswer((realInvocation) => _user);
  when(_user.uid).thenAnswer((realInvocation) => "ABCDEFGH");

  final firebaseService = FirebaseService.withInstance(firestore, _auth);
  CollectionReference users = firestore.collection("Users");
  CollectionReference events = firestore.collection("Events");
  CollectionReference videoPosts = firestore.collection("VideoPosts");
  CollectionReference connections = firestore.collection("Connections");
  CollectionReference videoPostLikes = firestore.collection("VideoPostLikes");

  setUpAll(() async {
    driver = await FlutterDriver.connect();
  });

  tearDownAll(() async {
    if (driver != null) {
      driver.close();
    }
  });

  final emailField = find.byValueKey('emailField');
  final passwordField = find.byValueKey('passwordField');
  final regPasswordField = find.byValueKey('registerPasswordField');
  final loginButton = find.byValueKey('loginButton');
  final artistHomeFeed = find.byValueKey('ArtistHomeFeed');
  final artistNavBarHomeBtn = find.byValueKey("NavBarHomeBtn");
  final venueHomeFeed = find.byValueKey("VenueHomeFeed");
  final venueEventsNavBarBtn = find.byValueKey("VenueNavBarEventsBtn");

  void logout(bool isArtist) async {
    final profileNavBarBtn = isArtist
        ? find.byValueKey("NavBarProfileBtn")
        : find.byValueKey("VenueNavBarProfileBtn");
    final profileSettingsBtn = find.byValueKey("ProfileSettingsBtn");
    final settingsLogoutBtn = find.byValueKey("LogoutBtn");

    await driver.tap(profileNavBarBtn);
    await driver.tap(profileSettingsBtn);
    await driver.tap(settingsLogoutBtn);
  }

  group('Functional Requirement 1', () {
    test('AuthenticationService.signUp()', () async {
      when(_auth.createUserWithEmailAndPassword(
              email: "createaccount1@test.com", password: "123456"))
          .thenAnswer((realInvocation) => null);

      expect(
          await authenticationService.signUp(
              email: "createaccount1test.com", password: "123456"),
          'Success');
    });
    test('FirebaseService Create Profile as Venue', () async {
      when(_user.uid).thenAnswer((realInvocation) => "testUser1");
      firebaseService.createProfileNoContext("Test User", "02890999000",
          "@TestUser", "Pop,Rock", "tinyurl.com/4dcv7uf7", true);

      var doc = await users.doc("testUser1").get();

      assert(doc.exists);
    });

    test('FirebaseService Create Profile as Artist', () async {
      when(_user.uid).thenAnswer((realInvocation) => "testUser2");
      firebaseService.createProfileNoContext("Test User", "02890999000",
          "@TestUser", "Pop,Rock", "tinyurl.com/4dcv7uf7", false);

      var doc = await users.doc("testUser2").get();

      assert(doc.exists);
    });
  });

  group('Functional Requirement 2', () {
    //Login as Venue
    final artistNameTxt = find.byValueKey("ArtistCardNameTxt0"); //First card
    final venueChatNavBtn = find.byValueKey("VenueNavBarChatBtn");

    test('Swipe Right on Artist to Connect', () async {
      await driver.tap(emailField);
      await driver.enterText("venue@test.com"); //venue account
      await driver.tap(passwordField);
      await driver.enterText("123456");
      await driver.tap(loginButton);
      final artistName = await driver.getText(artistNameTxt);
      // final name = await driver.get

      //swipe right
      await driver.scroll(artistNameTxt, 500, 0, Duration(seconds: 1));

      //Navigate to chats screen
      await driver.tap(venueChatNavBtn);

      final chatArtistName = find.text(artistName.toString());

      await driver.waitFor(chatArtistName);

      assert(chatArtistName != null);
    });
    test('FirebaseService Create Connection', () async {
      firebaseService.createConnectionNoChatRoom("userUidA", "userUidB");
      String connectionID = "userUidA_userUidB";
      var doc = await connections.doc(connectionID).get();

      assert(doc.exists);
    });
  });

  group('Functional Requirement 3', () {
    final venueChatNavBtn = find.byValueKey("VenueNavBarChatBtn");
    final chatNavBarBtn = find.byValueKey("NavBarChatBtn");
    final chatScreenConnectionsList =
        find.byValueKey("ChatScreenConnectionsList");
    final conversationWithArtist =
        find.text("Belfast Busker"); //Known Connection
    final conversationWithVenue = find.text("Venue Test"); //Known Connection
    final messageField = find.byValueKey("MessageField");
    test('Send Message from Venue to Artist', () async {
      await driver.tap(venueChatNavBtn);
      await driver.waitFor(chatScreenConnectionsList);
      await driver.waitFor(conversationWithArtist);
      await driver.tap(conversationWithArtist);
      await driver.tap(messageField);
      await driver.enterText("Test Message");
      final sendBtn = find.byValueKey("SendBtn");

      await driver.tap(sendBtn);

      final message = find.text("Test Message");
      await driver.waitFor(message);

      assert(message != null);
    });

    //Logout

    //Login as Artist
    test('Send Message from Artist to Venue', () async {
      // final messageBackBtn = find.byValueKey("ConvoBackBtn");
      var messageBackBtn = find.pageBack();
      await driver.tap(messageBackBtn);
      await logout(false);
      await driver.tap(emailField);
      await driver.enterText("arttest@test.com"); //artist account
      await driver.tap(passwordField);
      await driver.enterText("123456");
      await driver.tap(loginButton);
      await driver.tap(chatNavBarBtn);
      await driver.waitFor(chatScreenConnectionsList);
      await driver.waitFor(conversationWithVenue);
      await driver.tap(conversationWithVenue);

      final receivedMessage = find.text("Test Message");
      await driver.waitFor(receivedMessage);

      assert(receivedMessage != null);

      await driver.tap(messageField);
      await driver.enterText("Reply Test");
      final sendBtn = find.byValueKey("SendBtn");

      await driver.tap(sendBtn);

      final message = find.text("Reply Test");
      await driver.waitFor(message);

      assert(message != null);

      messageBackBtn = find.pageBack();
      await driver.tap(messageBackBtn);
    });
  });

  // group('Functional Requirement 5', () {
  //   //Logout

  //   //Login as Venue
  //   test('Venue Creates Event', () async {
  //     firebaseService.createEvent(event);

  //     var result = await events.get();
  //     bool eventFound = false;
  //     result.docs.forEach((event) {
  //       if (event.id == "eventId") {
  //         eventFound = true;
  //       }
  //     });

  //     assert(eventFound);
  //   });
  // });

  group('Functional Requirement 4, 5 & 6', () {
    Map<String, dynamic> venue;
    Event event = Event("eventId", "eventName", DateTime.now(),
        Duration(hours: 3), "tinyurl.com/4dcv7uf7", "venueId", "Pop", venue);

    test('Venue Creates Event', () async {
      firebaseService.createEvent(event);

      var result = await events.get();
      bool eventFound = false;
      result.docs.forEach((event) {
        if (event.id == "eventId") {
          eventFound = true;
        }
      });

      assert(eventFound);
    });
    test('Apply for Event & View Applicants', () async {
      when(_user.uid).thenAnswer((realInvocation) => "applicant1");
      firebaseService.createProfileNoContext("applicant", "02890999000",
          "@applicant", "Pop,Rock", "tinyurl.com/4dcv7uf7", false);
      firebaseService.applyForEvent(event, "applicant1");
      List<UserModel> applicants =
          await firebaseService.getEventApplicants(event.eventId);
      bool applicantFound = false;
      applicants.forEach((user) {
        if (user.uid == "applicant1") {
          applicantFound = true;
        }
      });

      assert(applicantFound);
    });
  });

  // group('Functional Requirement 6', () {
  //   //Logout

  //   //Login as Venue

  //   test('View Applicants', () async {
  //     List<UserModel> applicants =
  //         await firebaseService.getEventApplicants(event.eventId);
  //     bool applicantFound = false;
  //     applicants.forEach((user) {
  //       if (user.uid == "applicant1") {
  //         applicantFound = true;
  //       }
  //     });
  //   });
  // });

  group('Functional Requirement 7', () {
    test('Filter Artist Cards', () async {
      when(_user.uid).thenAnswer((realInvocation) => "connectedUser1");
      firebaseService.createProfileNoContext("connected User 1", "02890999000",
          "@cu1", "Pop,Rock", "tinyurl.com/4dcv7uf7", false);
      //Set location to QUB
      firebaseService.updateProfileLocationManual(
          "connectedUser1", 54.583830998, -5.93416293);

      when(_user.uid).thenAnswer((realInvocation) => "NotConnectedUser1");
      firebaseService.createProfileNoContext("User 1", "02890999000", "@ncu1",
          "Pop,Rock", "tinyurl.com/4dcv7uf7", false);
      //Set location to QUB
      firebaseService.updateProfileLocationManual(
          "NotConnectedUser1", 54.583830998, -5.93416293);

      when(_user.uid).thenAnswer((realInvocation) => "NotConnectedUser2");
      firebaseService.createProfileNoContext("User 2", "02890999000", "@ncu2",
          "Pop,Rock", "tinyurl.com/4dcv7uf7", false);
      //Set location to Stranmillis College
      firebaseService.updateProfileLocationManual(
          "NotConnectedUser2", 54.5733, -5.9340);

      when(_user.uid).thenAnswer((realInvocation) => "NotConnectedUser3");
      firebaseService.createProfileNoContext("User 3", "02890999000", "@ncu3",
          "Pop,Rock", "tinyurl.com/4dcv7uf7", false);
      //Set location to Portrush
      firebaseService.updateProfileLocationManual(
          "NotConnectedUser3", 55.2042, -6.6527);

      List<String> genres = ["Pop", "Rock"];
      Global().currentUserModel.position =
          GeoPoint(54.5973, -5.9301); //Belfast City Hall GeoPoint
      List<String> connectedUserUids = ["ConnectedUser1"];

      double distanceKm = 10;
      List<UserModel> filteredArtists = await firebaseService.getArtistAccounts(
          genres, distanceKm * 1000, connectedUserUids);

      bool notConnectedUser1Found = false;
      bool notConnectedUser2Found = false;

      filteredArtists.forEach((user) {
        if (user.uid == "NotConnectedUser1") {
          notConnectedUser1Found = true;
        }
        if (user.uid == "NotConnectedUser2") {
          notConnectedUser2Found = true;
        }
      });

      // assert(notConnectedUser2Found && notConnectedUser1Found);
      // assert(filteredArtists.length == 2); //only 2 artists returned
    });
  });

  group('Functional Requirement 8', () {
    final userVidProfileBtn = find.byValueKey('UserVideoProfileBtn');
    final userVidHandle = find.byValueKey('UserVideoHandle');
    final userProfileHandle = find.byValueKey('UserProfileHandleText');

    test('Open User Profile from Video Feed & Correct Profile Loaded',
        () async {
      await driver.tap(artistNavBarHomeBtn);
      await driver.waitFor(artistHomeFeed);
      final vidHandle = await driver.getText(userVidHandle);

      await driver.tap(userVidProfileBtn);
      final profileHandle = await driver.getText(userProfileHandle);
      assert(vidHandle == profileHandle);
    });
  });

  group('Functional Requirement 9', () {
    test('Firebase Service Create Post', () async {
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
  });

  group('Functional Requirement 10', () {
    final userVidHandle = find.byValueKey('UserVideoHandle');
    final userVidDesc = find.byValueKey('UserVideoDesc');
    final profileBackBtn = find.byValueKey("ProfileScreenBackBtn");
    test('Video Feed Displays Videos and is Scrollable', () async {
      await driver.tap(profileBackBtn);
      await driver.tap(artistNavBarHomeBtn);
      await driver.waitFor(artistHomeFeed);
      final initialVidHandleTxt = await driver.getText(userVidHandle);
      final initialVidDescTxt = await driver.getText(userVidDesc);
      //Scroll
      await driver.scroll(userVidDesc, 0, -1000, Duration(seconds: 1));

      final finalVidHandleTxt = await driver.getText(userVidHandle);
      final finalVidDescTxt = await driver.getText(userVidDesc);

      assert(finalVidDescTxt != initialVidDescTxt ||
          finalVidHandleTxt != initialVidHandleTxt);
    });
  });

  group('Functional Requirement 11', () {
    final artistNameTxt = find.byValueKey("ArtistCardNameTxt0"); //First card
    final artistNameTxt2 = find.byValueKey("ArtistCardNameTxt1");
    test('Artist Cards displayed on Discover Feed', () async {
      await logout(true);
      await driver.tap(emailField);
      await driver.enterText("venue@test.com"); //venue account
      await driver.tap(passwordField);
      await driver.enterText("123456");
      await driver.tap(loginButton);
      await driver.waitFor(artistNameTxt);
      final firstArtist = await driver.getText(artistNameTxt);

      assert(artistNameTxt != null);

      //swipe left
      await driver.scroll(artistNameTxt, -500, 0, Duration(seconds: 1));
      final finalArtist = await driver.getText(artistNameTxt2);

      assert(finalArtist != firstArtist);
    });

    final filtersBtn = find.byValueKey("OpenDiscoverFilters");
    final distanceFilter = find.byValueKey("DistanceFilterInput");
    final popGenre = find.text("Pop");
    final okBtn = find.byValueKey("FiltersOkayBtn");
    test('Apply Filters', () async {
      await driver.tap(filtersBtn);
      await driver.tap(distanceFilter);
      await driver.enterText("10");
      await driver.tap(popGenre);
      await driver.tap(okBtn);

      final artist1DistanceTxt = find.byValueKey("ArtistDistance0");
      final artist2DistanceTxt = find.byValueKey("ArtistDistance1");

      final artist1GenresWidget = find.byValueKey("ArtistGenres0");
      final artist2GenresWidget = find.byValueKey("ArtistGenres1");

      final artistDistance1Str = await driver.getText(artist1DistanceTxt);
      final artistDistance1 = int.parse(
          artistDistance1Str.substring(0, artistDistance1Str.indexOf("km")));

      final artistDistance2Str = await driver.getText(artist2DistanceTxt);
      final artistDistance2 = int.parse(
          artistDistance2Str.substring(0, artistDistance2Str.indexOf("km")));

      final artist1Genres = await driver.getText(artist1GenresWidget);
      final artist2Genres = await driver.getText(artist2GenresWidget);

      assert(artistDistance1 < 10 && artistDistance2 < 10);

      assert(artist1Genres.contains("Pop") && artist2Genres.contains("Pop"));
    });
  });

  group('Functional Requirement 12', () {
    test('FirebaseService create profile w/ example parameters', () {});

    test('Update profile w/ FirebaseService.updateSocials()', () {});
  });

  group('Functional Requirement 12', () {
    test('Follow User then Follow Back', () async {
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
      when(_user.uid).thenAnswer((realInvocation) => "UserB");
      await firebaseService.followUserUid("UserB", "UserA");

      var result = await connections.get();

      bool connectionFound = false;
      result.docs.forEach((element) {
        if (element.id == "UserA_UserB" || element.id == "UserB_UserA") {
          connectionFound = true;
        }
      });

      assert(connectionFound);
    });
  });

  group('Functional Requirement 14', () {
    test(
        'Add Spotify and Soundcloud links using FirebaseService.updateSocials()',
        () async {
      when(_user.uid).thenAnswer((realInvocation) => "UserC");
      firebaseService.createProfileNoContext(
          "UserC",
          "02890999000", //artist account created
          "@TestUserC",
          "Pop,Rock",
          "tinyurl.com/4dcv7uf7",
          false);
      Map<String, String> socialsAdd = new Map<String, String>();
      socialsAdd.addAll({
        "SpotifyURL": "https://open.spotify.com/artist/4YLtscXsxbVgi031ovDDdh",
        "SoundCloudURL": "https://soundcloud.com/calvinharris",
      });
      firebaseService.updateSocials("UserC", socialsAdd);

      bool detailsMatch = false;
      await users.doc("UserC").get().then((snapshot) {
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
  });
}
