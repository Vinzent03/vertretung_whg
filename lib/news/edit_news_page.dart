import 'package:Vertretung/data/school_classes.dart';
import 'package:Vertretung/models/school_class_model.dart';
import 'package:Vertretung/news/news_school_classes_selection.dart';
import 'package:Vertretung/news/news_transmitter.dart';
import 'package:Vertretung/otherWidgets/loading_dialog.dart';
import 'package:Vertretung/services/cloud_functions.dart';
import 'package:flutter/material.dart';

///Used to edit and add news
class EditNewsPage extends StatefulWidget {
  final NewsTransmitter transmitter;
  EditNewsPage(this.transmitter);
  @override
  EditNewsPageState createState() => EditNewsPageState();
}

class EditNewsPageState extends State<EditNewsPage> {
  TextEditingController titleController = TextEditingController();
  TextEditingController textController = TextEditingController();
  NewsTransmitter transmitter;
  List<SchoolClassModel> schoolClasses = SchoolClasses().schoolClasses;
  bool sendNotification = false;

  @override
  void didChangeDependencies() {
    transmitter = widget.transmitter;

    //decide between edit a news or add a new news
    if (transmitter.isEditAction) {
      titleController.text = transmitter.news.title;
      textController.text = transmitter.news.text;
    }
    super.didChangeDependencies();
  }

  List<String> getSelectedSchoolClasses() {
    List<String> selectedSchoolClasses = [];
    schoolClasses.forEach((element) {
      selectedSchoolClasses.addAll(element.children
          .where((element) => element.isChecked)
          .map((e) => e.title));
    });
    return selectedSchoolClasses;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(transmitter.isEditAction
            ? "Bearbeite die Nachricht"
            : "Füge eine Nachricht hinzu"),
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
                margin: EdgeInsets.all(10),
                elevation: 3,
                child: TextField(
                  controller: titleController,
                ),
              ),
              Padding(
                child: Text("Text"),
                padding: EdgeInsets.all(10),
              ),
              Card(
                margin: EdgeInsets.all(10),
                elevation: 3,
                child: Container(
                  height: 300,
                  child: TextField(
                    controller: textController,
                    expands: true,
                    maxLines: null,
                  ),
                ),
              ),
              Padding(
                padding:
                    const EdgeInsets.symmetric(vertical: 5.0, horizontal: 10.0),
                child: Text("Markdown wird unterstützt"),
              ),
              CheckboxListTile(
                title: Text("Benachrichtigung senden"),
                onChanged: (bool b) {
                  if (sendNotification)
                    setState(() => sendNotification = b);
                  else
                    confirmNotification();
                },
                value: sendNotification,
              ),
              if (!widget.transmitter.isEditAction)
                ListTile(
                  title: Text("Klassen/Stufen auswählen"),
                  onTap: () async {
                    await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            NewsSchoolClassesSelection(schoolClasses),
                      ),
                    );
                    setState(() {});
                    // setState(() => schoolClasses = newSchoolClasses);
                  },
                ),
              Center(
                child: ElevatedButton(
                  onPressed: getSelectedSchoolClasses().isNotEmpty ||
                          widget.transmitter.isEditAction
                      ? () => confirm(context)
                      : null,
                  child: Text("Bestätigen"),
                ),
              ),
            ],
          ),
        );
      }),
    );
  }

  confirm(BuildContext context) async {
    if (titleController.text == "")
      return ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text("Bitte gib einen Titel an"),
      ));

    LoadingDialog ld = LoadingDialog(context);
    ld.show();

    var result;
    if (transmitter.isEditAction) {
      result = await Functions().editNews(
        titleController.text,
        textController.text,
        transmitter.news.id,
        sendNotification,
      );
    } else {
      result = await Functions().addNews(
        titleController.text,
        textController.text,
        getSelectedSchoolClasses(),
        sendNotification,
      );
    }

    ld.hide();
    ScaffoldMessenger.of(context).hideCurrentSnackBar();

    switch (result["code"]) {
      case "SUCCESS":
        Navigator.pop(context);
        break;
      case "ERROR_NOT_ADMIN":
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result["message"]),
            duration: Duration(minutes: 1),
          ),
        );
        break;
      case "DEADLINE_EXCEEDED":
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content:
                Text("Das hat zu lange gedauert. Versuche es später erneut."),
            duration: Duration(seconds: 5),
          ),
        );
        break;
      default:
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Ein unerwarteter Fehler ist aufgetreten: \"" +
                result["code"] +
                "\""),
            duration: Duration(minutes: 1),
          ),
        );
    }
  }

  confirmNotification() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Möchtest du wirklich eine Benachrichtigung senden?"),
        actions: [
          TextButton(
            child: Text("Abbrechen"),
            onPressed: () => Navigator.pop(context),
          ),
          ElevatedButton(
            child: Text("Bestätigen"),
            onPressed: () {
              setState(() => sendNotification = true);
              Navigator.pop(context);
            },
          )
        ],
      ),
    );
  }
}
