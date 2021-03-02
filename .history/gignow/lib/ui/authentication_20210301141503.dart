import 'package:flutter/material.dart';
import 'package:gignow/net/authentication_service.dart';
import 'package:gignow/ui/home_view.dart';
import 'package:provider/provider.dart';

class Authentication extends StatefulWidget {
  @override
  _AuthenticationState createState() => _AuthenticationState();
}

class _AuthenticationState extends State<Authentication> {
  TextEditingController _emailField = TextEditingController();
  TextEditingController _passwordField = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        decoration: BoxDecoration(
          color: Colors.blue,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            TextFormField(
              controller: _emailField,
              decoration: InputDecoration(
                  hintText: 'example@example.com',
                  labelText: 'Email',
                  labelStyle: TextStyle(
                    color: Colors.white,
                  )),
            ),
            TextFormField(
              controller: _passwordField,
              obscureText: true,
              decoration: InputDecoration(
                  hintText: 'Password',
                  labelText: 'Password',
                  labelStyle: TextStyle(
                    color: Colors.white,
                  )),
            ),
            Container(
              width: MediaQuery.of(context).size.width / 1.4,
              height: 40,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(15.0),
              ),
              child: MaterialButton(
                onPressed: () {
                  context.read<AuthenticationService>().signIn(
                      email: _emailField.text.trim(),
                      password: _passwordField.text.trim());
                },
                child: Text("Register"),
              ),
            ),
            Container(
              width: MediaQuery.of(context).size.width / 1.4,
              height: 40,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(15.0),
                color: Colors.white,
              ),
              child: MaterialButton(
                onPressed: () {
                  context.read<AuthenticationService>().signIn(
                      email: _emailField.text.trim(),
                      password: _passwordField.text.trim());
                },
                child: Text("Login"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
