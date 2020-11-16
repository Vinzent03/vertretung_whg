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

  Future<dynamic> addNews(String title, String text, List<String> schoolClasses,
      bool sendNotification) async {
    try {
      HttpsCallable call = cf.getHttpsCallable(functionName: "addNews");
      HttpsCallableResult result = await call.call(<String, dynamic>{
        "title": title,
        "text": text,
        "schoolClasses": schoolClasses,
        "sendNotification": sendNotification
      });
      return result.data;
    } catch (e) {
      return throwError(e);
    }
  }

  Future<dynamic> deleteNews(String id) async {
    try {
      HttpsCallable call = cf.getHttpsCallable(functionName: "deleteNews");

      HttpsCallableResult result = await call.call(<String, dynamic>{
        "id": id,
      });
      return result.data;
    } catch (e) {
      return throwError(e);
    }
  }

  Future<dynamic> editNews(
      String title, String text, String id, bool sendNotification) async {
    try {
      HttpsCallable call = cf.getHttpsCallable(functionName: "editNews");

      HttpsCallableResult result = await call.call(<String, dynamic>{
        "id": id,
        "title": title,
        "text": text,
        "sendNotification": sendNotification
      });
      return result.data;
    } catch (e) {
      return throwError(e);
    }
  }

  dynamic throwError(dynamic e) {
    print(e);
    try {
      return {"code": e.details["code"], "message": e.details["message"]};
    } catch (error) {
      return {"code": e.toString(), "message": e.toString()};
    }
  }
}
