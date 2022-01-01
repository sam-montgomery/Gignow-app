import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:gignow/model/event.dart';
import 'package:gignow/model/user.dart';
import 'package:gignow/net/authentication_service.dart';
import 'package:gignow/net/firebase_service.dart';
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

  group('User Tests', () {
    test('Create Profile', () async {
      when(_user.uid).thenAnswer((realInvocation) => "testUser1");
      firebaseService.createProfileNoContext("Test User", "02890999000",
          "@TestUser", "Pop,Rock", "tinyurl.com/4dcv7uf7", false);

      var doc = await users.doc("testUser1").get();

      assert(doc.exists);
    });

    test('Get User', () async {
      UserModel testUser = await firebaseService.getUser("testUser1");
      assert(testUser.uid == "testUser1" &&
          testUser.name == "Test User" &&
          testUser.phone == "02890999000" &&
          testUser.handle == "@TestUser" &&
          testUser.genres == "Pop,Rock" &&
          testUser.profilePictureUrl == "tinyurl.com/4dcv7uf7" &&
          testUser.venue == false);
    });

    test('Get Profile Picture URL', () async {
      String url = await firebaseService.getProfilePicURL("testUser1");
      assert(url == "tinyurl.com/4dcv7uf7");
    });

    test('Get Artist Accounts', () async {
      // List<UserModel> artists = await firebaseService.getArtistAccounts(genreFilters, distanceFilter, connectionUids)
    });
  });
  group('4 Events Testing -', () {
    test('1 Create Event', () async {
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

    test('2 Apply for Event', () async {
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
    test('3 Accept applicant', () async {
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
    test('4 Reject Applicant', () async {
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
    test('5 Get Open Events for Venue', () async {
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
    test('6 Get Open Events for Artist', () async {
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
    test('7 Confirm Event', () async {
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
    test('8 Get Upcoming Events for Venue', () async {
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
    test('9 Get Upcoming Events for Artist', () async {
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
