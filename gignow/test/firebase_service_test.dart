import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
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
  test('FakeFirestore Test', () async {
    // await firestore.collection('test').doc("ABC").set({
    //   'message': 'Hello world!',
    //   'created_at': FieldValue.serverTimestamp(),
    // });

    var createdDoc = await firestore.collection('test').doc("ABC").get();
    assert(createdDoc.exists);

    // assert(firebaseService.test() == "ABCDEFGH");
  });
}
