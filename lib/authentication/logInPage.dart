import 'package:Vertretung/services/authService.dart';
import 'package:flutter/material.dart';

class LogInPage extends StatefulWidget {
  @override
  _LogInPageState createState() => _LogInPageState();
}

class _LogInPageState extends State<LogInPage> {
  bool isRegistration = true;
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController passwordConfirmController = TextEditingController();

  _buildLogInPage(context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        SizedBox(
          height: 20,
        ),
        Text("Email:"),
        TextFormField(
          controller: emailController,
        ),
        SizedBox(
          height: 20,
        ),
        Text("Passwort:"),
        TextFormField(
          obscureText: true,
          controller: passwordController,
        ),
        SizedBox(
          height: 20,
        ),
        ListTile(
          title: RaisedButton(
            child: Text("Anmelden"),
            onPressed: () async {
              String err = await AuthService().signInEmail(
                  email: emailController.text,
                  password: passwordController.text,
                  context: context);
              if (err != null) {
                final SnackBar snack = SnackBar(
                  content: Text(err),
                  backgroundColor: Colors.red,
                );
                Scaffold.of(context).showSnackBar(snack);
              } else {
                Navigator.pop(context);
              }
            },
          ),
        ),
        ListTile(
          dense: true,
          title: FlatButton(
            child: Text("Passwort vergessen"),
            onPressed: () async {
              String err =
                  await AuthService().resetPassword(emailController.text);
              if (err != null) {
                final SnackBar snack = SnackBar(
                  content: Text(err),
                  backgroundColor: Colors.red,
                );
                Scaffold.of(context).showSnackBar(snack);
              }
            },
          ),
        ),
      ],
    );
  }

  _buildRegistrationPage(context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        SizedBox(
          height: 20,
        ),
        Text("Email:"),
        TextFormField(
          controller: emailController,
        ),
        SizedBox(
          height: 20,
        ),
        Text("Passwort:"),
        TextFormField(
          obscureText: true,
          controller: passwordController,
        ),
        SizedBox(
          height: 20,
        ),
        Text("Passwort bestätigen:"),
        TextFormField(
          obscureText: true,
          controller: passwordConfirmController,
        ),
        SizedBox(
          height: 20,
        ),
        ListTile(
          title: RaisedButton(
            child: Text("Registrieren"),
            onPressed: () async {
              if (passwordController.text != passwordConfirmController.text)
                return Scaffold.of(context).showSnackBar(SnackBar(
                  content: Text("Die beiden Passwörter sind nicht identisch."),
                  behavior: SnackBarBehavior.floating,
                  backgroundColor: Colors.red,
                ));
              String err = await AuthService().signUp(
                  email: emailController.text,
                  password: passwordController.text);
              if (err != null) {
                final SnackBar snack = SnackBar(
                  content: Text(err),
                  backgroundColor: Colors.red,
                );
                Scaffold.of(context).showSnackBar(snack);
              } else {
                Navigator.pop(context);
              }
            },
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    isRegistration = ModalRoute.of(context).settings.arguments;
    return Scaffold(
      appBar: AppBar(
        title: Text(isRegistration ? "Registrieren" : "Anmelden"),
      ),
      body: Builder(
        builder: (context) {
          return Center(
            child: SingleChildScrollView(
              child: Card(
                elevation: 3,
                child: Container(
                  padding: EdgeInsets.all(30),
                  child: isRegistration
                      ? _buildRegistrationPage(context)
                      : _buildLogInPage(context),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
