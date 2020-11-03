import 'package:Vertretung/models/newsModel.dart';
import 'package:Vertretung/news/detailsPage.dart';
import "newsTransmitter.dart";
import 'package:Vertretung/services/cloudFunctions.dart';
import 'package:flutter/material.dart';
import 'package:progress_dialog/progress_dialog.dart';
import 'package:flushbar/flushbar.dart';

import 'editNewsPage.dart';

class NewsLogic {
  Future<bool> deleteNews(BuildContext context, index) async {
    ProgressDialog pr = ProgressDialog(context,
        type: ProgressDialogType.Normal, isDismissible: false, showLogs: false);
    await pr.show();

    var result = await Functions().deleteNews(index);
    await pr.hide();

    switch (result["code"]) {
      case "SUCCESS":
        return true;
      case "ERROR_NOT_ADMIN":
        Flushbar(
          message: result["message"],
          duration: Duration(seconds: 2),
        )..show(context);
        return false;
      case "DEADLINE_EXCEEDED":
        Flushbar(
          message: "Das hat zu lange gedauert. Versuche es später erneut.",
          duration: Duration(seconds: 5),
        )..show(context);
        return false;
      default:
        Flushbar(
          message: "Ein unerwarteter Fehler ist aufgetreten: \"" +
              result["code"] +
              "\"",
          duration: Duration(seconds: 30),
        )..show(context);
        return false;
    }
  }

  Future<dynamic> openEditNewsPage(
      BuildContext context, NewsModel news, int index) async {
    return await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditNewsPage(
          NewsTransmitter(
            true,
            news,
            index,
          ),
        ),
      ),
    );
  }

  Future<dynamic> openDetailsPage(
      BuildContext context, NewsModel news, int index) async {
    return await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => DetailsPage(
          news: news,
          index: index,
        ),
      ),
    );
  }
}
