import 'package:Vertretung/authentication/logInPage.dart';
import 'package:Vertretung/logic/names.dart';
import 'package:Vertretung/otherWidgets/SchoolClassSelection.dart';
import 'package:Vertretung/provider/themedata.dart';
import 'package:Vertretung/services/authService.dart';
import 'package:Vertretung/services/cloudDatabase.dart';
import 'package:flutter/material.dart';
import '../logic/sharedPref.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:introduction_screen/introduction_screen.dart';

class IntroScreen extends StatefulWidget {
  @override
  _IntroScreenState createState() => _IntroScreenState();
}

class _IntroScreenState extends State<IntroScreen> {
  TextEditingController nameController = TextEditingController();
  bool alreadyPressed = false;
  @override
  Widget build(BuildContext context) {
    return Theme(
      data: lightTheme,
      child: IntroductionScreen(
        pages: [
          PageViewModel(
            image: Center(
              child: Image.asset("assets/icons/icon.png"),
            ),
            title: "Vertretung",
            body: "Der bessere Vertretungsplan!",
            footer: FlatButton(
              child: Text("Du hast schon ein Account?"),
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (BuildContext context) =>
                      LogInPage(authType: AuthTypes.logIn),
                ),
              ),
            ),
            decoration: PageDecoration(
              imagePadding: EdgeInsets.symmetric(vertical: 30),
              titleTextStyle: TextStyle(
                fontSize: 35,
                fontWeight: FontWeight.bold,
              ),
              bodyTextStyle: TextStyle(fontSize: 25),
            ),
          ),
          PageViewModel(
            title: "Features",
            bodyWidget: Text(
              "-Personalisierte Vertretung\n"
              "\n-Personalisierte Benachrichtigungen\n"
              "\n-Kein lästiges Reinzoomen in der Dsb-Mobile App\n"
              "\n-Du siehst die Vertretung deiner Freunde\n"
              "\n-Verteilung von Nachrichten direkt über die App\n"
              "\n-Dark/Light Mode\n"
              "\n-Anzeige der aktuellen Wochennummer",
              style: TextStyle(fontSize: 20),
            ),
            decoration: PageDecoration(
              titlePadding: EdgeInsets.symmetric(vertical: 50),
              titleTextStyle: TextStyle(
                fontSize: 30,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          PageViewModel(
            title: "In welcher Klasse/Stufe bist du?",
            bodyWidget: StufenList(),
            decoration: PageDecoration(
              titlePadding: EdgeInsets.symmetric(vertical: 100),
              titleTextStyle: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          PageViewModel(
            title: "Wie heißt du?",
            bodyWidget: Container(
              padding: EdgeInsets.symmetric(horizontal: 50),
              child: TextField(
                controller: nameController,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 20,
                ),
              ),
            ),
            footer: Text(
                "Dies ist für das Freunde Feature nötig \nund wird deinen Freunden angezeigt."),
            decoration: PageDecoration(
              titlePadding: EdgeInsets.symmetric(vertical: 100),
              titleTextStyle: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          PageViewModel(
            title: "Deine Fächer (Whitelist)",
            body:
                "Hier kannst du deine Fächer eingeben. So wird nur Vertretung von Fächern angezeigt, die du dort eingetragen hast. Dies ist hauptsächlich für die Oberstufe gedacht.",
            decoration: PageDecoration(
              titlePadding: EdgeInsets.symmetric(vertical: 100),
              titleTextStyle: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          PageViewModel(
            title: "Fächer anderer (Blacklist)",
            body:
                "Hier kannst du die Fächer deiner Mitschüler eingeben. So wird nur Vertretung von anderen Fächern angezeigt. Dies ist hauptsächlich für die Unterstufe gedacht.",
            decoration: PageDecoration(
              titlePadding: EdgeInsets.symmetric(vertical: 100),
              titleTextStyle: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          PageViewModel(
            title: "Freunde",
            body:
                "Wenn du Freunde hinzufügst, siehst du wann deine Freunde Entfall haben. So weißt du immer wann du dich mit ihnen treffen kannst \n\nUm Freunde hinzuzufügen, schickst du deinen Freundestoken/Link an einen Freund. Die Person muss den Token dann eingeben oder auf den Link klicken.",
            decoration: PageDecoration(
              titlePadding: EdgeInsets.symmetric(vertical: 100),
              titleTextStyle: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          PageViewModel(
            title: "Fertig",
            bodyWidget: Column(
              children: <Widget>[
                Text(
                  "Den Rest der Einstellungen, wie deine Fächer, sowie Hilfe, zu verschiedenen Themen findest du unter Vertretung oben rechts. \n\n",
                  style: TextStyle(fontSize: 19),
                ),
                Text(
                  "Außerdem bist du damit einverstanden, dass deine Einstellungen in der Cloud gespeichert werden. Dies ist z.B für das Freundes-Feature nötig. Zusätzlich werden besondere Ereignisse wie Registrierungen und Fehlerberichte anonym gesendet.",
                  style: TextStyle(fontSize: 14),
                ),
              ],
            ),
            footer: FlatButton(
              child: Text("Zu Firebase"),
              onPressed: () => launch("https://firebase.google.com/"),
            ),
            decoration: PageDecoration(
              titlePadding: EdgeInsets.symmetric(vertical: 50),
              titleTextStyle: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
        dotsFlex: 3,
        next: Icon(Icons.arrow_forward),
        showNextButton: true,
        done: Text("Fertig"),
        onDone: () async {
          if (!alreadyPressed) {
            alreadyPressed = true;
            await AuthService().signInAnon();
            String name = nameController.text;
            if (name == "") name = "Nicht festgelegt";
            CloudDatabase db = CloudDatabase();
            db.updateName(name);
            db.updateUserData(
              subjects: [],
              subjectsNot: [],
              schoolClass: await SharedPref().getString(Names.schoolClass),
              personalSubstitute: false,
              notification: true,
            );
            db.updateCustomSubjects(Names.subjectsCustom, []);
            db.updateCustomSubjects(Names.subjectsNotCustom, []);
            SharedPref sharedPref = SharedPref();
            sharedPref.setBool(Names.personalSubstitute, false);
            sharedPref.setBool(Names.friendsFeature, true);
          }
        },
      ),
    );
  }
}
