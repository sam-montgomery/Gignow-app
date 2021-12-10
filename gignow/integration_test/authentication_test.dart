import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gignow/main.dart' as app;
import 'package:gignow/net/authentication_service.dart';
import 'package:integration_test/integration_test.dart';

void main() async {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  WidgetsFlutterBinding.ensureInitialized();
  Firebase.initializeApp();

  AuthenticationService authenticationService =
      AuthenticationService(FirebaseAuth.instance);
  testWidgets('Authentication Test', (WidgetTester tester) async {
    app.MyApp();
    await tester.pumpWidget(app.MyApp()); // Create main app
    await tester.pumpAndSettle(); // Finish animations and scheduled microtasks
    await tester.pump(Duration(seconds: 2)); // Render another frame in 2s
    bool loginResult =
        await authenticationService.signIn(email: "", password: "");
    expect(loginResult, false);
  });
}
