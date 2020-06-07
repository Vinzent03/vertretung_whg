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

  Future<dynamic> addNews(newNews) async {
    CloudFunctions cf =
        CloudFunctions(app: FirebaseApp.instance, region: "europe-west3");
    HttpsCallable call = cf.getHttpsCallable(functionName: "addNews");

    HttpsCallableResult result = await call.call(<String, dynamic>{
      "newNews": newNews,
    });
    return result.data;
  }

  Future<dynamic> deleteNews(index) async {
    CloudFunctions cf =
        CloudFunctions(app: FirebaseApp.instance, region: "europe-west3");
    HttpsCallable call = cf.getHttpsCallable(functionName: "deleteNews");

    HttpsCallableResult result = await call.call(<String, dynamic>{
      "index": index,
    });
    return result.data;
  }

  Future<dynamic> editNews(index, newNews) async {
    CloudFunctions cf =
        CloudFunctions(app: FirebaseApp.instance, region: "europe-west3");
    HttpsCallable call = cf.getHttpsCallable(functionName: "editNews");

    HttpsCallableResult result =
        await call.call(<String, dynamic>{"index": index, "newNews": newNews});
    return result.data;
  }
}
