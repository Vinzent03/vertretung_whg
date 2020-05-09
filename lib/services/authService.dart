import 'package:Vertretung/logic/localDatabase.dart';
import 'package:Vertretung/logic/names.dart';
import 'package:Vertretung/services/cloudDatabase.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'cloudFunctions.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  //sign in anon
  Future signInAnon() async {
    try {
      AuthResult result = await _auth.signInAnonymously();
      FirebaseUser user = result.user;
      UserUpdateInfo userUpdateInfo = new UserUpdateInfo();
      userUpdateInfo.displayName = "in den update profile gesetzt";
      user.updateProfile(userUpdateInfo);
      return user;
    } catch (e) {
      print(e.toString());
      return null;
    }
  }

  Future<String> getUserId() async {
    FirebaseUser user = await _auth.currentUser();
    return user.uid;
  }

  Stream<FirebaseUser> get user {
    return _auth.onAuthStateChanged;
  }

  //sign out
  Future signOut() async {
    var user = await _auth.currentUser();
    try {
      LocalDatabase local = LocalDatabase();
      local.setString(Names.stufe, "Nicht festgelegt");
      local.setString(Names.newsAnzahl, "0");
      local.setStringList(Names.faecherList, []);
      local.setStringList(Names.faecherNotList, []);
      local.setStringList(Names.faecherListCustom, []);
      local.setStringList(Names.faecherNotListCustom, []);
      local.setBool(Names.faecherOn, false);
      local.setBool(Names.dark, true);
      local.setBool(Names.notification, true);
      if (user.isAnonymous) {
        print("user deleted");
        return await user.delete();
      }
      print("ausgeloggt");
      return await _auth.signOut();
    } catch (e) {
      print("Couldnt log out");
      return null;
    }
  }

  Future<bool> isAnon() async {
    FirebaseUser user = await _auth.currentUser();
    return user.isAnonymous;
  }

  Future<String> signUp({email, password}) async {
    FirebaseUser user = await _auth.currentUser();
    AuthCredential credential =
        EmailAuthProvider.getCredential(email: email, password: password);
    try {
      AuthResult res = await user.linkWithCredential(credential);
    } catch (e) {
      return e.code;
    }
  }

  Future<String> getEmail() async {
    FirebaseUser user = await _auth.currentUser();
    return user.email;
  }

  Future<String> getName() async {
    FirebaseUser user = await _auth.currentUser();
    return user.displayName;
  }

  Future<String> updateName(String newName) async {
    FirebaseUser user = await _auth.currentUser();
    UserUpdateInfo info = UserUpdateInfo();
    info.displayName = newName;
    user.updateProfile(info);
    return user.displayName;
  }

  Future<String> signInEmail({email, password}) async {
    try {
      AuthResult res = await _auth.signInWithEmailAndPassword(
          email: email, password: password);
      CloudDatabase().restoreAccount();
    } catch (e) {
      switch (e.code) {
        case "ERROR_INVALID_EMAIL":
          return "Dies scheint keine richte E-Mail zu sein.";
          break;
        case "ERROR_WRONG_PASSWORD":
          return "Falsches Passwort";
          break;
        case "ERROR_USER_NOT_FOUND":
          return "Kein Konto mit der Email gefundend";
          break;
        case "ERRreturn OR_USER_DISABLED":
          return "Dieses Konto wurde deaktiviert";
          break;
        case "ERROR_TOO_MANY_REQUESTS":
          return "ZU viele Anfragen, versuche es später erneut";
          break;
        case "ERROR_OPERATION_NOT_ALLOWED":
          return "Diese Methode ist nicht aktiviert";
          break;
        default:
          return "An undefined Error happened.";
      }
    }
  }

  Future<String> changePassword({oldPassword, newPassword}) async {
    FirebaseUser user = await _auth.currentUser();
    AuthCredential credential = EmailAuthProvider.getCredential(
        email: user.email, password: oldPassword);
    try {
      AuthResult res = await user.reauthenticateWithCredential(credential);
    } catch (e) {
      switch (e.code) {
        case "ERROR_INVALID_CREDENTIAL":
          return "Deine Anmeldung ist ausgelaufen";
          break;
        case "ERROR_WRONG_PASSWORD":
          return "Falsches Passwort";
          break;
        case "ERROR_USER_DISABLED":
          return "Dieser Account wurde deaktiviert";
          break;
        case "ERROR_USER_NOT_FOUND":
          return "Dieses Konto wurde gelöscht";
          break;
        case "ERROR_OPERATION_NOT_ALLOWED":
          return "Das geht leider nicht, melde dich bei den Entwicklern";
          break;
        default:
          return "An undefined Error happened.";
      }
    }
    try {
      await user.updatePassword(newPassword);
    } catch (e) {
      switch (e.code) {
        case "ERROR_WEAK_PASSWORD":
          return "Das Passwort ist nicht stark genug";
          break;
        case "ERROR_USER_DISABLED":
          return "Dieser Account wurde deaktiviert";
          break;
        case "ERROR_USER_NOT_FOUND":
          return "Dieses Konto wurde gelöscht";
          break;
        case "ERROR_OPERATION_NOT_ALLOWED":
          return "Das geht leider nicht, melde dich bei den Entwicklern";
          break;
        default:
          return "An undefined Error happened.";
      }
    }
  }

  Future<String> resetPassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } catch (e) {
      switch (e.code) {
        case "ERROR_INVALID_EMAIL":
          return "Dies scheint keine richte E-Mail zu sein.";
          break;
        case "ERROR_USER_NOT_FOUND":
          return "Dieses Konto wurde gelöscht";
          break;
        default:
          return "An undefined Error happened.";
      }
    }
  }
}
