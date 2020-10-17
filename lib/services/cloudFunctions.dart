import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_core/firebase_core.dart';

class Functions {
  CloudFunctions cf;
  Functions() {
    cf = CloudFunctions(app: Firebase.app(), region: "europe-west3");
    //used to use the emulated firebase cloud functions
    //cf.useFunctionsEmulator(origin: "http://x.x.x.x:5001");
  }

  Future<dynamic> addFriend(
      String shortFriendUid, bool addFriendToYourself) async {
    try {
      final HttpsCallable call = cf.getHttpsCallable(functionName: "addFriend");
      return (await call.call(<String, dynamic>{
        "friendUid": shortFriendUid,
        "addFriendToYourself": addFriendToYourself.toString(),
      }))
          .data;
    } catch (e) {
      return throwError(e);
    }
  }

  Future<dynamic> addNews(Map newNews, bool sendNotification) async {
    try {
      HttpsCallable call = cf.getHttpsCallable(functionName: "addNews");
      HttpsCallableResult result = await call.call(<String, dynamic>{
        "newNews": newNews,
        "sendNotification": sendNotification
      });
      return result.data;
    } catch (e) {
      return throwError(e);
    }
  }

  Future<dynamic> deleteNews(index) async {
    try {
      HttpsCallable call = cf.getHttpsCallable(functionName: "deleteNews");

      HttpsCallableResult result = await call.call(<String, dynamic>{
        "index": index,
      });
      return result.data;
    } catch (e) {
      return throwError(e);
    }
  }

  Future<dynamic> editNews(
      int index, Map newNews, bool sendNotification) async {
    try {
      HttpsCallable call = cf.getHttpsCallable(functionName: "editNews");

      HttpsCallableResult result = await call.call(<String, dynamic>{
        "index": index,
        "newNews": newNews,
        "sendNotification": sendNotification
      });
      return result.data;
    } catch (e) {
      return throwError(e);
    }
  }

  dynamic throwError(dynamic e) {
    try {
      return {"code": e.details["code"], "message": e.details["message"]};
    } catch (e) {
      return {"code": e.code, "message": e.message};
    }
  }
}
