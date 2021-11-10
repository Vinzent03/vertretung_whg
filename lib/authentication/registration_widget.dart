import 'package:Vertretung/otherWidgets/loading_dialog.dart';
import 'package:Vertretung/services/auth_service.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class RegistrationWidget extends StatefulWidget {
  final String name;
  RegistrationWidget({Key key, this.name}) : super(key: key);

  @override
  State<RegistrationWidget> createState() => _RegistrationWidgetState();
}

class _RegistrationWidgetState extends State<RegistrationWidget> {
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
            autofillHints: [AutofillHints.newPassword],
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
                    .setupAccount(false, widget.name, emailController.text,
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
