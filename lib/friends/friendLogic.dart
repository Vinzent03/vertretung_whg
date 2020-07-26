import 'package:Vertretung/logic/filter.dart';
import 'package:Vertretung/logic/sharedPref.dart';
import 'package:Vertretung/logic/names.dart';
import 'package:Vertretung/services/authService.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:progress_dialog/progress_dialog.dart';
import 'package:Vertretung/friends/friendModel.dart';
import 'package:connectivity/connectivity.dart';
import 'package:Vertretung/services/cloudFunctions.dart';
import 'package:flutter/services.dart';

class FriendLogic {
  final Firestore ref = Firestore.instance;
  SharedPref sharedPref = SharedPref();
  List<String> rawSubstituteList;
  List<FriendModel> friends = [];

  Future<void> setFriendsSettings() async {
    for (var friend in friends) {
      DocumentSnapshot snap =
          await ref.collection("userdata").document(friend.uid).get();
      friend.subjects = snap.data[Names.subjects];
      friend.subjectsNot = snap.data[Names.subjectsNot];
      friend.personalSubstitute = snap.data[Names.personalSubstitute];
      friend.schoolClass = snap.data[Names.schoolClass];
    }
  }

  List _getSubstituteOfFriend(FriendModel friend) {
    Filter filter = Filter(friend.schoolClass, rawSubstituteList);
    if (friend.personalSubstitute) {
      var list = filter.checkForSubjects(
          Names.substituteToday, friend.subjects, friend.subjectsNot);
      return list;
    } else {
      var list = filter.checkForSchoolClass(
        Names.substituteToday,
      );
      return list;
    }
  }

  Future<dynamic> getFriendsSubstitute() async {
    List<Map<String, String>> friendsSubstitute = [];
    rawSubstituteList = await sharedPref.getStringList(Names.substituteToday);

    for (var friend in friends) {
      List<dynamic> list = _getSubstituteOfFriend(friend);
      for (var substitute in list) {
        if (friendsSubstitute.isNotEmpty) {
          List<String> temporarilyfriendVertretung = [];
          for (var st in friendsSubstitute) {
            temporarilyfriendVertretung.add(st["ver"]);
          }

          if (temporarilyfriendVertretung.contains(substitute["ver"])) {
            //add the name to the list who have this Substitute
            for (var oldVer in friendsSubstitute) {
              if (oldVer["ver"] == substitute["ver"]) {
                oldVer["name"] = oldVer["name"] + ", " + friend.name;
              }
            }
          } else {
            //nobody else has this Substitute
            friendsSubstitute.add({
              "name": friend.name,
              "ver": substitute["ver"],
              "subjectPrefix": substitute["subjectPrefix"]
            });
          }
        } else {
          //first Substitute in the List
          friendsSubstitute.add({
            "name": friend.name,
            "ver": substitute["ver"],
            "subjectPrefix": substitute["subjectPrefix"]
          });
        }
      }
    }
    return friendsSubstitute;
  }

  Future<void> updateFriendsList(List<FriendModel> newFriends) async {
    friends = newFriends;
    await setFriendsSettings();
  }

