import 'package:Vertretung/services/authService.dart';
import 'package:flutter/material.dart';

class LogInPage extends StatefulWidget {
  @override
  _LogInPageState createState() => _LogInPageState();
}

class _LogInPageState extends State<LogInPage> {
  bool isRegistration = true;
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    isRegistration = ModalRoute.of(context).settings.arguments;

    return Scaffold(
      appBar: AppBar(
        title: Text("LogIn/Registrieren"),
      ),
      body: Builder(
        builder: (context) {
          return Center(
            child: SingleChildScrollView(
              child: Card(
                child: Container(
                  padding: EdgeInsets.all(30),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      SizedBox(
                        height: 20,
                      ),
                      Text("Email:"),
                      TextFormField(
                        controller: emailController,
                      ),
                      SizedBox(
                        height: 20,
                      ),
                      Text("Passwort:"),
                      TextFormField(
                        obscureText: true,
                        controller: passwordController,
                      ),
                      SizedBox(
                        height: 20,
                      ),
                      ListTile(
                        title: RaisedButton(
                          child: Text(
                              isRegistration ? "Registrieren" : "Anmelden"),
                          onPressed: () async {
                            String err;
                            if (isRegistration)
                              err = await AuthService().signUp(
                                  email: emailController.text,
                                  password: passwordController.text);
                            else
                              err = await AuthService().signInEmail(
                                  email: emailController.text,
                                  password: passwordController.text);
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
                      ),
                      if (!isRegistration)
                        ListTile(
                          dense: true,
                          title: FlatButton(
                            child: Text("Passwort vergessen"),
                            onPressed: () async {
                              String err = await AuthService()
                                  .resetPassword(emailController.text);
                              if (err != null) {
                                final SnackBar snack = SnackBar(
                                  content: Text(err),
                                  backgroundColor: Colors.red,
                                );
                                Scaffold.of(context).showSnackBar(snack);
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
        },
      ),
    );
  }
}
