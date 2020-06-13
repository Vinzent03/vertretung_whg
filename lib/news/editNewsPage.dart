import 'package:Vertretung/news/newsPage.dart';
import 'package:Vertretung/services/cloudFunctions.dart';
import 'package:connectivity/connectivity.dart';
import 'package:progress_dialog/progress_dialog.dart';
import 'package:flutter/material.dart';

class EditNewsPage extends StatefulWidget {
  @override
  EditNewsPageState createState() => EditNewsPageState();
}

class EditNewsPageState extends State<EditNewsPage> {
  TextEditingController titleController = TextEditingController();
  TextEditingController textController = TextEditingController();
  NewsTransmitter transmitter;
  @override
  Widget build(BuildContext context) {
    transmitter = ModalRoute.of(context).settings.arguments;
    if (transmitter.isEditAction) {
      titleController.text = transmitter.title;
      textController.text = transmitter.text;
    }
    return Scaffold(
      appBar: AppBar(
        title: Text("Füge eine Nachricht hinzu"),
      ),
      body: Builder(builder: (context) {
        return SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Padding(
                child: Text("Titel"),
                padding: EdgeInsets.all(10),
              ),
              Card(
                child: TextField(
                  controller: titleController,
                ),
              ),
              Padding(
                child: Text("Text"),
                padding: EdgeInsets.all(10),
              ),
              Card(
                child: Container(
                  height: 300,
                  child: TextField(
                    controller: textController,
                    expands: true,
                    maxLines: null,
                  ),
                ),
              ),
              Center(
                child: RaisedButton(
                  onPressed: () async {
                    if (titleController.text == "")
                      return Scaffold.of(context).showSnackBar(SnackBar(
                        content: Text("Bitte gib einen Titel an"),
                      ));

                    if ((await Connectivity().checkConnectivity()) ==
                        ConnectivityResult.none) {
                      return Scaffold.of(context).showSnackBar(SnackBar(
                        content: Text("Keine Verbindung"),
                      ));
                    }
                    ProgressDialog pr = ProgressDialog(context,
                        type: ProgressDialogType.Normal,
                        isDismissible: false,
                        showLogs: false);
                    pr.show();

                    var result;
                    if (transmitter.isEditAction) {
                      result = await Functions().editNews(transmitter.index, {
                        "title": titleController.text,
                        "text": textController.text
                      });
                    } else {
                      result = await Functions().addNews({
                        "title": titleController.text,
                        "text": textController.text
                      });
                    }

                    pr.hide();

                    switch (result["code"]) {
                      case "Successful":
                        Navigator.pop(context);
                        break;
                      case "ERROR_NO_ADMIN":
                        Scaffold.of(context).showSnackBar(SnackBar(
                          content: Text(
                              "Du bist kein Admin, bitte melde dich ab und dann wieder an. Wenn du denktst du solltest Admin sein, melde dich bitte bei mir."),
                          duration: Duration(minutes: 1),
                        ));
                        break;
                    }
                  },
                  child: Text("Abschicken"),
                ),
              ),
            ],
          ),
        );
      }),
    );
  }
}
