import 'package:Vertretung/logic/names.dart';
import 'package:Vertretung/logic/sharedPref.dart';
import 'package:Vertretung/services/cloudDatabase.dart';
import 'package:Vertretung/services/push_notifications.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future signInAnon() async {
    UserCredential result = await _auth.signInAnonymously();
    User user = result.user;
    return user;
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

  Future<String> linkAccountWithEmail(email, password) async {
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
        case "network-request-failed":
          return "Keine Verbindung";
        default:
          return "Ein unerwarteter Fehler ist aufgetreten.";
      }
    }
  }

  Future<void> signUp(String email, String password) async {
    await _auth.createUserWithEmailAndPassword(
        email: email, password: password);
  }

  ///first mobile registration is anonym. First web registration is not anonym
  Future<String> setupAccount(bool isAnonym, String name,
      [String email, String password]) async {
    try {
      if (isAnonym)
        await signInAnon();
      else
        await signUp(email, password);
    } catch (e) {
      return e.message;
    }

    CloudDatabase db = CloudDatabase();
    db.updateName(name);
    db.updateUserData(
      subjects: [],
      subjectsNot: [],
      schoolClass: await SharedPref().getString(Names.schoolClass),
      personalSubstitute: false,
      notificationOnChange: isAnonym,
      notificationOnFirstChange: false,
    );
    db.updateCustomSubjects(Names.subjectsCustom, []);
    db.updateCustomSubjects(Names.subjectsNotCustom, []);
    SharedPref sharedPref = SharedPref();
    sharedPref.setBool(Names.personalSubstitute, false);
    sharedPref.setBool(Names.notificationOnChange, isAnonym);
    sharedPref.setBool(Names.notificationOnFirstChange, false);
  }

  String getEmail() {
    return _auth.currentUser.email;
  }

  Future<String> signInEmail({email, password, context}) async {
    try {
      await _auth.signInWithEmailAndPassword(email: email, password: password);
      FirebaseAnalytics().logLogin(loginMethod: "email");
      await CloudDatabase().syncSettings();
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
        case "network-request-failed":
          return "Keine Verbindung";
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
        case "network-request-failed":
          return "Keine Verbindung";
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
        case "network-request-failed":
          return "Keine Verbindung";
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
