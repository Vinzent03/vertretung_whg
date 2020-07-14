import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_core/firebase_core.dart';

class Functions {
  CloudFunctions cf;
  Functions() {
    cf = CloudFunctions(app: FirebaseApp.instance, region: "europe-west3");
    //used to use the emulated firebaes cloud functions
    //cf.useFunctionsEmulator(origin: "http://x.x.x.x:5001");
  }

  Future<dynamic> addFriendRequest(String frienduid) async {
    try {
      HttpsCallable call =
          cf.getHttpsCallable(functionName: "addFriendRequest");
      print(frienduid);
      HttpsCallableResult result = await call.call(<String, dynamic>{
        "frienduid": frienduid,
      });
      return result.data;
    } catch (e) {
      return throwError(e);
    }
  }

  Future<dynamic> acceptFriendRequest(String frienduid) async {
    try {
      final HttpsCallable call =
          cf.getHttpsCallable(functionName: "acceptFriendRequest");
      call.call(<String, dynamic>{
        "frienduid": frienduid,
      });
    } catch (e) {
      return throwError(e);
    }
  }

  Future<dynamic> declineFriendRequest(String frienduid) async {
    try {
      final HttpsCallable call =
          cf.getHttpsCallable(functionName: "declineFriendRequest");
      call.call(<String, dynamic>{
        "frienduid": frienduid,
      });
    } catch (e) {
      return throwError(e);
    }
  }

  Future<dynamic> addNews(newNews) async {
    try {
      HttpsCallable call = cf.getHttpsCallable(functionName: "addNews");
      HttpsCallableResult result = await call.call(<String, dynamic>{
        "newNews": newNews,
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

  Future<dynamic> editNews(index, newNews) async {
    try {
      HttpsCallable call = cf.getHttpsCallable(functionName: "editNews");

      HttpsCallableResult result = await call
          .call(<String, dynamic>{"index": index, "newNews": newNews});
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
