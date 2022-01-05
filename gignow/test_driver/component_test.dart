import 'package:test/test.dart';
import 'package:flutter_driver/flutter_driver.dart';

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

  final emailField = find.byValueKey('emailField');
  final passwordField = find.byValueKey('passwordField');
  final regPasswordField = find.byValueKey('registerPasswordField');
  final loginButton = find.byValueKey('loginButton');
  final artistHomeFeed = find.byValueKey('ArtistHomeFeed');
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

  group('Login Screen Tests', () {
    test('Error message displayed on invalid login', () async {
      await driver.tap(emailField);
      await driver.enterText("test@test.com"); //artist account
      await driver.tap(passwordField);
      await driver.enterText("123456789");
      await driver.tap(loginButton);
      final errorMessage = find.text("Invalid Login Credentials");

      await driver.waitFor(errorMessage);
      // await driver.waitFor(eventsPage);
      assert(errorMessage != null);
    });

    final registerBtn = find.byValueKey("RegisterBtn");
    final openRegisterBtn = find.byValueKey("OpenRegisterBtn");
    test('Open Register Form', () async {
      await driver.tap(openRegisterBtn);
      await driver.waitFor(registerBtn);

      assert(registerBtn != null);
    });

    final openLoginBtn = find.byValueKey("OpenLoginBtn");
    test('Open Login Form', () async {
      await driver.tap(openLoginBtn);
      await driver.waitFor(loginButton);

      assert(loginButton != null);
    });
  });

  group('Video Feed Tests', () {
    //Get Current Video Details
    final userVidHandle = find.byValueKey('UserVideoHandle');
    final userVidDesc = find.byValueKey('UserVideoDesc');

    test('Scroll to next video', () async {
      await driver.tap(emailField);
      await driver.enterText("test@test.com"); //artist account
      await driver.tap(passwordField);
      await driver.enterText("123456");
      await driver.tap(loginButton);
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

    final likeUnlikeButton = find.byValueKey("likeUnlikeBtn");
    final likeCount = find.byValueKey("NumLikesTxt");
    test('Like Video', () async {
      final initialLikeCount = await driver.getText(likeCount);
      await driver.tap(likeUnlikeButton);
      final finalLikeCount = await driver.getText(likeCount);

      assert(int.parse(finalLikeCount) == (int.parse(initialLikeCount) + 1));
    });

    test('Unike Video', () async {
      final initialLikeCount = await driver.getText(likeCount);
      await driver.tap(likeUnlikeButton);
      final finalLikeCount = await driver.getText(likeCount);

      assert(int.parse(finalLikeCount) == (int.parse(initialLikeCount) - 1));
    });
  });

  group('Profile Tests', () {
    final userVidProfileBtn = find.byValueKey('UserVideoProfileBtn');
    final userProfileFollowerCount = find.byValueKey('FollowerCountText');
    final followUnfollowBtn = find.byValueKey('FollowUnfollowBtn');
    final followUnfollowBtnText = find.byValueKey('FollowUnfollowBtnText');

    test('Follow Button Increments Follower Count & Button Text Changed',
        () async {
      await driver.tap(userVidProfileBtn);
      var initialFollowerCount = await driver.getText(userProfileFollowerCount);
      var initialFollowUnfollowBtnText =
          await driver.getText(followUnfollowBtnText);
      await driver.tap(followUnfollowBtn);
      // var finalFollowerCount = await driver.getText(userProfileFollowerCount);
      // var finalFollowerCount =
      //     await driver.getText(find.byValueKey('FollowerCountText'));
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
          (int.parse(initialFollowerCount) + 1));
    });

    test('Unfollow Button Decrements Follower Count & Button Text Changed',
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

  group('Chat Tests', () {
    final profileBackBtn = find.byValueKey("ProfileScreenBackBtn");
    final chatNavBarBtn = find.byValueKey("NavBarChatBtn");
    final chatScreenConnectionsList =
        find.byValueKey("ChatScreenConnectionsList");
    test('Connections Displayed on Chats Screen', () async {
      await driver.tap(profileBackBtn);
      await driver.tap(chatNavBarBtn);
      await driver.waitFor(chatScreenConnectionsList);

      assert(chatScreenConnectionsList != null);
    });

    final conversation = find.text("Belfast City Council"); //Known Connection
    final messageField = find.byValueKey("MessageField");
    test('Open Conversation & Send Message', () async {
      await driver.waitFor(conversation);
      await driver.tap(conversation);
      await driver.tap(messageField);
      await driver.enterText("Test Message");
      final sendBtn = find.byValueKey("SendBtn");

      await driver.tap(sendBtn);

      final message = find.text("Test Message");
      await driver.waitFor(message);

      assert(message != null);
    });
  });

  group('Discover Tests', () {
    final artistNameTxt = find.byValueKey("ArtistCardNameTxt0"); //First card
    final venueChatNavBtn = find.byValueKey("VenueNavBarChatBtn");
    final backBtn = find.pageBack();
    test('Swipe Right on Artist', () async {
      await driver.tap(backBtn);
      await logout(true);
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
      final chatNavBarBtn = find.byValueKey("NavBarChatBtn");
      await driver.tap(venueChatNavBtn);

      final chatArtistName = find.text(artistName.toString());

      await driver.waitFor(chatArtistName);

      assert(chatArtistName != null);
    });
    final discoverBtn = find.byValueKey("NavBarDiscoverBtn");
    final filtersBtn = find.byValueKey("OpenDiscoverFilters");
    final distanceFilter = find.byValueKey("DistanceFilterInput");
    final popGenre = find.text("Pop");
    final okBtn = find.byValueKey("FiltersOkayBtn");

    test('Apply Filters', () async {
      await driver.tap(discoverBtn);
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
}
