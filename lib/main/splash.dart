import 'dart:async';
import 'package:Vertretung/logic/names.dart';
import 'package:Vertretung/logic/sharedPref.dart';
import 'package:Vertretung/provider/providerData.dart';
import 'package:Vertretung/services/dynamicLink.dart';
import 'package:Vertretung/services/push_notifications.dart';
import "package:flutter/material.dart";
import 'package:provider/provider.dart';

class Splash extends StatefulWidget {
  @override
  _SplashState createState() => _SplashState();
}

class _SplashState extends State<Splash> {
  void initTheme() async {
    ThemeMode themeMode =
        ThemeMode.values[await SharedPref().getInt(Names.themeMode)];
    Provider.of<ProviderData>(context,listen: false).setThemeMode(themeMode);
  }

  void initNotification() => PushNotificationsManager().init();
  void initDynamicLink() => DynamicLink().handleDynamicLink(
      Provider.of<ProviderData>(context, listen: false).getNavigatorKey());

  @override
  void initState() {
    initTheme();
    initNotification();
    initDynamicLink();
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
                    style: TextStyle(fontSize: 30,color: Colors.white),
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
