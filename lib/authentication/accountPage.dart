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
  String name = "Laden";
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
                      // LocalDatabase().setString(Names.name, controller.text);
                      // setState(() {
                      //   name = controller.text;
                      // });
                      AuthService().updateName(controller.text);
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
                  Navigator.pushNamedAndRemoveUntil(
                      context, Names.homePage, (r) => false);
                },
              )
            ],
          );
        });
  }

  @override
  void initState() {
    // LocalDatabase().getString(Names.name).then((newName) {
    //   setState(() {
    //     name = newName;
    //   });
    // });
    AuthService().getName().then((value) => name = value);
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
                title: Text("Dein Name:"),
                subtitle: Text(name),
                trailing: FlatButton(
                  child: Text("Ändern"),
                  onPressed: () => changeNameAlert(),
                ),
              ),
            ),
            Card(
              child: Column(
                children: <Widget>[
                  ListTile(
                    leading: Icon(Icons.email),
                    title: Text("Anmelde Methode:"),
                    subtitle: isAnon ? null : Text(email),
                    trailing: Text("${isAnon ? "Anonym    " : "Email    "}"),
                  ),
                  if (!isAnon)
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
            if (isAnon)
              Card(
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
                        child: Text("Registrieren"),
                        onPressed: () => Navigator.pushNamed(
                            context, Names.logInPage,
                            arguments: true),
                      ),
                    )
                  : ListTile(
                      title: RaisedButton(
                          color: Colors.blue,
                          elevation: 0,
                          child: Text("Abmelden"),
                          onPressed: () async {
                            await AuthService().signOut();
                            Navigator.pushNamedAndRemoveUntil(
                                context, Names.homePage, (r) => false);
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
