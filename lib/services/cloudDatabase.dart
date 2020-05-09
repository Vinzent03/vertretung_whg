import 'package:Vertretung/logic/localDatabase.dart';
import 'package:Vertretung/logic/names.dart';
import 'package:Vertretung/services/authService.dart';
import 'package:Vertretung/services/push_notifications.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:package_info/package_info.dart';
import 'package:Vertretung/services/cloudFunctions.dart';

class CloudDatabase {
  final Firestore ref = Firestore.instance;

  ////////////UserData
  void updateUserData(
      {faecherOn, stufe, faecher, faecherNot, notification, name}) async {
    AuthService _auth = AuthService();
    String token = await PushNotificationsManager().getToken();
    print("data wurde gesettet");
    DocumentReference doc =
        ref.collection("userdata").document(await _auth.getUserId());
    doc.setData({
      "faecher": faecher,
      "faecherNot": faecherNot,
      "faecherOn": faecherOn,
      "notification": notification,
      "stufe": stufe,
      "token": token,
      "name": name,
    });
  }

  void updateFaecher({list, bool isWhitelist}) async {
    AuthService _auth = AuthService();
    DocumentReference doc =
        ref.collection("userdata").document(await _auth.getUserId());
    if (isWhitelist)
      doc.updateData({
        "faecher": list,
      });
    else
      doc.updateData({
        "faecherNot": list,
      });
  }

  void updateName(String newName) async {
    AuthService _auth = AuthService();
    DocumentReference doc =
        ref.collection("userdata").document(await _auth.getUserId());
    doc.updateData({
      "name": newName,
    });
  }

  void deleteDocument() async {
    AuthService _auth = AuthService();
    await ref.collection("userdata").document(await _auth.getUserId()).delete();
  }

  void restoreAccount() async {
    String uid = await AuthService().getUserId();
    DocumentSnapshot snap =
        await ref.collection("userdata").document(uid).get();
    LocalDatabase local = LocalDatabase();
    local.setString(Names.stufe, snap.data["stufe"]);
    local.setString(Names.name, snap.data["name"]);
    local.setString(Names.newsAnzahl, "0");
    local.setStringList(
        Names.faecherList, List<String>.from(snap.data["faecher"]));
    local.setStringList(
        Names.faecherNotList, List<String>.from(snap.data["faecherNot"]));
    local.setBool(Names.faecherOn, snap.data["faecherOn"]);
    local.setBool(Names.notification, snap.data["notification"]);
  }

  /////// Upddates
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

  ///////  News
  Future<bool> getIsNewAvailable() async {
    int localNewsAnzahl =
        int.parse(await LocalDatabase().getString(Names.newsAnzahl));

    DocumentSnapshot doc =
        await ref.collection("details").document("news").get();

    int cloudNewsAnzahl = doc.data["news"].length;
    if (localNewsAnzahl < cloudNewsAnzahl) {
      return true;
    } else {
      return false;
    }
  }

  Future<List<dynamic>> getNews() async {
    DocumentSnapshot snap =
        await ref.collection("details").document("news").get();
    return snap.data["news"];
  }

  // friends
  Future<List<dynamic>> getFriendRequests() async {
    List<dynamic> list = [];
    AuthService _auth = AuthService();
    String uid = await _auth.getUserId();
    QuerySnapshot snap = await ref
        .collection("userFriends")
        .document(uid)
        .collection("requests")
        .getDocuments();
    snap.documents.forEach(
        (doc) => ref.collection("userdata").document(doc.documentID).get().then(
              (friendDoc) => list.add({
                "name": friendDoc.data["name"],
                "frienduid": doc.documentID,
              }),
            ));
    return list;
  }

  void removeFriend(String frienduid) async {
    AuthService _auth = AuthService();
    String uid = await _auth.getUserId();

    DocumentReference doc = await ref
        .collection("userFriends")
        .document(uid)
        .collection("friends")
        .document(frienduid);
    doc.delete();
  }

  Future<List<dynamic>> getFriendsList() async {
    List<dynamic> list = [];
    AuthService _auth = AuthService();
    String uid = await _auth.getUserId();
    QuerySnapshot snap = await ref
        .collection("userFriends")
        .document(uid)
        .collection("friends")
        .getDocuments();
    for (DocumentSnapshot doc in snap.documents) {
      DocumentSnapshot snap1 =
          await ref.collection("userdata").document(doc.documentID).get();
      String st = snap1.data["name"];
      list.add({
        "name": st,
        "frienduid": doc.documentID,
      });
    }
    return list;
  }
}
