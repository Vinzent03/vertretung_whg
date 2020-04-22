import 'package:firebase_auth/firebase_auth.dart';

class AuthService{
  final FirebaseAuth _auth = FirebaseAuth.instance;
  //  https://www.youtube.com/watch?v=j_SJ7XmT2MM

  //sign in anon
  Future signInAnon()async{
    try{
      AuthResult result = await _auth.signInAnonymously();
      FirebaseUser user = result.user;
      return user;

    }catch(e){
      print(e.toString());
      return null;
    }
  }
  // sign in with email

  //register with anon

  //sign out

}