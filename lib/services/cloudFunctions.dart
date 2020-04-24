import 'package:Vertretung/main.dart';
import 'package:Vertretung/services/authService.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_core/firebase_core.dart';

class Functions{
  void callFriendRequest(String frienduid)async{
    CloudFunctions cf = CloudFunctions(app: FirebaseApp.instance,region: "europe-west3");
    final HttpsCallable  call = cf.getHttpsCallable(functionName: "addFriendRequest");
    AuthService _auth = AuthService();
    print(frienduid);
    String uid = await _auth.getUserId();
    print(uid);

    call.call(<String, dynamic>{
      "uid": uid,
      "frienduid": frienduid,
    });
  }
  void callAcceptFriendRequest(String frienduid)async{
    CloudFunctions cf = CloudFunctions(app: FirebaseApp.instance,region: "europe-west3");
    final HttpsCallable  call = cf.getHttpsCallable(functionName: "acceptFriendRequest");
    AuthService _auth = AuthService();
    print(frienduid);
    String uid = await _auth.getUserId();
    print(uid);

    call.call(<String, dynamic>{
      "uid": uid,
      "frienduid": frienduid,
    });
  }
}