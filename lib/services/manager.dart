import 'package:Vertretung/logic/getter.dart';
import 'package:Vertretung/logic/names.dart';
import 'package:Vertretung/services/push_notifications.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:package_info/package_info.dart';

class Manager {
  final Firestore ref = Firestore.instance;

  void updateUserData(
      {faecherOn, stufe, faecher, faecherNot, notification}) async {
    print("data wurde gesettet");
    String token = await PushNotificationsManager().getToken();
    DocumentReference doc = ref.collection("userdata").document(token);
    if (faecherOn != null) {
      doc.updateData({
        "faecherOn": faecherOn,
      }
      );
    }
    if (stufe != null) {
      doc.updateData({
        "stufe": stufe,
      }
      );
    }
    if (faecher != null) {
      doc.updateData({
        "faecher": faecher,
      }
      );
    }
    if (faecherNot != null) {
      doc.updateData({
        "faecherNot": faecherNot,
      }
      );
    }
    if (notification != null) {
      doc.updateData({
        "notification": notification,
      }
      );
    }
  }


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
  void createDocument()async{
    String token = await PushNotificationsManager().getToken();
    DocumentReference doc = ref.collection("userdata").document(token);
    doc.setData({
      "faecherOn":true,
      "stufe": "Laden",
      "faecher": ["Laden"],
      "faecherNot": ["Laden"],
      "notification": true,
    });
  }
  void deleteDocument() async {
    await ref
        .collection("userdata")
        .document(await PushNotificationsManager().getToken())
        .delete();
  }

  Future<bool> getIsNewsAvailable() async {
    int localNewsAnzahl = int.parse(await Getter().getString(Names.newsAnzahl));
 
    DocumentSnapshot doc = await ref.collection("details").document("news").get();

    int cloudNewsAnzahl = doc.data["news"].length;
    if(localNewsAnzahl < cloudNewsAnzahl){
      return true;
    }else{
      return false;
    }
  }
  Future<List<dynamic>> getNews()async {
   DocumentSnapshot snap= await ref.collection("details").document("news").get();
   return snap.data["news"];
  }
}
