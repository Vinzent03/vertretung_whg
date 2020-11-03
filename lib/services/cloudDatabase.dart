import 'package:Vertretung/logic/sharedPref.dart';
import 'package:Vertretung/logic/names.dart';
import 'package:Vertretung/models/newsModel.dart';
import 'package:Vertretung/models/substituteModel.dart';
import 'package:Vertretung/services/authService.dart';
import 'package:Vertretung/services/push_notifications.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:package_info/package_info.dart';
import 'package:Vertretung/models/friendModel.dart';

enum updateCodes { availableNormal, availableForce, notAvailable }

class CloudDatabase {
  final FirebaseFirestore ref = FirebaseFirestore.instance;
  String uid = AuthService().getUserId();

  void updateUserData({
    @required personalSubstitute,
    @required schoolClass,
    @required subjects,
    @required subjectsNot,
    @required notificationOnChange,
    @required notificationOnFirstChange,
  }) async {
    updateToken();
    DocumentReference doc = ref.collection("userdata").doc(uid);
    doc.set({
      Names.subjects: subjects,
      Names.subjectsNot: subjectsNot,
      Names.personalSubstitute: personalSubstitute,
      Names.notificationOnChange: notificationOnChange,
      Names.notificationOnFirstChange: notificationOnFirstChange,
      Names.schoolClass: schoolClass,
    }, SetOptions(merge: true));
  }

  void updateToken() async {
    String token = await PushNotificationsManager().getToken();
    DocumentReference doc = ref.collection("userdata").doc(uid);
    if (!kIsWeb) doc.update({"token": token});
  }

  void updateCustomSubjects(
      String name, List<String> customSubjectsList) async {
    //name indicates whether to save as whitelist or blacklist
    ref.collection("userdata").doc(uid).update(
      {
        name: customSubjectsList,
      },
    );
  }

  void updateFreeLessons(List<String> newFreeLessons) async {
    ref.collection("userdata").doc(uid).update(
      {
        "freeLessons": newFreeLessons,
      },
    );
  }

  void updateLastNotification(List<SubstituteModel> substitute) async {
    List<String> justSubstitute = [];
    for (SubstituteModel item in substitute) {
      justSubstitute.add(item.title);
    }
    DocumentReference doc = ref.collection("userdata").doc(uid);
    doc.set({"lastNotification": justSubstitute}, SetOptions(merge: true));
  }

  void updateName(String newName) async {
    DocumentReference doc = ref.collection("userdata").doc(uid);
    doc.set({
      "name": newName.trim(),
    }, SetOptions(merge: true));
  }

  Future<String> getName() async {
    DocumentSnapshot snap = await ref.collection("userdata").doc(uid).get();
    return snap.data()["name"] ?? "No internet connection";
  }

  Future<void> syncSettings() async {
    DocumentSnapshot userdataDoc =
        await ref.collection("userdata").doc(uid).get();

    updateToken();

    SharedPref sharedPref = SharedPref();
    sharedPref.setString(
        Names.schoolClass, userdataDoc.data()[Names.schoolClass]);
    sharedPref.setStringList(
        Names.subjects, List<String>.from(userdataDoc.data()[Names.subjects]));
    sharedPref.setStringList(Names.subjectsNot,
        List<String>.from(userdataDoc.data()[Names.subjectsNot]));
    sharedPref.setStringList(Names.subjectsCustom,
        List<String>.from(userdataDoc.data()[Names.subjectsCustom]));
    sharedPref.setStringList(Names.subjectsNotCustom,
        List<String>.from(userdataDoc.data()[Names.subjectsNotCustom]));
    sharedPref.setStringList(Names.freeLessons,
        List<String>.from(userdataDoc.data()[Names.freeLessons] ?? []));
    sharedPref.setBool(
        Names.personalSubstitute, userdataDoc.data()[Names.personalSubstitute]);
    sharedPref.setBool(Names.notificationOnChange,
        userdataDoc.data()[Names.notificationOnChange]);
    await sharedPref.setBool(Names.notificationOnFirstChange,
        userdataDoc.data()[Names.notificationOnFirstChange]);
  }

  //Updates
  Future<updateCodes> getUpdate() async {
    PackageInfo pa = await PackageInfo.fromPlatform();
    String version = pa.version;
    bool updateAvailable = true;
    bool forceUpdate;
    try {
      DocumentSnapshot snap =
          await ref.collection("details").doc("versions").get();
      updateAvailable = snap.data()["newVersion"] != version;
      forceUpdate = snap.data()["forceUpdate"];
      if (updateAvailable) {
        if (forceUpdate) {
          return updateCodes.availableForce;
        } else {
          return updateCodes.availableNormal;
        }
      } else {
        return updateCodes.notAvailable;
      }
    } catch (e) {
      return updateCodes.notAvailable;
    }
  }

  Future<Map<String, String>> getUpdateLinks() async {
    DocumentSnapshot snap = await ref.collection("details").doc("links").get();
    return {
      "download": snap.data()["downloadLink"],
      "changelog": snap.data()["changelogLink"]
    };
  }

  Future<List<dynamic>> getUpdateMessage() async {
    DocumentSnapshot snap =
        await ref.collection("details").doc("versions").get();
    return snap.data()["message"];
  }

  //News
  Stream<List<NewsModel>> getNews() {
    Stream<DocumentSnapshot> snap =
        ref.collection("news").doc("news").snapshots();
    return snap.map((event) => (event.data()["news"] as List)
        .map((e) => NewsModel(e["title"], e["text"], e["lastEdited"]))
        .toList());
  }

  // friends
  Future<void> removeFriend(String frienduid) async {
    DocumentReference doc = ref.collection("userdata").doc(uid);
    DocumentSnapshot snap = await doc.get();
    List<dynamic> friends = List<String>.from(snap.data()["friends"]);
    friends.remove(frienduid);
    return await doc.update({"friends": friends});
  }

  Future<List<FriendModel>> getFriendsList() async {
    List<FriendModel> friendList = [];
    DocumentSnapshot myFriendsDoc =
        await ref.collection("userdata").doc(uid).get();
    try {
      for (String friendUid in myFriendsDoc.data()["friends"]) {
        DocumentSnapshot friendsDoc =
            await ref.collection("userdata").doc(friendUid).get();
        String friendName = friendsDoc.data()["name"];
        friendList.add(FriendModel(name: friendName, uid: friendUid));
      }
      friendList.sort((friendA, friendB) {
        return friendA.name.toLowerCase().compareTo(friendB.name.toLowerCase());
      });
      return friendList;
    } catch (e) {
      return [];
    }
  }

  ///only used for web app
  Future<List<dynamic>> getSubstitute() async {
    DocumentSnapshot data = await ref.collection("details").doc("webapp").get();
    String lastChange = data.data()["lastChange"];
    return [
      lastChange.substring(17, 23) + lastChange.substring(27),
      List<String>.from(data.data()["substituteToday"]),
      List<String>.from(data.data()["substituteTomorrow"])
    ];
  }
}
