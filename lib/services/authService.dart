import 'package:Vertretung/logic/sharedPref.dart';
import 'package:Vertretung/services/cloudDatabase.dart';
import 'package:Vertretung/services/push_notifications.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future signInAnon() async {
    try {
      UserCredential result = await _auth.signInAnonymously();
      User user = result.user;
      return user;
    } catch (e) {
      print(e.toString());
      return null;
    }
  }

  String getUserId() {
    User user = _auth.currentUser;
    return user?.uid;
  }

  Stream<User> get user {
    return _auth.authStateChanges();
  }

  Future<void> signOut({bool deleteAccount = false}) async {
    var user = _auth.currentUser;
    await PushNotificationsManager().signOut();
    if (user.isAnonymous || deleteAccount)
      await user.delete();
    else
      _auth.signOut();
    await SharedPref().clear();
  }

  bool isAnon() {
    User user = _auth.currentUser;
    return user.isAnonymous;
  }

  Future<String> signUp({email, password}) async {
    User user = _auth.currentUser;
    AuthCredential credential =
        EmailAuthProvider.credential(email: email, password: password);
    try {
      await user.linkWithCredential(credential);
      FirebaseAnalytics().logSignUp(signUpMethod: "email");
    } catch (e) {
      switch (e.code) {
        case "weak-password":
          return "Das Passwort ist zu schwach.";
          break;
        case "email-already-in-use":
          return "Diese Email wird bereits genutzt.";
          break;
        case "invalid-email":
          return "Dies scheint keine richte E-Mail zu sein.";
          break;
        default:
          return "Ein unerwarteter Fehler ist aufgetreten.";
      }
    }
  }

  String getEmail() {
    return _auth.currentUser.email;
  }

  Future<String> signInEmail({email, password, context}) async {
    try {
      await _auth.signInWithEmailAndPassword(email: email, password: password);
      FirebaseAnalytics().logLogin(loginMethod: "email");
      await CloudDatabase().restoreAccount();
    } on FirebaseAuthException catch (e) {
      switch (e.code) {
        case "invalid-email":
          return "Dies scheint keine richte E-Mail zu sein.";
          break;
        case "wrong-password":
          return "Falsches Passwort";
          break;
        case "user-not-found":
          return "Kein Konto mit der Email gefunden";
          break;
        case "user-disabled":
          return "Dieses Konto wurde deaktiviert";
          break;
        default:
          return "An undefined Error happened.";
      }
    }
  }

  reAuthenticate(password) async {
    User user = _auth.currentUser;
    AuthCredential credential =
        EmailAuthProvider.credential(email: user.email, password: password);
    try {
      await user.reauthenticateWithCredential(credential);
    } catch (e) {
      switch (e.code) {
        case "wrong-password":
          return "Falsches Passwort";
          break;
        default:
          return "Ein unerwarteter Fehler ist aufgetreten.";
      }
    }
  }

  Future<String> changePassword({oldPassword, newPassword}) async {
    User user = _auth.currentUser;
    try {
      await user.updatePassword(newPassword);
    } catch (e) {
      switch (e.code) {
        case "weak-password":
          return "Das Passwort ist nicht stark genug";
          break;
        default:
          return "Ein unerwarteter Fehler ist aufgetreten.";
      }
    }
  }

  Future<String> resetPassword(String email) async {
    await _auth.sendPasswordResetEmail(email: email);
  }

  Future<bool> getAdminStatus() async {
    //prevent internet issue
    try {
      IdTokenResult claims = await _auth.currentUser.getIdTokenResult(true);
      return claims.claims["admin"] ?? false;
    } catch (e) {
      return false;
    }
  }
}
