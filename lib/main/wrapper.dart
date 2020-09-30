import 'package:Vertretung/authentication/webPageLogIn.dart';
import 'package:Vertretung/main/introScreen.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'home.dart';

class Wrapper extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final user = Provider.of<User>(context);
    if (user == null) {
      if (kIsWeb)
        return WebPageLogIn(isLogIn: true,);
      else
        return IntroScreen();
    } else {
      return Home();
    }
  }
}
