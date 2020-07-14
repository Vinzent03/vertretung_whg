import 'package:Vertretung/news/detailsPage.dart';
import "newsTransmitter.dart";
import 'package:Vertretung/services/cloudFunctions.dart';
import 'package:connectivity/connectivity.dart';
import 'package:flutter/material.dart';
import 'package:progress_dialog/progress_dialog.dart';

import 'editNewsPage.dart';

class NewsLogic {
  Future<bool> deleteNews(BuildContext context, index) async {
    if ((await Connectivity().checkConnectivity()) == ConnectivityResult.none) {
      Scaffold.of(context).showSnackBar(SnackBar(
        content: Text("Keine Verbindung"),
      ));
      return false;
    }

    var result;

    ProgressDialog pr = ProgressDialog(context,
        type: ProgressDialogType.Normal, isDismissible: false, showLogs: false);
    await pr.show();

    result = await Functions().deleteNews(index);
    await pr.hide();
    Scaffold.of(context).hideCurrentSnackBar();

    switch (result["code"]) {
      case "SUCCESS":
        return true;
      case "ERROR_NOT_ADMIN":
        Scaffold.of(context).showSnackBar(
          SnackBar(
            content: Text(result["message"]),
            duration: Duration(minutes: 1),
          ),
        );
        return false;
      case "DEADLINE_EXCEEDED":
        Scaffold.of(context).showSnackBar(
          SnackBar(
            content:
                Text("Das hat zu lange gedauert. Versuche es später erneut."),
            duration: Duration(seconds: 5),
          ),
        );
        return false;
      default:
        Scaffold.of(context).showSnackBar(
          SnackBar(
            content: Text("Ein unerwarteter Fehler ist aufgetreten: \"" +
                result["code"] +
                "\""),
            duration: Duration(minutes: 1),
          ),
        );
        return false;
    }
  }

  Future<dynamic> openEditNewsPage(
      BuildContext context, String text, String title, int index) async {
    return await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditNewsPage(
          NewsTransmitter(
            true,
            text: text,
            title: title,
            index: index,
          ),
        ),
      ),
    );
  }

  Future<dynamic> openDetailsPage(
      BuildContext context, String text, String title, int index) async {
    return await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => DetailsPage(
          text: text,
          title: title,
          index: index,
        ),
      ),
    );
  }
}
