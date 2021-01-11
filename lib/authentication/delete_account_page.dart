import 'package:Vertretung/provider/user_data.dart';
import 'package:Vertretung/services/auth_service.dart';
import 'package:flutter/material.dart';
import 'package:progress_dialog/progress_dialog.dart';
import 'package:provider/provider.dart';

class DeleteAccountPage extends StatefulWidget {
  @override
  _DeleteAccountPageState createState() => _DeleteAccountPageState();
}

class _DeleteAccountPageState extends State<DeleteAccountPage> {
  TextEditingController passwordController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Account löschen"),
      ),
      body: Builder(
        builder: (context) {
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
                      Text("Passwort bestätigen:"),
                      TextFormField(
                        obscureText: true,
                        controller: passwordController,
                      ),
                      SizedBox(
                        height: 20,
                      ),
                      Text(
                        "Dieser Vorgang kann nicht rückgängig gemacht werden!",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      SizedBox(
                        height: 20,
                      ),
                      ListTile(
                        title: RaisedButton(
                          child: Text("Konto löschen"),
                          color: Colors.red,
                          onPressed: () async {
                            AuthService auth = AuthService();
                            ProgressDialog pr = ProgressDialog(context,
                                isDismissible: false, showLogs: false);
                            await pr.show();
                            String authRes = await auth
                                .reAuthenticate(passwordController.text);
                            if (authRes != null) {
                              await pr.hide();
                              return ScaffoldMessenger.of(context)
                                  .showSnackBar(SnackBar(
                                content: Text(authRes),
                                backgroundColor: Colors.red,
                              ));
                            }
                            await auth.signOut(
                              Provider.of<UserData>(context, listen: false),
                              deleteAccount: true,
                            );
                            await pr.hide();
                            Navigator.popUntil(
                                context,
                                ModalRoute.withName(
                                    Navigator.defaultRouteName));
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}