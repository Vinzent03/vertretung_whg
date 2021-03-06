import 'package:Vertretung/otherWidgets/loading_dialog.dart';
import 'package:Vertretung/services/auth_service.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class LogInWidget extends StatelessWidget {
  LogInWidget({Key key}) : super(key: key);
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  void logIn(context) async {
    LoadingDialog ld = LoadingDialog(context);
    ld.show();
    String err = await AuthService().signInEmail(
        email: emailController.text, password: passwordController.text);
    if (err != null) {
      ld.hide();
      final SnackBar snack = SnackBar(
        content: Text(err),
        backgroundColor: Colors.red,
      );
      ScaffoldMessenger.of(context).showSnackBar(snack);
    } else {
      ld.hide();
      if (!kIsWeb) Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AutofillGroup(
      child: Column(
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
            keyboardType: TextInputType.emailAddress,
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
          ElevatedButton(
              child: Text("Anmelden"), onPressed: () => logIn(context)),
          TextButton(
            child: Text("Passwort vergessen"),
            onPressed: () async {
              await AuthService().resetPassword(emailController.text);
            },
          )
        ],
      ),
    );
  }
}
