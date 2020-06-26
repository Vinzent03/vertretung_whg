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
    pr.show();

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

  Future<void> openEditNewsPage(
      BuildContext context, String text, String title, int index) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditNewsPage(),
        settings: RouteSettings(
          arguments:
              NewsTransmitter(true, text: text, title: title, index: index),
        ),
      ),
    );
  }
}

///Informations about the selected news from the main page
class NewsTransmitter {
  final String text;
  final String title;
  final bool isEditAction;
  final int index;
  NewsTransmitter(this.isEditAction, {this.text, this.title, this.index});
}
