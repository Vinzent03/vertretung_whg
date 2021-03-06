import 'package:Vertretung/services/auth_service.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:progress_dialog/progress_dialog.dart';

class RegistrationWidget extends StatelessWidget {
  final String name;
  RegistrationWidget({Key key, this.name}) : super(key: key);
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController passwordConfirmController = TextEditingController();

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
            autofillHints: [AutofillHints.newPassword],
            obscureText: true,
            controller: passwordController,
          ),
          SizedBox(
            height: 20,
          ),
          Align(
            alignment: Alignment.centerLeft,
            child: Text("Passwort bestätigen:"),
          ),
          TextFormField(
            obscureText: true,
            controller: passwordConfirmController,
          ),
          SizedBox(
            height: 20,
          ),
          ElevatedButton(
            child:
                Text(kIsWeb ? "Registrieren" : "Account mit Email verbinden"),
            onPressed: () async {
              LoadingDialog ld = LoadingDialog(context);
              String err;
              if (passwordController.text != passwordConfirmController.text)
                return ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                  content: Text("Die beiden Passwörter sind nicht identisch."),
                  behavior: SnackBarBehavior.floating,
                  backgroundColor: Colors.red,
                ));
              ld.show();
              if (kIsWeb) {
                await AuthService()
                    .setupAccount(false, name, emailController.text,
                        passwordController.text)
                    .catchError((e) async {
                  ld.hide();
                  final SnackBar snack = SnackBar(
                    content: Text(e),
                    backgroundColor: Colors.red,
                  );
                  ScaffoldMessenger.of(context).showSnackBar(snack);
                });
                ld.hide();
              } else {
                err = await AuthService().linkAccountWithEmail(
                    emailController.text, passwordController.text);
                ld.hide();
              }
              if (err != null) {
                final SnackBar snack = SnackBar(
                  content: Text(err),
                  backgroundColor: Colors.red,
                );
                ScaffoldMessenger.of(context).showSnackBar(snack);
              } else {
                Navigator.popUntil(
                    context, ModalRoute.withName(Navigator.defaultRouteName));
              }
            },
          ),
        ],
      ),
    );
  }
}
