import 'package:Vertretung/authentication/login_page.dart';
import 'package:Vertretung/otherWidgets/school_class_selection.dart';
import 'package:Vertretung/provider/theme_data.dart';
import 'package:Vertretung/provider/user_data.dart';
import 'package:Vertretung/services/auth_service.dart';
import 'package:Vertretung/settings/subjectsSelection/subjects_page.dart';
import 'package:flushbar/flushbar.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:introduction_screen/introduction_screen.dart';
import 'package:progress_dialog/progress_dialog.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

class IntroScreen extends StatefulWidget {
  @override
  _IntroScreenState createState() => _IntroScreenState();
}

class _IntroScreenState extends State<IntroScreen> {
  TextEditingController nameController = TextEditingController();
  bool alreadyPressed = false;
  bool personalSubstitute = false;

  ///Whether to use whitelist or blacklist
  bool isAdvancedLevel = false;
  bool alreadyShowedSchoolClassFlushBar = false;
  TextStyle titleStyle = TextStyle(
      color: Colors.blue[800], fontSize: 35, fontWeight: FontWeight.w600);
  EdgeInsets titlePadding = EdgeInsets.symmetric(vertical: 100);

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
              titleTextStyle: titleStyle,
              bodyTextStyle: TextStyle(fontSize: 25),
            ),
          ),
          PageViewModel(
            title: "Features",
            bodyWidget: MarkdownBody(
              data: "- Personalisierte Vertretung\n"
                  "\n- Personalisierte Benachrichtigungen\n"
                  "\n- Du siehst die Vertretung und Freistunden Deiner Freunde\n"
                  "\n- Verteilung von Nachrichten direkt über die App\n"
                  "\n- Dark/Light Mode\n"
                  "\n- Anzeige der aktuellen Wochennummer",
              styleSheet: MarkdownStyleSheet(p: TextStyle(fontSize: 21)),
            ),
            decoration: PageDecoration(
                titlePadding: titlePadding, titleTextStyle: titleStyle),
          ),
          PageViewModel(
            title: "In welcher Stufe/Klasse bist Du?",
            bodyWidget: SchoolClassSelection(),
            decoration: PageDecoration(
                titlePadding: titlePadding, titleTextStyle: titleStyle),
          ),
          PageViewModel(
            title: "Wie heißt Du?",
            bodyWidget: Container(
              padding: EdgeInsets.symmetric(horizontal: 100),
              child: TextField(
                controller: nameController,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 20,
                ),
              ),
            ),
            footer: Text(
              "Dies ist für das Freunde Feature nötig \nund wird Deinen Freunden angezeigt.",
              style: TextStyle(fontSize: 18),
            ),
            decoration: PageDecoration(
              titlePadding: titlePadding,
              titleTextStyle: titleStyle,
            ),
          ),
          PageViewModel(
            title: "Personalisierte Vertretung",
            bodyWidget: Column(
              children: [
                Text(
                  isAdvancedLevel ? "Oberstufe" : "Unterstufe",
                  style: TextStyle(fontSize: 25),
                ),
                SizedBox(
                  height: 50,
                ),
                Text(
                  isAdvancedLevel
                      ? "Wenn Du Deine Fächer eingibst, siehst Du extra Tabs. In diesen wird nur Vertretung angezeigt, die Dich betrifft."
                      : "Wenn Du die Fächer Deiner Mitschüler eingibst, siehst Du keine Vertretung mehr von diesen Fächern. Zum Beispiel wenn Du Latein hast, kannst du Französisch eingeben.",
                  style: TextStyle(fontSize: 18),
                ),
                SizedBox(
                  height: 50,
                ),
                SwitchListTile(
                  title: Text("Personalisierte Vertretung"),
                  onChanged: (bool value) {
                    setState(() => personalSubstitute = value);
                  },
                  value: personalSubstitute,
                ),
                ListTile(
                  title: Text("Fächer eingeben"),
                  leading: Icon(Icons.edit),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (BuildContext context) => SubjectsPage(
                          isWhitelist: isAdvancedLevel,
                          inIntroScreen: true,
                        ),
                      ),
                    );
                  },
                  enabled: personalSubstitute,
                ),
              ],
            ),
            decoration: PageDecoration(
              titlePadding: titlePadding,
              titleTextStyle: titleStyle,
            ),
          ),
          PageViewModel(
            title: "Freunde",
            body:
                'Wenn Du Freunde hinzufügst, siehst Du, wann Deine Freunde Entfall haben. So weißt Du immer, wann Du Dich mit ihnen treffen kannst. \n\nUm Freunde hinzuzufügen, schickst Du Deinen Freundestoken/Link an einen Freund. Dieser muss den Token dann unter \n"Als Freund eintragen" eingeben oder auf den Link klicken.',
            decoration: PageDecoration(
                titlePadding: titlePadding, titleTextStyle: titleStyle),
          ),
          PageViewModel(
            title: "Fertig",
            bodyWidget: Column(
              children: <Widget>[
                Text(
                  "Den Rest der Einstellungen, wie Deine Fächer, sowie Hilfe, zu verschiedenen Themen findest Du unter Vertretung oben rechts. \n\n",
                  style: TextStyle(fontSize: 19),
                ),
                Text(
                  "Außerdem bist Du damit einverstanden, dass Deine Einstellungen in der Cloud gespeichert werden. Dies ist z.B für das Freundes-Feature nötig. Zusätzlich werden besondere Ereignisse wie Registrierungen und Fehlerberichte anonym gesendet.",
                  style: TextStyle(fontSize: 14),
                ),
              ],
            ),
            footer: FlatButton(
              child: Text("Zu Firebase"),
              onPressed: () => launch("https://firebase.google.com/"),
            ),
            decoration: PageDecoration(
                titlePadding: titlePadding, titleTextStyle: titleStyle),
          ),
        ],
        dotsFlex: 3,
        dotsDecorator: DotsDecorator(activeColor: Colors.blue[800]),
        next: Icon(Icons.arrow_forward),
        showNextButton: true,
        done: Text("Fertig"),
        onChange: (int i) async {
          //get schoolClass to show different personalSubstitute content
          String schoolClass = context.read<UserData>().schoolClass;
          if (i > 2 &&
              !alreadyShowedSchoolClassFlushBar &&
              schoolClass == "Nicht festgelegt") {
            alreadyShowedSchoolClassFlushBar = true;
            Flushbar(
              message: "Möchtest Du wirklich keine Stufe/Klasse festlegegen?",
              duration: Duration(seconds: 5),
            ).show(context);
          }

          setState(() {
            isAdvancedLevel = ["EF", "Q1", "Q2"].contains(schoolClass);
          });
        },
        onDone: () async {
          if (!alreadyPressed) {
            alreadyPressed = true;
            ProgressDialog pr =
                ProgressDialog(context, isDismissible: false, showLogs: false);
            context.read<UserData>().personalSubstitute = personalSubstitute;
            String name = nameController.text;
            if (name == "") name = "Nicht festgelegt";
            if (kIsWeb) {
              Navigator.pop(context, name);
            } else {
              await pr.show();
              await AuthService()
                  .setupAccount(true, name)
                  .catchError((e) async {
                await pr.hide();
                alreadyPressed = false;
                Flushbar(
                  message: "Ein Fehler ist aufgetreten: $e",
                  backgroundColor: Colors.red,
                  duration: Duration(seconds: 5),
                ).show(context);
              });
              pr.hide();
            }
          }
        },
      ),
    );
  }
}
