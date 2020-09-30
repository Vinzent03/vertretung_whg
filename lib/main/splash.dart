import 'dart:async';
import 'package:Vertretung/logic/myKeys.dart';
import 'package:Vertretung/logic/names.dart';
import 'package:Vertretung/logic/sharedPref.dart';
import 'package:Vertretung/provider/providerData.dart';
import 'package:Vertretung/services/cloudDatabase.dart';
import 'package:Vertretung/services/dynamicLink.dart';
import 'package:Vertretung/services/push_notifications.dart';
import "package:flutter/material.dart";
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

class Splash extends StatefulWidget {
  @override
  _SplashState createState() => _SplashState();
}

class _SplashState extends State<Splash> {
  void initTheme() async {
    ThemeMode themeMode =
        ThemeMode.values[await SharedPref().getInt(Names.themeMode)];
    Provider.of<ProviderData>(context, listen: false).setThemeMode(themeMode);
  }

  void initNotification() => PushNotificationsManager().init();
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

  @override
  void initState() {
    initTheme();
    if (!kIsWeb) {
      checkForUpdate();
      initDynamicLink();
      initNotification();
    }

    //disable new notification option by default
    SharedPref().checkIfKeyIsSet(Names.notificationOnFirstChange).then((value) {
      if (!value) SharedPref().setBool(Names.notificationOnFirstChange, false);
    });

    Timer(Duration(milliseconds: 100), () {
      Navigator.of(context).pushReplacementNamed(Names.wrapper);
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue[800],
      body: Stack(
        children: <Widget>[
          Center(
            child: Image.asset(
              "assets/icons/icon.png",
              height: 100,
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
                child: AnimatedOpacity(
                  opacity: 1,
                  duration: Duration(milliseconds: 100),
                  child: Text(
                    "Vertretung",
                    style: TextStyle(fontSize: 30, color: Colors.white),
                    textAlign: TextAlign.center,
                  ),
                ),
              )
            ],
          ),
        ],
      ),
    );
  }
}
