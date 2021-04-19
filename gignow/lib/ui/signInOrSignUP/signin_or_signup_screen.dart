import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:form_field_validator/form_field_validator.dart';
import 'package:gignow/net/authentication_service.dart';
import 'package:gignow/ui/home_view.dart';
import 'package:provider/provider.dart';
import 'package:gignow/constants.dart';
import 'package:gignow/widgets/form_button.dart';

class SignInOrSignUp extends StatefulWidget {
  @override
  SignInOrSignUpState createState() => SignInOrSignUpState();
}

//https://github.com/yogitakumar/loginform_validation_demo

class SignInOrSignUpState extends State<SignInOrSignUp> {
  TextEditingController _emailField = TextEditingController();
  TextEditingController _passwordField = TextEditingController();
  TextEditingController _registerPasswordField = TextEditingController();
  bool signInMode = true;
  bool invalidLoginCreds = false;
  String invalidRegisterText = "";
  bool invalidRegister = false;
  GlobalKey<FormState> formkey = GlobalKey<FormState>();

  String validatePassword(String value) {
    if (value.isEmpty) {
      return "* Required";
    } else if (value.length < 6) {
      return "Password should be at least 6 characters";
    } else if (value.length > 15) {
      return "Password should not be greater than 15 characters";
    } else
      return null;
  }

  //https://github.com/putraxor/flutter-login-ui
  @override
  Widget build(BuildContext context) {
    final logo = Hero(
      tag: 'hero',
      child: CircleAvatar(
        backgroundColor: Colors.transparent,
        radius: kLogoRadius,
        child: Image.asset('assets/logo-blue-black.png'),
      ),
    );

    final email = TextFormField(
      controller: _emailField,
      keyboardType: TextInputType.emailAddress,
      autofocus: false,
      decoration: InputDecoration(
        hintText: 'Email',
        contentPadding: EdgeInsets.fromLTRB(kDefaultPadding,
            kHalfDefaultPadding, kDefaultPadding, kHalfDefaultPadding),
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(kFormBorderRadius)),
      ),
      validator: MultiValidator([
        RequiredValidator(errorText: "* Required"),
        EmailValidator(errorText: "Invalid Email"),
      ]),
    );
    final invalidLoginLabel = Text("Invalid Login Credentials",
        style: TextStyle(backgroundColor: kErrorColor, color: Colors.white));

    final invalidRegisterLabel = Text(invalidRegisterText,
        style: TextStyle(backgroundColor: kErrorColor, color: Colors.white));

