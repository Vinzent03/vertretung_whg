import 'package:Vertretung/logic/names.dart';
import 'package:Vertretung/logic/theme.dart';
import 'package:Vertretung/logic/themedata.dart';
import 'package:Vertretung/services/authService.dart';
import 'package:Vertretung/services/cloudDatabase.dart';
import 'package:Vertretung/widgets/stufenList.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:intro_slider/intro_slider.dart';
import 'package:intro_slider/slide_object.dart';
import '../logic/localDatabase.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:provider/provider.dart';

class IntroScreen extends StatefulWidget {
  @override
  _IntroScreenState createState() => _IntroScreenState();
}

class _IntroScreenState extends State<IntroScreen> {
  /*@override
  void initState() {
    SchedulerBinding.instance.addPostFrameCallback((callback) {
      Provider.of<ThemeChanger>(context, listen: false).setLightTheme();
    });
    super.initState();
  }*/

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: lightTheme,
      child: IntroSlider(
        slides: [
          Slide(
            widgetDescription: Center(
              child: Text(
                "Der bessere Vertretungsplan!",
                style: TextStyle(fontSize: 40, color: Colors.white),
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
                    fontSize: 20,
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
        onSkipPress: ()=> Navigator.pushNamed(context, Names.logInPage,arguments: false),
        onDonePress: () async {
          await AuthService().signInAnon();
          CloudDatabase().updateUserData(
            faecher: [],
            faecherNot: [],
            stufe: await LocalDatabase().getString(Names.stufe),
            faecherOn: false,
            name: "Nicht festgelegt",
            notification: true,
          );
        },
      ),
    );
  }
}