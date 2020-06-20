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
    pr.hide();

    switch (result["code"]) {
      case "Successful":
        return true;
        break;
      case "ERROR_NO_ADMIN":
        Scaffold.of(context).showSnackBar(
          SnackBar(
            content: Text(
                "Du bist kein Admin, bitte melde dich ab und dann wieder an. Wenn du denktst du solltest Admin sein, melde dich bitte bei mir."),
            duration: Duration(minutes: 1),
          ),
        );
        return true;
        break;
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
