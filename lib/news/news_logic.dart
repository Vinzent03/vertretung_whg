import 'package:Vertretung/models/news_model.dart';
import 'package:Vertretung/news/details_page.dart';
import 'package:Vertretung/otherWidgets/loading_dialog.dart';
import 'package:Vertretung/services/cloud_functions.dart';
import 'package:flutter/material.dart';

import 'edit_news_page.dart';
import 'news_transmitter.dart';

class NewsLogic {
  Future<bool> deleteNews(BuildContext context, String id) async {
    LoadingDialog ld = LoadingDialog(context);
    ld.show();

    var result = await Functions().deleteNews(id);
    ld.hide();

    switch (result["code"]) {
      case "SUCCESS":
        return true;
      case "ERROR_NOT_ADMIN":
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(result["message"]),
          backgroundColor: Colors.red,
        ));
        return false;
      case "DEADLINE_EXCEEDED":
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content:
              Text("Das hat zu lange gedauert. Versuche es später erneut."),
        ));
        return false;
      default:
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(
              "Ein unerwarteter Fehler ist aufgetreten: \"${result["code"]}\""),
          duration: Duration(seconds: 20),
          backgroundColor: Colors.red,
        ));
        return false;
    }
  }

  Future<dynamic> openEditNewsPage(BuildContext context, NewsModel news) async {
    return await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditNewsPage(
          NewsTransmitter(
            true,
            news,
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
