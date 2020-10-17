import 'package:Vertretung/models/newsModel.dart';
import 'package:Vertretung/news/detailsPage.dart';
import "newsTransmitter.dart";
import 'package:Vertretung/services/cloudFunctions.dart';
import 'package:flutter/material.dart';
import 'package:progress_dialog/progress_dialog.dart';

import 'editNewsPage.dart';

class NewsLogic {
  Future<bool> deleteNews(BuildContext context, index) async {
    ProgressDialog pr = ProgressDialog(context,
        type: ProgressDialogType.Normal, isDismissible: false, showLogs: false);
    await pr.show();

    var result = await Functions().deleteNews(index);
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
