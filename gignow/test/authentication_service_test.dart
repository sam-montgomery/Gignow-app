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
    when(_auth.createUserWithEmailAndPassword(
            email: "createaccount1@test.com", password: "123456"))
        .thenAnswer((realInvocation) => null);

    expect(
        await authenticationService.signUp(
            email: "createaccount1test.com", password: "123456"),
        'Success');
  });

  test("Email already exists Test", () async {
    when(_auth.createUserWithEmailAndPassword(
            email: "createaccount1@test.com", password: "12345678"))
        .thenAnswer((realInvocation) => throw FirebaseAuthException(
            code: "email-already-in-use",
            message:
                "The email address is already in use by another account."));

    expect(
        await authenticationService.signUp(
            email: "createaccount1@test.com", password: "12345678"),
        "The email address is already in use by another account.");
  });

  test("Create Account w/ invalid Email Test", () async {
    when(_auth.createUserWithEmailAndPassword(
            email: "testcom", password: "123456"))
        .thenAnswer((realInvocation) => throw FirebaseAuthException(
            code: "invalid-email",
            message: "The email address is badly formatted."));

    expect(
        await authenticationService.signUp(
            email: "testcom", password: "123456"),
        "The email address is badly formatted.");
  });

  test("Login w/ valid details", () async {
    when(_auth.signInWithEmailAndPassword(
            email: "createaccount1@test.com", password: "123456"))
        .thenAnswer((realInvocation) => null);

    expect(
        await authenticationService.signIn(
            email: "createaccount1@test.com", password: "123456"),
        true);
  });

  test("Login w/ incorrect password", () async {
    when(_auth.signInWithEmailAndPassword(
            email: "createaccount1@test.com", password: "1234567"))
        .thenAnswer((realInvocation) => throw FirebaseAuthException(
            code: "wrong-password",
            message:
                "The password is invalid or the user does not have a password."));
    expect(
        await authenticationService.signIn(
            email: "createaccount1@test.com", password: "1234567"),
        false);
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
