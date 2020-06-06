import 'package:Vertretung/main.dart';
import 'package:Vertretung/services/authService.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_core/firebase_core.dart';

class Functions {
  Future<dynamic> callAddFriendRequest(String frienduid) async {
    CloudFunctions cf =
        CloudFunctions(app: FirebaseApp.instance, region: "europe-west3");
    HttpsCallable call = cf.getHttpsCallable(functionName: "addFriendRequest");
    print(frienduid);
    HttpsCallableResult result = await call.call(<String, dynamic>{
      "frienduid": frienduid,
    });
    return result.data;
  }

  void callAcceptFriendRequest(String frienduid) async {
    CloudFunctions cf =
        CloudFunctions(app: FirebaseApp.instance, region: "europe-west3");
    final HttpsCallable call =
        cf.getHttpsCallable(functionName: "acceptFriendRequest");
    call.call(<String, dynamic>{
      "frienduid": frienduid,
    });
  }

  void callDeclineFriendRequest(String frienduid) async {
    CloudFunctions cf =
        CloudFunctions(app: FirebaseApp.instance, region: "europe-west3");
    final HttpsCallable call =
        cf.getHttpsCallable(functionName: "declineFriendRequest");
    AuthService _auth = AuthService();
    print(frienduid);
    call.call(<String, dynamic>{
      "frienduid": frienduid,
    });
  }

  Future<void> callDeleteProfile() async {
    CloudFunctions cf =
        CloudFunctions(app: FirebaseApp.instance, region: "europe-west3");
    final HttpsCallable call =
        cf.getHttpsCallable(functionName: "deleteProfile");
    await call.call().whenComplete(() async {
      print("Konto gelöscht");
      await AuthService().signOut(deleteAccount: true);
      return;
    });
    return;
  }
}
