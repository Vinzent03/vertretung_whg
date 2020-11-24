import 'package:Vertretung/provider/userData.dart';
import 'package:Vertretung/services/authService.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:progress_dialog/progress_dialog.dart';
import 'package:provider/provider.dart';

class LogInWidget extends StatelessWidget {
  LogInWidget({Key key}) : super(key: key);
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  void logIn(context) async {
    ProgressDialog pr =
        ProgressDialog(context, isDismissible: false, showLogs: false);
    await pr.show();
    String err = await AuthService().signInEmail(
        email: emailController.text,
        password: passwordController.text,
        provider: Provider.of<UserData>(context, listen: false));
    if (err != null) {
      await pr.hide();
      final SnackBar snack = SnackBar(
        content: Text(err),
        backgroundColor: Colors.red,
      );
      Scaffold.of(context).showSnackBar(snack);
    } else {
      await pr.hide();
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