    final password = TextFormField(
      controller: _passwordField,
      autofocus: false,
      obscureText: true,
      decoration: InputDecoration(
        hintText: 'Password',
        contentPadding: EdgeInsets.fromLTRB(kDefaultPadding,
            kHalfDefaultPadding, kDefaultPadding, kHalfDefaultPadding),
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(kFormBorderRadius)),
      ),
    );

    final registerPassword = TextFormField(
        controller: _registerPasswordField,
        autofocus: false,
        obscureText: true,
        decoration: InputDecoration(
          hintText: 'Password',
          contentPadding: EdgeInsets.fromLTRB(kDefaultPadding,
              kHalfDefaultPadding, kDefaultPadding, kHalfDefaultPadding),
          border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(kFormBorderRadius)),
        ),
        validator: MultiValidator([
          RequiredValidator(errorText: "* Required"),
          MinLengthValidator(6,
              errorText: "Password should be at least 6 characters"),
          MaxLengthValidator(15,
              errorText: "Password should not be greater than 15 characters")
        ]));

    final loginButton = FormButton(
        press: () async {
          try {
            bool loginSuccess = await context
                .read<AuthenticationService>()
                .signIn(
                    email: _emailField.text.trim(),
                    password: _passwordField.text.trim());
            if (!loginSuccess) {
              setState(() {
                invalidLoginCreds = true;
              });
            }
          } catch (e) {
            setState(() {
              invalidLoginCreds = true;
            });
          }
        },
        text: "Log In");

    final registerButton = FormButton(
        press: () async {
          try {
            String registerResult = await context
                .read<AuthenticationService>()
                .signUp(
                    email: _emailField.text.trim(),
                    password: _registerPasswordField.text.trim());
            if (registerResult != null) {
              setState(() {
                invalidRegister = true;
                invalidRegisterText = registerResult;
              });
            } else {
              setState(() {
                invalidRegister = false;
              });
            }
          } on FirebaseAuthException catch (e) {
            print(e.code);
          }
        },
        text: "Register");

    final forgotLabel = FlatButton(
      child: Text(
        'Forgot password?',
        style: TextStyle(color: kHintColor),
      ),
      onPressed: () {},
    );

    final registerLabel = FlatButton(
      child: Text(
        'No Account? Register',
        style: TextStyle(color: kHintColor),
      ),
      onPressed: () {
        _emailField.clear();
        _passwordField.clear();
        setState(() {
          signInMode = false;
          invalidLoginCreds = false;
          invalidRegister = false;
        });
      },
    );

    final signInLabel = FlatButton(
      child: Text(
        'Already Registered? Sign In',
        style: TextStyle(color: kHintColor),
      ),
      onPressed: () {
        _emailField.clear();
        _passwordField.clear();
        setState(() {
          signInMode = true;
          invalidLoginCreds = false;
          invalidRegister = false;
        });
      },
    );

    return Scaffold(
      backgroundColor: kBackgroundColour,
      body: Center(
        child: Form(
          autovalidate: true,
          key: formkey,
          child: ListView(
            shrinkWrap: true,
            padding: EdgeInsets.only(left: 24.0, right: 24.0),
            children: <Widget>[
              logo,
              SizedBox(height: 48.0),
              invalidLoginCreds
                  ? invalidLoginLabel
                  : invalidRegister
                      ? invalidRegisterLabel
                      : Text(""),
              SizedBox(
                height: 8.0,
              ),
              email,
              SizedBox(height: 8.0),
              signInMode ? password : registerPassword,
              SizedBox(height: 24.0),
              signInMode ? loginButton : registerButton,
              signInMode ? registerLabel : signInLabel
            ],
          ),
        ),
      ),
    );
    // return Scaffold(
    //   body: Container(
    //     width: MediaQuery.of(context).size.width,
    //     height: MediaQuery.of(context).size.height,
    //     decoration: BoxDecoration(
    //       color: Colors.blue,
    //     ),
    //     child: Column(
    //       mainAxisAlignment: MainAxisAlignment.spaceEvenly,
    //       children: <Widget>[
    //         TextFormField(
    //           controller: _emailField,
    //           decoration: InputDecoration(
    //               hintText: 'example@example.com',
    //               labelText: 'Email',
    //               labelStyle: TextStyle(
    //                 color: Colors.white,
    //               )),
    //         ),
    //         TextFormField(
    //           controller: _passwordField,
    //           obscureText: true,
    //           decoration: InputDecoration(
    //               hintText: 'Password',
    //               labelText: 'Password',
    //               labelStyle: TextStyle(
    //                 color: Colors.white,
    //               )),
    //         ),
    //         Container(
    //           width: MediaQuery.of(context).size.width / 1.4,
    //           height: 40,
    //           decoration: BoxDecoration(
    //             color: Colors.white,
    //             borderRadius: BorderRadius.circular(15.0),
    //           ),
    //           child: MaterialButton(
    //             onPressed: () {
    //               context.read<AuthenticationService>().signUp(
    //                   email: _emailField.text.trim(),
    //                   password: _passwordField.text.trim());
    //             },
    //             child: Text("Register"),
    //           ),
    //         ),
    //         Container(
    //           width: MediaQuery.of(context).size.width / 1.4,
    //           height: 40,
    //           decoration: BoxDecoration(
    //             borderRadius: BorderRadius.circular(15.0),
    //             color: Colors.white,
    //           ),
    //           child: MaterialButton(
    //             onPressed: () {
    //               context.read<AuthenticationService>().signIn(
    //                   email: _emailField.text.trim(),
    //                   password: _passwordField.text.trim());
    //             },
    //             child: Text("Login"),
    //           ),
    //         ),
    //       ],
    //     ),
    //   ),
    // );
  }
}
