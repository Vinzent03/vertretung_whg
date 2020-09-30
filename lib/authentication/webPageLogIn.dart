import 'package:Vertretung/authentication/logInWidget.dart';
import 'package:Vertretung/authentication/registrationWidget.dart';
import 'package:Vertretung/main/introScreen.dart';
import "package:flutter/material.dart";
import 'package:flutter/rendering.dart';

class WebPageLogIn extends StatefulWidget {
  bool isLogIn;
  WebPageLogIn({Key key, @required this.isLogIn}) : super(key: key);
  @override
  _WebPageLogInState createState() => _WebPageLogInState();
}

class _WebPageLogInState extends State<WebPageLogIn> {
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController passwordConfirmController = TextEditingController();
  String name;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Anmelden/Registrieren"),
      ),
      body: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            height: 75,
          ),
          CircleAvatar(
            child: Image.asset("assets/icons/icon.png"),
            radius: 100,
          ),
          SizedBox(
            height: 75,
          ),
          Center(
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(30),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    widget.isLogIn
                        ? LogInWidget()
                        : RegistrationWidget(name: name),
                    RaisedButton(
                      color: Colors.red,
                      child: Text(
                          widget.isLogIn ? "Zum Registrieren" : "Zum Anmelden"),
                      onPressed: () async {
                        setState(() {
                          widget.isLogIn = !widget.isLogIn;
                        });
                        if (!widget.isLogIn) {
                          String newName = await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => IntroScreen(),
                            ),
                          );
                          setState(() {
                            name = newName;
                          });
                          print(name);
                        }
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
