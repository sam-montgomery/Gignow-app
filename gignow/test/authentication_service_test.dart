import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:gignow/net/authentication_service.dart';
import 'package:mockito/mockito.dart';
import 'package:rxdart/subjects.dart';
import 'package:test/test.dart';

class MockFirebaseAuth extends Mock implements FirebaseAuth {}

class MockFirebaseUser extends Mock implements User {}

// class MockAuthResult extends Mock implements

void main() {
  MockFirebaseAuth _auth = MockFirebaseAuth();
  BehaviorSubject<MockFirebaseUser> _user = BehaviorSubject<MockFirebaseUser>();
  AuthenticationService authenticationService = AuthenticationService(_auth);
  setUp(() {});

  tearDown(() {});
  test("Test Create Account", () async {
    // when(_auth.createUserWithEmailAndPassword(
    //         email: "createaccount1@test.com", password: "123456"))
    //     .thenAnswer((realInvocation) => null);

    expect(
        await authenticationService.signUp(
            email: "createaccount1test.com", password: "123456"),
        'Success');
    expect(
        await authenticationService.signUp(
            email: "createaccount1@test.com", password: "123456"),
        'Success');
  });
}

// void main() async {
//   await Firebase.initializeApp();
//   // AuthenticationService authenticationService =
//   //     AuthenticationService(FirebaseAuth.instance);
//   // test('Successful Login Test', () async {
//   //   bool loginSuccess = await authenticationService.signIn(
//   //       email: "test@test.com", password: "12346");
//   //   expect(true, loginSuccess);
//   // });
//   AuthenticationService authenticationService =
//       AuthenticationService(FirebaseAuth.instance);
//   test('test', () {});
//   test('Successful Login Test', () async {
//     bool loginSuccess = await authenticationService.signIn(
//         email: "test@test.com", password: "12346");
//     expect(true, loginSuccess);
//     expect(true, true);
//   });
// }
