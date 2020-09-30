import 'package:Vertretung/authentication/logInWidget.dart';
import 'package:Vertretung/authentication/registrationWidget.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class LogInPage extends StatefulWidget {
  final authType;

  const LogInPage({Key key, @required this.authType}) : super(key: key);

  @override
  _LogInPageState createState() => _LogInPageState();
}

enum AuthTypes { logIn, registration }

class _LogInPageState extends State<LogInPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.authType == AuthTypes.registration
            ? "Registrieren"
            : "Anmelden"),
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Card(
            elevation: 3,
            child: Container(
              padding: EdgeInsets.all(30),
              child: widget.authType == AuthTypes.registration
                  ? RegistrationWidget()
                  : LogInWidget(),
            ),
          ),
        ),
      ),
    );
  }
}
