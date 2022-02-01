import 'package:Vertretung/authentication/web_page_login.dart';
import 'package:Vertretung/data/my_keys.dart';
import 'package:Vertretung/data/names.dart';
import 'package:Vertretung/logic/shared_pref.dart';
import 'package:Vertretung/main/home.dart';
import 'package:Vertretung/main/intro_screen.dart';
import 'package:Vertretung/main/update_dialog.dart';
import 'package:Vertretung/provider/theme_settings.dart';
import 'package:Vertretung/provider/user_data.dart';
import 'package:Vertretung/services/auth_service.dart';
import 'package:Vertretung/services/cloud_database.dart';
import 'package:Vertretung/services/dynamic_link.dart';
import 'package:Vertretung/services/remote_config.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import "package:flutter/material.dart";
import 'package:provider/provider.dart';

class Splash extends StatefulWidget {
  @override
  _SplashState createState() => _SplashState();
}

class _SplashState extends State<Splash> {
  AuthService auth = AuthService();
  bool finishedLoading = false;
  Future<void> initTheme() async {
    ThemeMode themeMode =
        ThemeMode.values[await SharedPref.getInt(Names.themeMode)];
    context.read<ThemeSettings>().setThemeMode(themeMode);
  }

  Future<void> initUserSettings() async {
    UserData provider = Provider.of<UserData>(context, listen: false);
    provider.schoolClass = await SharedPref.getString(Names.schoolClass);
    provider.personalSubstitute =
        await SharedPref.getBool(Names.personalSubstitute);
    provider.friendsFeature = await SharedPref.getBool(Names.friendsFeature);

    provider.rawSubstituteToday =
        await SharedPref.getStringList(Names.substituteToday);
    provider.rawSubstituteTomorrow =
        await SharedPref.getStringList(Names.substituteTomorrow);
    provider.lastChange = await SharedPref.getString(Names.lastChange);
    provider.dayNames = await SharedPref.getStringList(Names.dayNames);

    provider.subjects = await SharedPref.getStringList(Names.subjects);
    provider.subjectsNot = await SharedPref.getStringList(Names.subjectsNot);

    provider.freeLessons = await SharedPref.getStringList(Names.freeLessons);
  }

  void initDynamicLink() => DynamicLink().handleDynamicLink();

  Future<void> checkForUpdate() async {
    CloudDatabase cd = CloudDatabase();
    UpdateCodes updateSituation = await cd.getUpdate();

    if (UpdateCodes.availableNormal == updateSituation ||
        UpdateCodes.availableForce == updateSituation) {
      Map<String, String> links = await cd.getUpdateLinks();
      List<dynamic> message = await cd.getUpdateMessage();
      showDialog(
        context: MyKeys.navigatorKey.currentState.overlay.context,
        builder: (_) => UpdateDialog(
          title: message[0],
          description: message[1],
          changelogLink: links["changelog"],
          websiteLink: links["website"],
          downloadLink: links["download"],
          isForce: updateSituation == UpdateCodes.availableForce,
        ),
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
    SharedPref.checkIfKeyIsSet(Names.notificationOnFirstChange).then((value) {
      if (!value) SharedPref.setBool(Names.notificationOnFirstChange, false);
    });
    await Future.wait(
      [
        initTheme(),
        initUserSettings(),
        RemoteConfigService.init(),
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
    if (finishedLoading) {
      return StreamBuilder(
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
      );
    } else {
      return buildLoadScreen();
    }
  }

  Widget buildLoadScreen() {
    return Scaffold(
      backgroundColor: Theme.of(context).primaryColor,
      body: Stack(
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
      ),
    );
  }
}
