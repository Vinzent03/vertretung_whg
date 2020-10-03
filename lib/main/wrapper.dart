import 'package:Vertretung/authentication/webPageLogIn.dart';
import 'package:Vertretung/main/introScreen.dart';
import 'package:Vertretung/services/authService.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'home.dart';

class Wrapper extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: AuthService().user,
      builder: (context, snapshot) {
        if (snapshot.hasData)
          return Home();
        else if (kIsWeb)
          return WebPageLogIn(isLogIn: true);
        else
          return IntroScreen();
      },
    );
  }
}
