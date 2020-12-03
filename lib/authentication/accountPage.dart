import 'package:Vertretung/authentication/deleteAccountPage.dart';
import 'package:Vertretung/authentication/logInPage.dart';
import 'package:Vertretung/data/names.dart';
import 'package:Vertretung/provider/userData.dart';
import 'package:Vertretung/services/authService.dart';
import 'package:Vertretung/services/cloudDatabase.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class AccountPage extends StatefulWidget {
  @override
  _AccountPageState createState() => _AccountPageState();
}

class _AccountPageState extends State<AccountPage> {
  String name = "Laden";
  String email = "Laden";
  String uid = "Laden";
  bool isAnon = true;
  AuthService authService = AuthService();
  changeNameAlert(scaffoldContext) {
    final TextEditingController controller = TextEditingController();
    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(15))),
            title: Text("Gib deinen neuen Namen ein"),
            content: TextField(
              controller: controller,
            ),
            actions: <Widget>[
              FlatButton(
                child: Text("abbrechen"),
                onPressed: () => Navigator.pop(context),
              ),
              RaisedButton(
                  child: Text("Bestätigen"),
                  onPressed: () async {
                    if (controller.text.length >= 2) {
                      setState(() {
                        name = controller.text;
                      });
                      CloudDatabase().updateName(controller.text);
                      Navigator.pop(context);
                    } else {
                      final snack = SnackBar(
                        content: Text("Bitte wähle einen längeren Namen"),
                        behavior: SnackBarBehavior.floating,
                        backgroundColor: Colors.red,
                      );

                      Scaffold.of(scaffoldContext).showSnackBar(snack);
                      await Future.delayed(
                        Duration(seconds: 4),
                      ); //Erst nach den 4 Sekunden wird die Snackbar geschlossen. Keine Ahnung warum das extra nötig ist.
                      Scaffold.of(scaffoldContext).removeCurrentSnackBar();
                    }
                  }),
            ],
          );
        });
  }

  void reload() {
    CloudDatabase().getName().then((value) {
      if (mounted) setState(() => name = value);
    });
    setState(() => uid = authService.getUserId().substring(0, 5));
    setState(() => isAnon = authService.isAnon());
    if (!isAnon) {
      setState(() {
        email = authService.getEmail();
      });
    }
  }

  void deleteAccountAlert() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Account löschen"),
        content: Text(
            "Möchtest du dein Account wirklich löschen?\nDies kann nicht rückgängig gemacht werden!"),
        actions: [
          RaisedButton(
            child: Text("Bestätigen"),
            color: Colors.red,
            onPressed: () async {
              await authService
                  .signOut(Provider.of<UserData>(context, listen: false));
              Navigator.popUntil(
                  context, ModalRoute.withName(Navigator.defaultRouteName));
            },
          )
        ],
      ),
    );
  }

  @override
  void initState() {
    reload();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Dein Account"),
      ),
      body: Builder(
        builder: (context) {
          return SingleChildScrollView(
            child: Column(
              children: <Widget>[
                Card(
                  elevation: 3,
                  child: Column(
                    children: <Widget>[
                      ListTile(
                        leading: Icon(Icons.person),
                        title: Text("Dein Name: $name"),
                        subtitle: Text("Dein Freundestoken: $uid"),
                      ),
                      ListTile(
                        title: Text("Namen ändern"),
                        leading: Icon(Icons.edit),
                        onTap: () => changeNameAlert(context),
                      )
                    ],
                  ),
                ),
                Card(
                  elevation: 3,
                  child: Column(
                    children: <Widget>[
                      ListTile(
                        leading: Icon(Icons.email),
                        title: Text("Anmelde Methode:"),
                        subtitle: isAnon ? null : Text(email),
                        trailing: Padding(
                          padding: EdgeInsets.only(right: 10),
                          child: Text("${isAnon ? "Anonym" : "Email"}"),
                        ),
                      ),
                      if (!isAnon)
                        ListTile(
                          leading: Icon(Icons.security),
                          title: Text("Passwort ändern"),
                          onTap: () async {
                            Navigator.pushNamed(
                                context, Names.changePasswordPage);
                          },
                        )
                    ],
                  ),
                ),
                //Anonym
                if (isAnon)
                  Card(
                    elevation: 3,
                    child: ListTile(
                      leading: Icon(Icons.info),
                      title: Text(
                          "Zum Anmelden bitte erst Abmelden bzw. Konto löschen wenn du Anonym bist"),
                    ),
                  ),
                Card(
                  color: Colors.blue,
                  child: isAnon
                      ? ListTile(
                          title: RaisedButton(
                              color: Colors.blue,
                              elevation: 0,
                              child: Text("Account mit Email verbinden"),
                              onPressed: () async {
                                await Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (BuildContext context) =>
                                        LogInPage(
                                            authType: AuthTypes.registration),
                                  ),
                                );
                                reload();
                              }),
                        )
                      : ListTile(
                          title: RaisedButton(
                              color: Colors.blue,
                              elevation: 0,
                              child: Text("Abmelden"),
                              onPressed: () async {
                                await authService.signOut(Provider.of<UserData>(
                                    context,
                                    listen: false));
                                Navigator.popUntil(
                                    context,
                                    ModalRoute.withName(
                                        Navigator.defaultRouteName));
                              }),
                        ),
                ),
                Card(
                  color: Colors.red,
                  child: ListTile(
                    title: RaisedButton(
                      color: Colors.red,
                      elevation: 0,
                      child: Text("Konto löschen"),
                      onPressed: () async {
                        if (authService.isAnon())
                          deleteAccountAlert();
                        else
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (BuildContext context) =>
                                  DeleteAccountPage(),
                            ),
                          );
                      },
                    ),
                  ),
                )
              ],
            ),
          );
        },
      ),
    );
  }
}