  addFriendAlert(scaffoldContext) async {
    final TextEditingController controller = TextEditingController();
    ClipboardData clipboardData = await Clipboard.getData("text/plain");
    final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
    bool _autoValidate = false;
    String message;
    String uid;
    bool error = false;
    ProgressDialog pr = ProgressDialog(scaffoldContext,
        type: ProgressDialogType.Normal, isDismissible: false, showLogs: false);
    AuthService().getUserId().then((value) => uid = value.substring(0, 5));
    if (clipboardData != null) {
      if (clipboardData.text.length ==
          25) //If the user has the complete share sentence
        controller.text = clipboardData.text.substring(20);
      if (clipboardData.text.length == 5)
        controller.text = clipboardData.text; //if the user has just the code
    }

    String isValid(st) {
      if (error) return message;
      if (st == uid) {
        return "Du kannst dich nicht selbst hinzufügen";
      }
      if (st.length != 5) {
        return "Der Token muss 5 Zeichen lang sein";
      }

      return null;
    }

    bool _validateInputs() {
      if (_formKey.currentState.validate()) {
        return true;
      } else {
        _autoValidate = true;
        return false;
      }
    }

    showDialog(
      context: scaffoldContext,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(15))),
          title: Text("Gib den Token deines Freundes ein"),
          content: Form(
            key: _formKey,
            child: TextFormField(
              controller: controller,
              autovalidate: _autoValidate,
              validator: isValid,
            ),
          ),
          actions: <Widget>[
            FlatButton(
              child: Text("abbrechen"),
              onPressed: () => Navigator.pop(context),
            ),
            RaisedButton(
              child: Text("Bestätigen"),
              // ignore: missing_return
              onPressed: () async {
                error = false;
                if (_validateInputs()) {
                  var connectivityResult =
                      await (Connectivity().checkConnectivity());
                  if (connectivityResult == ConnectivityResult.none) {
                    Navigator.pop(context);
                    return Scaffold.of(scaffoldContext).showSnackBar(SnackBar(
                      content: Text("Keine Verbindung"),
                      behavior: SnackBarBehavior.floating,
                    ));
                  }
                  await pr.show();
                  var result =
                      await Functions().addFriendRequest(controller.text);
                  await pr.hide();
                  switch (result["code"]) {
                    case "SUCCESS":
                      Navigator.pop(context);
                      Scaffold.of(scaffoldContext).showSnackBar(SnackBar(
                        content: Text("Freundesanfrage geschickt"),
                      ));
                      break;
                    case "EXCEPTION_ALREADY_REQUESTED":
                      message = result["message"];
                      error = true;
                      _validateInputs();
                      break;
                    case "EXCEPTION_ALREADY_FRIEND":
                      message = result["message"];
                      error = true;
                      _validateInputs();
                      break;
                    case "EXCEPTION_CANT_FIND_FRIEND":
                      message = result["message"];
                      error = true;
                      _validateInputs();
                      break;
                    case "DEADLINE_EXCEEDED":
                      Navigator.pop(context);
                      Scaffold.of(scaffoldContext).showSnackBar(
                        SnackBar(
                          content: Text(
                              "Das hat zu lange gedauert. Versuche es später erneut."),
                          duration: Duration(seconds: 5),
                        ),
                      );
                      break;
                    default:
                      Navigator.pop(context);
                      Scaffold.of(scaffoldContext).showSnackBar(
                        SnackBar(
                          content: Text(
                              "Ein unerwarteter Fehler ist aufgetreten: \"" +
                                  result["code"] +
                                  "\""),
                          duration: Duration(minutes: 1),
                        ),
                      );
                  }
                }
              },
            ),
          ],
        );
      },
    );
  }

  acceptFriendPerDynamicLink(GlobalKey<NavigatorState> navigatorKey,
      String friendsShortUid, String name) async {
    String shortUid = (await AuthService().getUserId()).substring(0, 5);
    if (friendsShortUid == shortUid)
      return showDialog(
        context: navigatorKey.currentState.overlay.context,
        builder: (context) => AlertDialog(
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(15))),
          title: Text(
              "Dies ist dein eigener Link. Du kannst dir nicht selbst eine Freundesanfrage schicken."),
          actions: <Widget>[
            RaisedButton(
              child: Text("OK"),
              onPressed: () => Navigator.pop(context),
            ),
          ],
        ),
      );
    showDialog(
      context: navigatorKey.currentState.overlay.context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(15))),
          title: Text("Möchtest du $name eine Freundesanfrage schicken?"),
          actions: <Widget>[
            FlatButton(
              child: Text("Abbrechen"),
              onPressed: () => Navigator.pop(context),
            ),
            RaisedButton(
              child: Text("Bestätigen"),
              onPressed: () {
                Functions().addFriendRequest(friendsShortUid);
                Navigator.pop(context);
              },
            ),
          ],
        );
      },
    );
  }
}
