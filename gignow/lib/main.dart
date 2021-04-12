import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:gignow/net/authentication_service.dart';
import 'package:gignow/ui/navBar/artist_nav_bar.dart';
import 'package:gignow/ui/navBar/venue_nav_bar.dart';
import 'package:gignow/ui/signInOrSignUP/signin_or_signup_screen.dart';
import 'package:gignow/ui/chats/chats_screen.dart';
import 'package:gignow/ui/home_view.dart';
import 'package:gignow/ui/userAccount/settings_screen.dart';
import 'package:gignow/widgets/post_form.dart';
import 'package:provider/provider.dart';

import 'artist_cards/swipe_feed_page.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<AuthenticationService>(
            create: (_) => AuthenticationService((FirebaseAuth.instance))),
        StreamProvider(
            create: (context) =>
                context.read<AuthenticationService>().authStateChanges),
      ],
      child: MaterialApp(title: 'Flutter Demo', initialRoute: '/', routes: {
        '/': (context) => AuthenticationWrapper(),
        '/chat': (context) => ChatsScreen(),
        '/settings': (context) => SettingsScreen(),
        '/postvideo': (context) => PostForm(),
      }),
    );
  }
}

class AuthenticationWrapper extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final firebaseUser = context.watch<User>();

    if (firebaseUser != null) {
      return HomeView();
    }
    return SignInOrSignUp();
  }
}
