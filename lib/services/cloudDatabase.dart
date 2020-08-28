import 'package:Vertretung/logic/sharedPref.dart';
import 'package:Vertretung/logic/names.dart';
import 'package:Vertretung/services/authService.dart';
import 'package:Vertretung/services/push_notifications.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:package_info/package_info.dart';
import 'package:Vertretung/friends/friendModel.dart';

enum updateCodes { availableNormal, availableForce, notAvailable }

class CloudDatabase {
  final FirebaseFirestore ref = FirebaseFirestore.instance;
  String uid;

  CloudDatabase() {
    uid = AuthService().getUserId();
  }

  void updateUserData(
      {personalSubstitute,
      schoolClass,
      subjects,
      subjectsNot,
      notification}) async {
    String token = await PushNotificationsManager().getToken();
    DocumentReference doc = ref.collection("userdata").doc(uid);
    doc.set({
      Names.subjects: subjects,
      Names.subjectsNot: subjectsNot,
      Names.personalSubstitute: personalSubstitute,
      Names.notification: notification,
      Names.schoolClass: schoolClass,
      "token": token,
    }, SetOptions(merge: true));
  }

  void updateCustomSubjects(
      String name, List<String> customSubjectsList) async {
    //name indicates whether to save as whitelist or blacklist
    AuthService _auth = AuthService();
    ref.collection("userdata").doc(uid).update(
      {
        name: customSubjectsList,
      },
    );
  }

  void updateLastNotification(List<dynamic> substitute) async {
    List<String> justSubstitute = [];
    for (Map item in substitute) {
      justSubstitute.add(item["ver"]);
    }
    DocumentReference doc = ref.collection("userdata").doc(uid);
    doc.set({"lastNotification": justSubstitute}, SetOptions(merge: true));
  }

  void updateName(String newName) async {
    DocumentReference doc = ref.collection("userdata").doc(uid);
    doc.set({
      "name": newName,
    }, SetOptions(merge: true));
  }

  Future<String> getName() async {
    DocumentSnapshot snap = await ref.collection("userdata").doc(uid).get();
    return snap.data()["name"] ?? "No internet connection";
  }

  Future<void> restoreAccount() async {
    DocumentSnapshot userdataDoc =
        await ref.collection("userdata").doc(uid).get();

    DocumentReference doc = ref.collection("userdata").doc(uid);
    String token = await PushNotificationsManager().getToken();
    doc.update({
      "token": token,
    });

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
    sharedPref.setBool(
        Names.personalSubstitute, userdataDoc.data()[Names.personalSubstitute]);
    await sharedPref.setBool(
        Names.notification, userdataDoc.data()[Names.notification]);
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
  Future<List<dynamic>> getNews() async {
    DocumentSnapshot snap = await ref.collection("news").doc("news").get();
    return snap.data()["news"];
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
}
