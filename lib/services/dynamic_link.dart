import 'package:Vertretung/data/my_keys.dart';
import 'package:Vertretung/friends/add_friend_per_dynamic_link.dart';
import 'package:Vertretung/services/auth_service.dart';
import 'package:Vertretung/services/cloud_database.dart';
import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'package:flutter/material.dart';

class DynamicLink {
  Future handleDynamicLink() async {
    //if app is started from that link
    final PendingDynamicLinkData data =
        await FirebaseDynamicLinks.instance.getInitialLink();
    if (data != null) _handleDeepLink(data, true);

    //if app gets to foreground because auf that link
    FirebaseDynamicLinks.instance.onLink.listen(
      (PendingDynamicLinkData dynamicLinkData) async {
        _handleDeepLink(dynamicLinkData, false);
      },
      onError: (e) {
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
        fallbackUrl: Uri.parse("https://info-vertretung-whg.web.app"),
      ),
    );
    final ShortDynamicLink shortDynamicUrl =
        await FirebaseDynamicLinks.instance.buildShortLink(parameters);
    return shortDynamicUrl.shortUrl.toString();
  }
}
