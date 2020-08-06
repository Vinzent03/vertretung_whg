import 'package:Vertretung/logic/sharedPref.dart';
import 'package:Vertretung/logic/names.dart';
import 'package:Vertretung/services/authService.dart';
import 'package:Vertretung/services/push_notifications.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:package_info/package_info.dart';
import 'package:Vertretung/friends/friendModel.dart';

enum updateCodes { availableNormal, availableForce, notAvailable }

class CloudDatabase {
  final Firestore ref = Firestore.instance;

  void updateUserData(
      {personalSubstitute,
      schoolClass,
      subjects,
      subjectsNot,
      notification}) async {
    AuthService _auth = AuthService();
    String token = await PushNotificationsManager().getToken();
    DocumentReference doc =
        ref.collection("userdata").document(await _auth.getUserId());
    doc.setData({
      Names.subjects: subjects,
      Names.subjectsNot: subjectsNot,
      Names.personalSubstitute: personalSubstitute,
      Names.notification: notification,
      Names.schoolClass: schoolClass,
      "token": token,
    }, merge: true);
  }

  void updateCustomSubjects(
      String name, List<String> customSubjectsList) async {
    //name indicates whether to save as whitelist or blacklist
    AuthService _auth = AuthService();
    ref.collection("userdata").document(await _auth.getUserId()).updateData(
      {
        name: customSubjectsList,
      },
    );
  }

  void updateName(String newName) async {
    AuthService _auth = AuthService();
    DocumentReference doc =
        ref.collection("userdata").document(await _auth.getUserId());
    doc.setData({
      "name": newName,
    }, merge: true);
  }

  Future<String> getName() async {
    String uid = await AuthService().getUserId();
    DocumentSnapshot snap =
        await ref.collection("userdata").document(uid).get();
    return snap.data["name"] ?? "No internet connection";
  }

  Future<void> restoreAccount() async {
    AuthService _auth = AuthService();
    String uid = await _auth.getUserId();
    DocumentSnapshot userdataDoc =
        await ref.collection("userdata").document(uid).get();

    DocumentReference doc = ref.collection("userdata").document(uid);
    String token = await PushNotificationsManager().getToken();
    doc.updateData({
      "token": token,
    });

    SharedPref sharedPref = SharedPref();
    sharedPref.setString(
        Names.schoolClass, userdataDoc.data[Names.schoolClass]);
    sharedPref.setStringList(
        Names.subjects, List<String>.from(userdataDoc.data[Names.subjects]));
    sharedPref.setStringList(Names.subjectsNot,
        List<String>.from(userdataDoc.data[Names.subjectsNot]));
    sharedPref.setStringList(Names.subjectsCustom,
        List<String>.from(userdataDoc.data[Names.subjectsCustom]));
    sharedPref.setStringList(Names.subjectsNotCustom,
        List<String>.from(userdataDoc.data[Names.subjectsNotCustom]));
    sharedPref.setBool(
        Names.personalSubstitute, userdataDoc.data[Names.personalSubstitute]);
    await sharedPref.setBool(
        Names.notification, userdataDoc.data[Names.notification]);
  }

  //Updates
  Future<updateCodes> getUpdate() async {
    PackageInfo pa = await PackageInfo.fromPlatform();
    String version = pa.version;
    bool updateAvailable = true;
    bool forceUpdate;
    try {
      DocumentSnapshot snap =
          await ref.collection("details").document("versions").get();
      updateAvailable = snap.data["newVersion"] != version;
      forceUpdate = snap.data["forceUpdate"];
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

  Future<String> getUpdateLink() async {
    DocumentSnapshot snap =
        await ref.collection("details").document("links").get();
    return snap.data["newLink"];
  }

  Future<List<dynamic>> getUpdateMessage() async {
    DocumentSnapshot snap =
        await ref.collection("details").document("versions").get();
    return snap.data["message"];
  }

  //News
  Future<List<dynamic>> getNews() async {
    DocumentSnapshot snap = await ref.collection("news").document("news").get();
    return snap.data["news"];
  }

  // friends
  Future<List<dynamic>> getFriendRequests() async {
    List<FriendModel> friendRequests = [];
    AuthService _auth = AuthService();
    String uid = await _auth.getUserId();
    try {
      DocumentSnapshot myFriendsDoc =
          await ref.collection("userFriends").document(uid).get();
      for (String friendUid in myFriendsDoc.data["requests"]) {
        DocumentSnapshot friendDoc =
            await ref.collection("userdata").document(friendUid).get();
        friendRequests.add(
          FriendModel(name: friendDoc.data["name"], uid: friendUid),
        );
      }
      return friendRequests;
    } catch (e) {
      return [];
    }
  }

  Future<void> removeFriend(String frienduid) async {
    AuthService _auth = AuthService();
    String uid = await _auth.getUserId();

    DocumentReference doc = ref.collection("userFriends").document(uid);
    DocumentSnapshot snap = await doc.get();
    List<dynamic> friends = List<String>.from(snap.data["friends"]);
    friends.remove(frienduid);
    return await doc.updateData({"friends": friends});
  }

  Future<List<FriendModel>> getFriendsList() async {
    List<FriendModel> friendList = [];
    AuthService _auth = AuthService();
    String uid = await _auth.getUserId();
    DocumentSnapshot myFriendsDoc =
        await ref.collection("userFriends").document(uid).get();
    try {
      for (String friendUid in myFriendsDoc.data["friends"]) {
        DocumentSnapshot friendsDoc =
            await ref.collection("userdata").document(friendUid).get();
        String friendName = friendsDoc.data["name"];
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
