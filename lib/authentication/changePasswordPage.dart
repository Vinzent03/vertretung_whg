import 'package:flutter/material.dart';
import 'package:Vertretung/services/authService.dart';

class ChangePasswordPage extends StatelessWidget {
  final TextEditingController oldPasswordController = TextEditingController();
  final TextEditingController newPasswordController = TextEditingController();

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
                    ListTile(
                      title: RaisedButton(
                        child: Text("Bestätigen"),
                        onPressed: () async {
                          String err = await AuthService().changePassword(
                              oldPassword: oldPasswordController.text,
                              newPassword: newPasswordController.text);
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
