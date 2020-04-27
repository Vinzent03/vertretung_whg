import 'package:Vertretung/logic/localDatabase.dart';
import 'package:Vertretung/logic/names.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'cloudFunctions.dart';

class AuthService{
  final FirebaseAuth _auth = FirebaseAuth.instance;
  //sign in anon
  Future signInAnon()async{
    try{
      AuthResult result = await _auth.signInAnonymously();
      FirebaseUser user = result.user;
      UserUpdateInfo userUpdateInfo = new UserUpdateInfo();
      userUpdateInfo.displayName = "in den update profile gesetzt";
      user.updateProfile(userUpdateInfo);
      return user;

    }catch(e){
      print(e.toString());
      return null;
    }
  }

  Future<String> getUserId()async{
    FirebaseUser user = await _auth.currentUser();
    return user.uid;
  }
  void check(){
  }

  Stream<FirebaseUser> get user{
    return _auth.onAuthStateChanged;
  }

  //sign out
Future signOut()async{
    var user = await _auth.currentUser();
    try{
      if(user.isAnonymous){
        user.delete();
        LocalDatabase local = LocalDatabase();
        local.setString(Names.stufe, "Nicht festgelegt");
        local.setString(Names.name, "Nicht festgelegt");
        local.setString(Names.newsAnzahl, "0");
        local.setStringList(Names.faecherList, []);
        local.setStringList(Names.faecherNotList, []);
        local.setStringList(Names.faecherListCustom, []);
        local.setStringList(Names.faecherNotListCustom, []);
        local.setBool(Names.faecherOn, false);
        local.setBool(Names.dark, true);
        local.setBool(Names.notification, true);
      }

      return await _auth.signOut();
    }catch(e){
      print("Couldnt log out");
      return null;
    }
}

}