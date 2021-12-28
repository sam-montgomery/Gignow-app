import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
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
}
