import 'package:Vertretung/authentication/login_page.dart';
import 'package:Vertretung/otherWidgets/school_class_selection.dart';
import 'package:Vertretung/provider/theme_data.dart';
import 'package:Vertretung/provider/user_data.dart';
import 'package:Vertretung/services/auth_service.dart';
import 'package:Vertretung/settings/subjectsSelection/subjects_page.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:introduction_screen/introduction_screen.dart';
import 'package:progress_dialog/progress_dialog.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

class IntroScreen extends StatefulWidget {
  @override
  _IntroScreenState createState() => _IntroScreenState();
}

class _IntroScreenState extends State<IntroScreen>
    with TickerProviderStateMixin {
  TextEditingController nameController = TextEditingController();
  bool alreadyPressed = false;

  ///Whether to use whitelist or blacklist
  bool isAdvancedLevel = true;
  bool highlightSchoolClassSelection = false;
  bool highlightSubjectsSelection = false;
  bool showIgnoreEmptySubjectsButton = false;
  bool ignoreEmptySubjects = false;
  TextStyle titleStyle = TextStyle(
    color: lightTheme.primaryColor,
    fontSize: 30,
    fontWeight: FontWeight.w600,
  );

  TextStyle descriptionStyle = TextStyle(fontSize: 15);
  final GlobalKey<IntroductionScreenState> introKey =
      GlobalKey<IntroductionScreenState>();

  EdgeInsets titlePadding = EdgeInsets.symmetric(vertical: 50);

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    String schoolClass = context.read<UserData>().schoolClass;
    isAdvancedLevel = ["EF", "Q1", "Q2"].contains(schoolClass);
    if (schoolClass != "Nicht festgelegt") {
      highlightSchoolClassSelection = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: lightTheme,
      child: IntroductionScreen(
        key: introKey,
        pages: [
          PageViewModel(
            image: Center(child: Image.asset("assets/icons/icon.png")),
            title: "Vertretung",
            body: "Der bessere Vertretungsplan!",
            footer: TextButton(
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
            title: "Personalisierte Vertretung",
            bodyWidget: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(30),
                  child: Image.asset("assets/images/checklist.png"),
                ),
                Text(
                  "Mit personalisierter Vertretung siehst Du durch die Eingabe von Fächern nur Vertretung, die Dich betrifft. Somit wirst Du nicht mehr von der Vertretung anderer Kurse gestört.",
                  style: descriptionStyle,
                  textAlign: TextAlign.center,
                ),
              ],
            ),
            decoration: PageDecoration(
              titlePadding: titlePadding,
              titleTextStyle: titleStyle,
            ),
          ),
          PageViewModel(
            title: "Benachrichtigungen",
            bodyWidget: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(30),
                  child: Image.asset("assets/images/notification.png"),
                ),
                Text(
                  "Mit Benachrichtigungen weißt Du immer Bescheid, wenn es neue Änderungen gibt! Auch wenn die App geschlossen ist.",
                  style: descriptionStyle,
                  textAlign: TextAlign.center,
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
            bodyWidget: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 30),
                  child: Image.asset("assets/images/friends.png"),
                ),
                Text(
                  'Wenn Du Freunde hinzufügst, siehst Du, wann Deine Freunde Entfall haben. So weißt Du immer, wann Du Dich mit ihnen treffen kannst.',
                  style: descriptionStyle,
                  textAlign: TextAlign.center,
                ),
              ],
            ),
            decoration: PageDecoration(
                titlePadding: titlePadding, titleTextStyle: titleStyle),
          ),
          PageViewModel(
            title: "Dein Profil",
            bodyWidget: Column(
              children: [
                ListTile(
                  title: TextField(
                    controller: nameController,
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 20),
                    decoration: InputDecoration(hintText: "Dein Name"),
                  ),
                  leading: Icon(Icons.person),
                  trailing: IconButton(
                    icon: Icon(Icons.info),
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          content: Text(
                              "Dies ist für die Freunde-Funktion nötig \nund wird Deinen Freunden angezeigt."),
                        ),
                      );
                    },
                  ),
                ),
                SizedBox(height: 15),
                SchoolClassSelection(highlight: highlightSchoolClassSelection),
                SizedBox(height: 15),
                SwitchListTile(
                  title: Text("Personalisierte Vertretung"),
                  secondary: Icon(Icons.grade),
                  onChanged: (bool value) =>
                      context.read<UserData>().personalSubstitute = value,
                  value: context.watch<UserData>().personalSubstitute,
                ),
                SizedBox(height: 15),
                AnimatedSwitcher(
                  duration: Duration(milliseconds: 800),
                  child: Container(
                    decoration: BoxDecoration(
                      border: Border.all(
                          color: highlightSubjectsSelection
                              ? Colors.red
                              : lightTheme.canvasColor,
                          width: 4),
                      borderRadius: BorderRadius.all(Radius.circular(15)),
                    ),
                    key: ValueKey(highlightSubjectsSelection),
                    child: ListTile(
                      title: Text("Fächer eingeben"),
                      leading: Icon(Icons.edit),
                      trailing: buildSubjectsTrailing(),
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
                      enabled: context.watch<UserData>().personalSubstitute,
                    ),
                  ),
                ),
                if (context.watch<UserData>().schoolClass != "Nicht festgelegt")
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        vertical: 25, horizontal: 15),
                    child: Text(
                      isAdvancedLevel
                          ? "Wenn Du Deine Fächer eingibst, siehst Du nur Vertretung, die Dich betrifft!"
                          : "Wenn Du die Fächer Deiner Mitschüler eingibst, die Du nicht hast, siehst Du keine Vertretung mehr von diesen Fächern. Zum Beispiel wenn Du Latein hast, kannst Du Französisch eingeben.",
                      style: descriptionStyle,
                      textAlign: TextAlign.center,
                    ),
                  ),
                SizedBox(height: 100),
              ],
            ),
            decoration: PageDecoration(
              titlePadding: titlePadding,
              titleTextStyle: titleStyle,
            ),
          ),
          PageViewModel(
            title: "Fertig",
            bodyWidget: Column(
              children: <Widget>[
                Text(
                  "Fragen und Rückmeldungen bitte über das Feedbackformular in den Einstellungen. \n\n",
                  style: TextStyle(fontSize: 19),
                  textAlign: TextAlign.center,
                ),
                Text(
                  "Außerdem bist Du damit einverstanden, dass Deine Einstellungen in der Cloud gespeichert werden. Dies ist z.B für das Freundes-Feature nötig. Zusätzlich werden besondere Ereignisse wie Registrierungen und Fehlerberichte anonym gesendet.",
                  style: TextStyle(fontSize: 14),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
            footer: TextButton(
              child: Text("Zu Firebase"),
              onPressed: () => launch("https://firebase.google.com/"),
            ),
            decoration: PageDecoration(
              titlePadding: titlePadding,
              titleTextStyle: titleStyle,
            ),
          ),
        ],
        dotsFlex: 3,
        dotsDecorator:
            DotsDecorator(activeColor: Theme.of(context).primaryColor),
        next: Icon(Icons.arrow_forward),
        done: Text("Fertig"),
        onChange: onPageChange,
        onDone: onDone,
      ),
    );
  }

  void onPageChange(int newPage) {
    UserData userData = context.read<UserData>();
    if (newPage >= 5) {
      if (userData.schoolClass == "Nicht festgelegt") {
        highlightMissingSelection(true);
      }
      if (userData.personalSubstitute && !ignoreEmptySubjects) {
        if (isAdvancedLevel) {
          if (userData.subjects.isEmpty) {
            highlightMissingSelection(false);
          }
        } else {
          if (userData.subjectsNot.isEmpty) {
            highlightMissingSelection(false);
          }
        }
      }
    }
  }

  void onDone() async {
    if (!alreadyPressed) {
      alreadyPressed = true;
      ProgressDialog pr =
          ProgressDialog(context, isDismissible: false, showLogs: false);
      String name = nameController.text;
      if (name == "") name = "Nicht festgelegt";
      if (kIsWeb) {
        Navigator.pop(context, name);
      } else {
        await pr.show();
        await AuthService().setupAccount(true, name).catchError((e) async {
          await pr.hide();
          alreadyPressed = false;
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text("Ein Fehler ist aufgetreten: $e"),
            duration: Duration(seconds: 5),
            backgroundColor: Colors.red,
          ));
        });
        pr.hide();
      }
    }
  }

  Widget buildSubjectsTrailing() {
    final icon = Icon(Icons.check, color: Colors.green);
    if (showIgnoreEmptySubjectsButton &&
        context.watch<UserData>().personalSubstitute) {
      return ElevatedButton(
        onPressed: () {
          setState(() => ignoreEmptySubjects = true);
          setState(() => showIgnoreEmptySubjectsButton = false);
        },
        style:
            ButtonStyle(backgroundColor: MaterialStateProperty.all(Colors.red)),
        child: Text(
          "Später eingeben",
          style: TextStyle(color: Colors.white),
        ),
      );
    } else if (ignoreEmptySubjects) {
      return icon;
    } else if (isAdvancedLevel) {
      if (context.watch<UserData>().subjects.isNotEmpty) return icon;
    } else if (context.watch<UserData>().subjectsNot.isNotEmpty) {
      return icon;
    }
    return null;
  }

  ///Whether to highlight schoolClassSelection or subjectsSelection
  void highlightMissingSelection(bool schoolClass) async {
    introKey.currentState.animateScroll(4);
    if (schoolClass) {
      setState(() => highlightSchoolClassSelection = true);
    } else {
      setState(() => highlightSubjectsSelection = true);
    }
    await Future.delayed(Duration(milliseconds: 800));
    if (schoolClass) {
      setState(() => highlightSchoolClassSelection = false);
    } else {
      setState(() => highlightSubjectsSelection = false);
      setState(() => showIgnoreEmptySubjectsButton = true);
    }
  }
}
