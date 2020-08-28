import 'package:Vertretung/friends/addFriendPerDynamicLink.dart';
import 'package:Vertretung/logic/myKeys.dart';
import 'package:Vertretung/services/authService.dart';
import 'package:Vertretung/services/cloudDatabase.dart';
import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'package:flutter/material.dart';

class DynamicLink {
  Future handleDynamicLink() async {
    //if app is started from that link
    final PendingDynamicLinkData data =
        await FirebaseDynamicLinks.instance.getInitialLink();
    if (data != null) _handleDeepLink(data, true);

    //if app gets to foreground because auf that link
    FirebaseDynamicLinks.instance.onLink(
      onSuccess: (PendingDynamicLinkData dynamicLinkData) async {
        _handleDeepLink(dynamicLinkData, false);
      },
      onError: (OnLinkErrorException e) {
        print("Error: ${e.message}");
      },
    );
  }

  _handleDeepLink(PendingDynamicLinkData data, bool fromLaunch) async {
    final Uri deepLink = data?.link;
    if (fromLaunch) await Future.delayed(Duration(seconds: 1));
    if (AuthService().getUserId() == null) return;
    if (deepLink.pathSegments.contains("friendAdd")) {
      var parameters = deepLink.queryParameters;
      showDialog(
        context: MyKeys.navigatorKey.currentState.overlay.context,
        builder: (context) => AddFriendPerDynamicLink(
          friendUid: parameters["uid"],
          name: parameters["name"],
        ),
      );
    }
  }

  Future createLink() async {
    String name = await CloudDatabase().getName();
    String shortUid = (AuthService().getUserId()).substring(0, 5);
    final DynamicLinkParameters parameters = DynamicLinkParameters(
      uriPrefix: "https://vertretung.page.link",
      link: Uri.parse(
          "https://vertretung.page.link/friendAdd?uid=$shortUid&name=$name"),
      androidParameters: AndroidParameters(
        packageName: "com.vinzent.vertretung",
        fallbackUrl: Uri.parse(
            "https://github.com/Vinzent03/vertretung_whg/releases/latest"),
      ),
    );
    final ShortDynamicLink shortDynamicUrl = await parameters.buildShortLink();
    return shortDynamicUrl.shortUrl.toString();
  }
}
