import 'package:Vertretung/services/cloudDatabase.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuthService{
  final FirebaseAuth _auth = FirebaseAuth.instance;
  //sign in anon
  Future signInAnon()async{
    try{
      AuthResult result = await _auth.signInAnonymously();
      FirebaseUser user = result.user;
      UserUpdateInfo userUpdateInfo = new UserUpdateInfo();
      userUpdateInfo.displayName = "Tom";
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
        CloudDatabase().deleteDocument();
        user.delete();
      }

      return await _auth.signOut();
    }catch(e){
      print("Couldnt log out");
      return null;
    }
}

}