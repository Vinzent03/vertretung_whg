import 'package:Vertretung/authentication/login_widget.dart';
import 'package:Vertretung/authentication/registration_widget.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

enum AuthTypes { logIn, registration }

class LogInPage extends StatelessWidget {
  final authType;

  const LogInPage({Key key, @required this.authType}) : super(key: key);

  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
            authType == AuthTypes.registration ? "Registrieren" : "Anmelden"),
      ),
      body: Center(
        child: Card(
          elevation: 3,
          child: Container(
            padding: EdgeInsets.all(30),
            child: authType == AuthTypes.registration
                ? RegistrationWidget()
                : LogInWidget(),
          ),
        ),
      ),
    );
  }
}
