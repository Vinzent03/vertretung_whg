import 'package:Vertretung/logic/names.dart';
import 'package:Vertretung/otherWidgets/stufenList.dart';
import 'package:Vertretung/provider/themedata.dart';
import 'package:Vertretung/services/authService.dart';
import 'package:Vertretung/services/cloudDatabase.dart';
import 'package:flutter/material.dart';
import 'package:intro_slider/intro_slider.dart';
import 'package:intro_slider/slide_object.dart';
import '../logic/localDatabase.dart';
import 'package:url_launcher/url_launcher.dart';

class IntroScreen extends StatefulWidget {
  @override
  _IntroScreenState createState() => _IntroScreenState();
}

class _IntroScreenState extends State<IntroScreen> {
  TextEditingController nameController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Theme(
      data: lightTheme,
      child: IntroSlider(
        slides: [
          Slide(
            widgetDescription: Center(
              child: Column(
                children: <Widget>[
                  Text(
                    "Der bessere Vertretungsplan!",
                    style: TextStyle(fontSize: 40, color: Colors.white),
                  ),
                  SizedBox(
                    height: 200,
                  ),
                  Text(
                    "Du hast schon ein Account? Dann klick unten auf Anmelden",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white,
                    ),
                  )
                ],
              ),
            ),
            backgroundColor: Colors.blue[800],
          ),
          Slide(
            title: "Features:",
            centerWidget: Container(
              padding: EdgeInsets.all(20),
              child: Text(
                "-Personalisierte Vertretung\n"
                "\n-Du bekommst SINNVOLLE Benachrichtigungen\n"
                "\n-Kein lästiges Reinzoomen in der Dsb-Mobile App\n"
                "\n-Du siehst immer was deine Freunde für Vertretung haben\n"
                "\n-Verteilung von Nachrichten direkt über die App\n"
                "\n-Durchgehender Dark/Light Mode\n"
                "\n-Anzeige der aktuellen Wochennummer",
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white),
              ),
            ),
            backgroundColor: Colors.blue[800],
          ),
          Slide(
            title: "In welcher Stufe/Klasse bist du?",
            maxLineTitle: 3,
            styleTitle: TextStyle(fontSize: 25, color: Colors.white),
            centerWidget: Theme(
              data: lightTheme,
              child: StufenList(),
            ),
            backgroundColor: Colors.blue[800],
          ),
          Slide(
            title: "Wie ist dein Name?",
            maxLineTitle: 3,
            styleTitle: TextStyle(fontSize: 25, color: Colors.white),
            centerWidget: Container(
              padding: EdgeInsets.all(100),
              child: TextField(
                controller: nameController,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 20,
                  color: Colors.white,
                ),
              ),
            ),
            backgroundColor: Colors.blue[800],
          ),
          Slide(
              title: "Fertig",
              backgroundColor: Colors.blue[800],
              widgetDescription: Column(
                children: <Widget>[
                  Text(
                    "Den Rest der Einstellungen, wie deine Fächer, sowie Hilfe, zu verschiedenen Themen findest du unter Vertretung oben rechts.\n\n\n",
                    style: TextStyle(fontSize: 20, color: Colors.white),
                  ),
                  InkWell(
                    child: Text(
                      "Außerdem bist du damit einverstanden, dass deine Einstellungen in der Cloud(https://firebase.google.com/) gespeichert werde. Dies ist für die  Bereitstellung der Benachrichtigungen und des Freundes Feature nötig.",
                      style: TextStyle(color: Colors.white),
                    ),
                    onTap: () {
                      launch("https://firebase.google.com/");
                    },
                  ),
                ],
              )),
        ],
        colorDot: Colors.white,
        colorActiveDot: Colors.blue[900],
        nameSkipBtn: "Anmelden",
        widthSkipBtn: 100,
        onSkipPress: () =>
            Navigator.pushNamed(context, Names.logInPage, arguments: false),
        onDonePress: () async {
          await AuthService().signInAnon();
          String name = nameController.text;
          if (name == "") name = "Nicht festgelegt";
          CloudDatabase db = CloudDatabase();
          db.updateName(name);
          db.updateUserData(
            subjects: [],
            subjectsNot: [],
            schoolClass: await LocalDatabase().getString(Names.schoolClass),
            personalSubstitute: false,
            notification: true,
          );
          db.becomeBetaUser(false);
          LocalDatabase local = LocalDatabase();
          local.setBool(Names.personalSubstitute, false);
          local.setBool(Names.beta, false);
        },
      ),
    );
  }
}
