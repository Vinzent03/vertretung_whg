import 'package:Vertretung/logic/sharedPref.dart';
import 'package:Vertretung/services/cloudDatabase.dart';
import 'package:Vertretung/services/push_notifications.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future signInAnon() async {
    try {
      AuthResult result = await _auth.signInAnonymously();
      FirebaseUser user = result.user;
      return user;
    } catch (e) {
      print(e.toString());
      return null;
    }
  }

  Future<String> getUserId() async {
    FirebaseUser user = await _auth.currentUser();
    return user?.uid;
  }

  Stream<FirebaseUser> get user {
    return _auth.onAuthStateChanged;
  }

  Future signOut({bool deleteAccount = false}) async {
    var user = await _auth.currentUser();
    try {
      await PushNotificationsManager().signOut();
      if (user.isAnonymous || deleteAccount) {
        await user.delete();
      }
      await _auth.signOut();
      SharedPref().clear();
    } catch (e) {
      return e.toString();
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
      FirebaseAnalytics().logSignUp(signUpMethod: "email");
    } catch (e) {
      print(e.toString());
      switch (e.code) {
        case "ERROR_WEAK_PASSWORD":
          return "Das Passwort ist zu schwach.";
          break;
        case "ERROR_EMAIL_ALREADY_IN_USE  ":
          return "Diese Email wird bereits genutzt.";
          break;
        case "ERROR_INVALID_EMAIL":
          return "Dies scheint keine richte E-Mail zu sein.";
          break;
        case "ERROR_USER_DISABLED":
          return "Dieses Konto wurde deaktiviert";
          break;
        default:
          return "Ein unerwarteter Fehler ist aufgetreten.";
      }
    }
  }

  Future<String> getEmail() async {
    FirebaseUser user = await _auth.currentUser();
    return user.email;
  }

  Future<String> signInEmail({email, password, context}) async {
    try {
      AuthResult res = await _auth.signInWithEmailAndPassword(
          email: email, password: password);
      FirebaseAnalytics().logLogin(loginMethod: "email");
      await CloudDatabase().restoreAccount();
    } catch (e) {
      print(e.toString());
      switch (e.code) {
        case "ERROR_INVALID_EMAIL":
          return "Dies scheint keine richte E-Mail zu sein.";
          break;
        case "ERROR_WRONG_PASSWORD":
          return "Falsches Passwort";
          break;
        case "ERROR_USER_NOT_FOUND":
          return "Kein Konto mit der Email gefunden";
          break;
        case "ERROR_USER_DISABLED":
          return "Dieses Konto wurde deaktiviert";
          break;
        case "ERROR_TOO_MANY_REQUESTS":
          return "Zu viele Anfragen, versuche es später erneut";
          break;
        case "ERROR_OPERATION_NOT_ALLOWED":
          return "Diese Methode ist nicht aktiviert";
          break;
        default:
          return "An undefined Error happened.";
      }
    }
  }

  reAuthenticate(password) async {
    FirebaseUser user = await _auth.currentUser();
    AuthCredential credential =
        EmailAuthProvider.getCredential(email: user.email, password: password);
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
  }

  Future<String> changePassword({oldPassword, newPassword}) async {
    FirebaseUser user = await _auth.currentUser();
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

  Future<bool> getAdminStatus() async {
    //prevent internet issue
    try {
      FirebaseUser user = await _auth.currentUser();
      var claims = await user.getIdToken();
      return claims.claims["admin"] ?? false;
    } catch (e) {
      return false;
    }
  }
}
