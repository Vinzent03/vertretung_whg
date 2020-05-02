import 'package:Vertretung/logic/localDatabase.dart';
import 'package:Vertretung/logic/names.dart';
import 'package:Vertretung/services/authService.dart';
import 'package:Vertretung/services/cloudDatabase.dart';
import 'package:Vertretung/services/cloudFunctions.dart';
import 'package:flutter/material.dart';

class AccountPage extends StatefulWidget {
  @override
  _AccountPageState createState() => _AccountPageState();
}

class _AccountPageState extends State<AccountPage> {
  String name;
  String email = "Laden";
  bool isAnon = true;

  changeNameAlert() {
    final TextEditingController controller = TextEditingController();
    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
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
                  onPressed: () {
                    if (controller.text.length >= 2) {
                      LocalDatabase().setString(Names.name, controller.text);
                      setState(() {
                        name = controller.text;
                      });
                      CloudDatabase().updateName(controller.text);
                      Navigator.pop(context);
                    }
                  }),
            ],
          );
        });
  }

  void deleteAccountAlert() {
    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text(
                "Möchtest du dein Account wirklich löschen? Das kann nicht Rückgängig gemacht werden!"),
            actions: <Widget>[
              FlatButton(
                child: Text("abbrechen"),
                onPressed: () => Navigator.pop(context),
              ),
              RaisedButton(
                color: Colors.red,
                child: Text("Bestätigen"),
                onPressed: () async {
                  await Functions().callDeleteProfile();
                  Navigator.pop(context);
                },
              )
            ],
          );
        });
  }

  @override
  void initState() {
    LocalDatabase().getString(Names.name).then((newName) {
      setState(() {
        name = newName;
      });
    });
    AuthService().isAnon().then((newIsAnon) {
      setState(() {
        isAnon = newIsAnon;
      });
      if (!isAnon) {
        AuthService().getEmail().then((newEmail) {
          setState(() {
            email = newEmail;
          });
        });
      }
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Dein Account"),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            Card(
              child: ListTile(
                leading: Icon(Icons.person),
                title: Text("Dein Name: $name"),
                trailing: FlatButton(
                  child: Text("Ändern"),
                  onPressed: () => changeNameAlert(),
                ),
              ),
            ),
            Card(
              child: Column(
                children: <Widget>[
                  ListTile(leading: Icon(Icons.email)
                    , title: Text(
                        "Anmelde Methode:    ${isAnon ? "Anonym" : "Email"}"),
                    subtitle: isAnon ? null : Text(email),
                  ),
                  ListTile(
                    leading: Icon(Icons.security),
                    title: Text("Passwort ändern"),
                    onTap: () {
                      Navigator.pushNamed(context, Names.changePasswordPage);
                    },
                  )
                ],
              ),
            ),
            Card(
              child: ListTile(
                leading: Icon(Icons.info),
                title: Text(
                    "Zum Anmelden erst Abmelden oder Konto löschen, wenn du anonym bist"),
              ),
            ),
            Card(
              color: Colors.blue,
              child: isAnon
                  ? ListTile(
                title: RaisedButton(
                  color: Colors.blue,
                  elevation: 0,
                  child: Text("Registrieren"),
                  onPressed: () =>
                      Navigator.pushNamed(
                          context, Names.logInPage,
                          arguments: true),
                ),
              )
                  : ListTile(
                title: RaisedButton(
                    color: Colors.blue,
                    elevation: 0,
                    child: Text("Abmelden"),
                    onPressed: () {
                      AuthService().signOut();
                      Navigator.pushNamed(context, Names.homePage);
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
                  onPressed: deleteAccountAlert,
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
