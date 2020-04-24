import 'package:Vertretung/pages/vertretung.dart';
import 'package:Vertretung/pages/introScreen.dart';
import 'package:Vertretung/services/push_notifications.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'home.dart';

class Wrapper extends StatelessWidget{
  Wrapper(){
    // Push-Notification handling
    PushNotificationsManager().init();
  }
  @override
  Widget build(BuildContext context){
    final user = Provider.of<FirebaseUser>(context);
    print(user== null ?"Kein konto":user.uid);
    if(user == null){
      return IntroScreen();
    }else{
      return Home();
    }
  }
}
