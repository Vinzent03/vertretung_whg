import 'package:Vertretung/services/authService.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class LogInWidget extends StatelessWidget {
  LogInWidget({Key key}) : super(key: key);
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  void logIn(context) async {
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
      if (!kIsWeb) Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        SizedBox(
          height: 20,
        ),
        Align(
          alignment: Alignment.centerLeft,
          child: Text("Email:"),
        ),
        TextFormField(
          autofillHints: [AutofillHints.email],
          controller: emailController,
        ),
        SizedBox(
          height: 20,
        ),
        Align(
          alignment: Alignment.centerLeft,
          child: Text("Passwort:"),
        ),
        TextFormField(
          obscureText: true,
          autofillHints: [AutofillHints.password],
          controller: passwordController,
          onFieldSubmitted: (String st) => logIn(context),
        ),
        SizedBox(
          height: 20,
        ),
        RaisedButton(child: Text("Anmelden"), onPressed: () => logIn(context)),
        FlatButton(
          child: Text("Passwort vergessen"),
          onPressed: () async {
            await AuthService().resetPassword(emailController.text);
          },
        )
      ],
    );
  }
}
