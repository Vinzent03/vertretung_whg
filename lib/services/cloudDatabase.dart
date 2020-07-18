import 'package:Vertretung/logic/localDatabase.dart';
import 'package:Vertretung/logic/names.dart';
import 'package:Vertretung/services/authService.dart';
import 'package:Vertretung/services/push_notifications.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:package_info/package_info.dart';
import 'package:Vertretung/friends/friendModel.dart';

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
      "subjects": subjects,
      "subjectsNot": subjectsNot,
      "personalSubstitute": personalSubstitute,
      "notification": notification,
      "schoolClass": schoolClass,
      "token": token,
    }, merge: true);
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
    return snap.data["name"];
  }

  Future<void> restoreAccount() async {
    AuthService _auth = AuthService();
    String uid = await _auth.getUserId();
    DocumentSnapshot snap =
        await ref.collection("userdata").document(uid).get();

    //update the token
    DocumentReference doc = ref.collection("userdata").document(uid);
    String token = await PushNotificationsManager().getToken();
    doc.updateData({
      "token": token,
    });

    LocalDatabase local = LocalDatabase();
    local.setString(Names.schoolClass, snap.data["schoolClass"]);
    local.setStringList(
        Names.subjectsList, List<String>.from(snap.data["subjects"]));
    local.setStringList(
        Names.subjectsNotList, List<String>.from(snap.data["subjectsNot"]));
    local.setBool(Names.personalSubstitute, snap.data["personalSubstitute"]);
    await local.setBool(Names.notification, snap.data["notification"]);
  }

  //Upddates
  Future<String> getUpdate() async {
    PackageInfo pa = await PackageInfo.fromPlatform();
    String version = pa.version;
    bool updateAvaible = true;
    bool forceUpdate;
    DocumentSnapshot snap =
        await ref.collection("details").document("versions").get();
    updateAvaible = snap.data["newVersion"] != version;
    forceUpdate = snap.data["forceUpdate"];
    if (updateAvaible) {
      if (forceUpdate) {
        return "forceUpdate";
      } else {
        return "updateAvaible";
      }
    } else {
      return "noUpdateAvaible";
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
    DocumentSnapshot myFriendsDoc =
        await ref.collection("userFriends").document(uid).get();
    try {
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
