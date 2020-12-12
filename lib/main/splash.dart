import 'package:Vertretung/authentication/webPageLogIn.dart';
import 'package:Vertretung/data/myKeys.dart';
import 'package:Vertretung/data/names.dart';
import 'package:Vertretung/logic/sharedPref.dart';
import 'package:Vertretung/main/home.dart';
import 'package:Vertretung/main/introScreen.dart';
import 'package:Vertretung/provider/themeSettings.dart';
import 'package:Vertretung/provider/userData.dart';
import 'package:Vertretung/services/authService.dart';
import 'package:Vertretung/services/cloudDatabase.dart';
import 'package:Vertretung/services/dynamicLink.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import "package:flutter/material.dart";
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

class Splash extends StatefulWidget {
  @override
  _SplashState createState() => _SplashState();
}

class _SplashState extends State<Splash> {
  AuthService auth = AuthService();
  bool finishedLoading = false;
  Future<void> initTheme() async {
    ThemeMode themeMode =
        ThemeMode.values[await SharedPref().getInt(Names.themeMode)];
    context.read<ThemeSettings>().setThemeMode(themeMode);
  }

  Future<void> initUserSettings() async {
    SharedPref sharedPref = SharedPref();
    UserData provider = Provider.of<UserData>(context, listen: false);
    provider.schoolClass = await sharedPref.getString(Names.schoolClass);
    provider.personalSubstitute =
        await sharedPref.getBool(Names.personalSubstitute);
    provider.friendsFeature = await sharedPref.getBool(Names.friendsFeature);

    provider.rawSubstituteToday =
        await sharedPref.getStringList(Names.substituteToday);
    provider.rawSubstituteTomorrow =
        await sharedPref.getStringList(Names.substituteTomorrow);
    provider.lastChange = await sharedPref.getString(Names.lastChange);

    provider.subjects = await sharedPref.getStringList(Names.subjects);
    provider.subjectsNot = await sharedPref.getStringList(Names.subjectsNot);
  }

  void initDynamicLink() => DynamicLink().handleDynamicLink();

  Future<void> checkForUpdate() async {
    CloudDatabase cd = CloudDatabase();
    updateCodes updateSituation = await cd.getUpdate();

    if (updateCodes.availableNormal == updateSituation ||
        updateCodes.availableForce == updateSituation) {
      Map<String, String> links = await cd.getUpdateLinks();
      List<dynamic> message = await cd.getUpdateMessage();
      if (updateCodes.availableForce == updateSituation)
        showDialog(
          context: MyKeys.navigatorKey.currentState.overlay.context,
          barrierDismissible: false,
          builder: (context) {
            return WillPopScope(
              // ignore: missing_return
              onWillPop: () {},
              child: AlertDialog(
                title: Text(message[0]),
                content: Text(message[1]),
                actions: <Widget>[
                  RaisedButton(
                    child: Text("Changelog"),
                    onPressed: () => launch(links["changelog"]),
                  ),
                  RaisedButton(
                    child: Text("Download"),
                    onPressed: () => launch(links["download"]),
                  )
                ],
              ),
            );
          },
        );
      else
        showDialog(
          context: MyKeys.navigatorKey.currentState.overlay.context,
          barrierDismissible: true,
          builder: (context) {
            return AlertDialog(
              title: Text(message[0]),
              content: Text(message[1]),
              actions: <Widget>[
                FlatButton(
                  child: Text("abbrechen"),
                  onPressed: () => Navigator.pop(context),
                ),
                RaisedButton(
                  child: Text("Changelog"),
                  onPressed: () => launch(links["changelog"]),
                ),
                RaisedButton(
                  child: Text("Download"),
                  onPressed: () => launch(links["download"]),
                ),
              ],
            );
          },
        );
    }
  }

  Future<void> load() async {
    auth.syncSettingsOnSignIn(Provider.of<UserData>(context, listen: false));
    if (!kIsWeb) {
      initDynamicLink();
      checkForUpdate();
    }
    //disable new notification option by default
    SharedPref().checkIfKeyIsSet(Names.notificationOnFirstChange).then((value) {
      if (!value) SharedPref().setBool(Names.notificationOnFirstChange, false);
    });
    await Future.wait(
      [
        initTheme(),
        initUserSettings(),
      ],
    );
    setState(() {
      finishedLoading = true;
    });
  }

  @override
  void initState() {
    load();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue[800],
      body: finishedLoading
          ? StreamBuilder(
              stream: auth.user,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting)
                  return buildLoadScreen();
                if (snapshot.hasData)
                  return Home();
                else if (kIsWeb)
                  return WebPageLogIn(isLogIn: true);
                else
                  return IntroScreen();
              },
            )
          : buildLoadScreen(),
    );
  }

  Widget buildLoadScreen() {
    return Stack(
      children: <Widget>[
        Center(
          child: Image.asset(
            "assets/icons/icon.png",
            height: 150,
          ),
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            SizedBox(
              height: 500,
            ),
            Align(
              alignment: Alignment.center,
              child: Text(
                "Vertretung",
                style: TextStyle(fontSize: 30, color: Colors.white),
                textAlign: TextAlign.center,
              ),
            )
          ],
        ),
      ],
    );
  }
}
