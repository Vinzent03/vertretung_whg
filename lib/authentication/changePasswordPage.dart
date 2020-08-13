import 'package:flutter/material.dart';
import 'package:Vertretung/services/authService.dart';

class ChangePasswordPage extends StatelessWidget {
  final TextEditingController oldPasswordController = TextEditingController();
  final TextEditingController newPasswordController = TextEditingController();
  final TextEditingController newPasswordConfirmController =
      TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Password ändern"),
      ),
      body: Builder(builder: (context) {
        return Center(
          child: SingleChildScrollView(
            child: Card(
              elevation: 3,
              child: Container(
                padding: EdgeInsets.all(30),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    SizedBox(
                      height: 20,
                    ),
                    Text("Altes Passwort:"),
                    TextFormField(
                      obscureText: true,
                      controller: oldPasswordController,
                    ),
                    SizedBox(
                      height: 20,
                    ),
                    Text("Neues Passwort:"),
                    TextFormField(
                      obscureText: true,
                      controller: newPasswordController,
                    ),
                    SizedBox(
                      height: 20,
                    ),
                    Text("Neues Passwort bestätigen:"),
                    TextFormField(
                      obscureText: true,
                      controller: newPasswordConfirmController,
                    ),
                    SizedBox(
                      height: 20,
                    ),
                    ListTile(
                      title: RaisedButton(
                        child: Text("Bestätigen"),
                        onPressed: () async {
                          AuthService auth = AuthService();
                          if (newPasswordController.text !=
                              newPasswordConfirmController.text)
                            return Scaffold.of(context).showSnackBar(SnackBar(
                              content: Text(
                                  "Die beiden neuen Passwörter sind nicht identisch."),
                              behavior: SnackBarBehavior.floating,
                              backgroundColor: Colors.red,
                            ));
                          String authRes = await auth
                              .reAuthenticate(oldPasswordController.text);
                          if (authRes != null) {
                            return Scaffold.of(context).showSnackBar(SnackBar(
                              content: Text(authRes),
                              backgroundColor: Colors.red,
                            ));
                          }
                          String changePasswordRes = await auth.changePassword(
                              oldPassword: oldPasswordController.text,
                              newPassword: newPasswordController.text);
                          if (changePasswordRes != null)
                            return Scaffold.of(context).showSnackBar(SnackBar(
                              content: Text(changePasswordRes),
                              backgroundColor: Colors.red,
                            ));
                          Navigator.pop(context);
                        },
                      ),
                    )
                  ],
                ),
              ),
            ),
          ),
        );
      }),
    );
  }
}
