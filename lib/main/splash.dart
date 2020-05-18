import 'dart:async';
import 'package:Vertretung/logic/names.dart';
import "package:flutter/material.dart";

class Splash extends StatefulWidget {
  @override
  _SplashState createState() => _SplashState();
}

class _SplashState extends State<Splash> {
  @override
  void initState() {
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
                    style: TextStyle(fontSize: 30),
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
