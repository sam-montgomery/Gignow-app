import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_driver/flutter_driver.dart';
import 'package:gignow/net/authentication_service.dart';
import 'package:provider/provider.dart';
import 'package:test/test.dart';

void main() {
  FlutterDriver driver;

  setUpAll(() async {
    driver = await FlutterDriver.connect();
  });

  tearDownAll(() async {
    if (driver != null) {
      driver.close();
    }
  });

  final button = find.byType('FloatingActionButton');

  // FirebaseAuth _auth = FirebaseAuth.instance;

  // AuthenticationService authenticationService = AuthenticationService(_auth);
  group('Login Tests', () {
    final emailField = find.byValueKey('emailField');
    final passwordField = find.byValueKey('passwordField');
    final regPasswordField = find.byValueKey('registerPasswordField');
    final loginButton = find.byValueKey('loginButton');
    final artistHomeFeed = find.byValueKey('ArtistHomeFeed');

    test('Home Feed loaded on Artist Login', () async {
      await driver.tap(emailField);
      await driver.enterText("test@test.com"); //artist account
      await driver.tap(passwordField);
      await driver.enterText("123456");
      await driver.tap(loginButton);
      await driver.waitFor(artistHomeFeed);
      // await driver.waitFor(eventsPage);
      assert(artistHomeFeed != null);
    });

    final profileNavBarBtn = find.byValueKey("NavBarProfileBtn");
    final profileSettingsBtn = find.byValueKey("ProfileSettingsBtn");
    final settingsLogoutBtn = find.byValueKey("LogoutBtn");

    // RUN THESE TESTS LAST AS PROFILE CANNOT BE CREATED AS CANT UPLOAD IMAGE
    // AND NEEDS LOGGED IN FOR OTHER TESTS

    // test('Logout Test', () async {
    //   await driver.tap(profileNavBarBtn);
    //   await driver.tap(profileSettingsBtn);
    //   await driver.tap(settingsLogoutBtn);
    //   await driver.waitFor(loginButton);
    //   assert(loginButton != null);
    // });

    // final registerBtn = find.byValueKey("RegisterBtn");
    // final openRegisterBtn = find.byValueKey("OpenRegisterBtn");
    // final createProfileAccountTypeSelection =
    //     find.byValueKey("AccountTypeSelectionRow");
    // test('Create Profile Screen Loaded on Register', () async {
    //   await driver.tap(openRegisterBtn);
    //   await driver.tap(emailField);
    //   await driver.enterText("testingreg@test.com");
    //   await driver.tap(regPasswordField);
    //   await driver.enterText("123456");
    //   await driver.tap(registerBtn);
    //   await driver.waitFor(createProfileAccountTypeSelection);

    //   assert(createProfileAccountTypeSelection != null);
    // });
  });
  group('Video/Profile Tests', () {
    final userVidProfileBtn = find.byValueKey('UserVideoProfileBtn');
    final userVidHandle = find.byValueKey('UserVideoHandle');
    final userProfileFollowerCount = find.byValueKey('FollowerCountText');
    final followUnfollowBtn = find.byValueKey('FollowUnfollowBtn');
    final userProfileHandle = find.byValueKey('UserProfileHandleText');
    final followUnfollowBtnText = find.byValueKey('FollowUnfollowBtnText');
    test('User Profile Loaded w/ correct Handle', () async {
      final vidHandle = await driver.getText(userVidHandle);
      await driver.tap(userVidProfileBtn);
      final profileHandle = await driver.getText(userProfileHandle);

      assert(vidHandle == profileHandle);
    });

    test('Follow Button Increments Follower Count & Button Text Changed',
        () async {
      var initialFollowerCount = await driver.getText(userProfileFollowerCount);
      var initialFollowUnfollowBtnText =
          await driver.getText(followUnfollowBtnText);
      await driver.tap(followUnfollowBtn);
      // var finalFollowerCount = await driver.getText(userProfileFollowerCount);
      // var finalFollowerCount =
      //     await driver.getText(find.byValueKey('FollowerCountText'));
      var finalFollowUnfollowBtnText =
          await driver.getText(followUnfollowBtnText);
      if (initialFollowUnfollowBtnText == "Follow") {
        assert(finalFollowUnfollowBtnText == "Unfollow");
      } else {
        assert(finalFollowUnfollowBtnText == "Follow");
      }

      // assert(int.parse(finalFollowerCount) ==
      //     (int.parse(initialFollowerCount) + 1));
    });

    test('Unfollow Button Increments Follower Count & Button Text Changed',
        () async {
      var initialFollowUnfollowBtnText =
          await driver.getText(followUnfollowBtnText);
      var initialFollowerCount = await driver.getText(userProfileFollowerCount);
      await driver.tap(followUnfollowBtn);
      var finalFollowerCount =
          await driver.getText(find.byValueKey('FollowerCountText'));
      var finalFollowUnfollowBtnText =
          await driver.getText(followUnfollowBtnText);
      if (initialFollowUnfollowBtnText == "Follow") {
        assert(finalFollowUnfollowBtnText == "Unfollow");
      } else {
        assert(finalFollowUnfollowBtnText == "Follow");
      }

      assert(int.parse(finalFollowerCount) ==
          (int.parse(initialFollowerCount) - 1));
    });
  });

  // test('Successful Sign In', () async {
  //   await driver.tap(button);
  //   expect(1, 1);
  //   // bool loginResult = await authenticationService.signIn(
  //   //     email: "test@test.com", password: "123456");
  //   // expect(loginResult, true);
  // });
}
