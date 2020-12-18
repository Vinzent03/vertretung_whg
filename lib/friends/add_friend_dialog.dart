import 'package:Vertretung/services/auth_service.dart';
import 'package:Vertretung/services/cloud_functions.dart';
import 'package:flushbar/flushbar.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:progress_dialog/progress_dialog.dart';

class AddFriendDialog extends StatefulWidget {
  @override
  _AddFriendDialogState createState() => _AddFriendDialogState();
}

class _AddFriendDialogState extends State<AddFriendDialog> {
  final TextEditingController controller = TextEditingController();

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  bool _autoValidate = false;
  String message;
  String uid;
  bool error = false;
  bool addFriendToYourself = true;
  ProgressDialog pr;
  @override
  void didChangeDependencies() {
    pr = ProgressDialog(context, isDismissible: false, showLogs: false);
    super.didChangeDependencies();
  }

  @override
  void initState() {
    super.initState();
    if (!kIsWeb)
      Clipboard.getData("text/plain").then((value) => {
            if (value != null)
              {
                if (value.text.length ==
                    25) //If the user has the complete share sentence
                  controller.text = value.text.substring(20)
                else if (value.text.length == 5)
                  controller.text = value.text //if the user has just the code
              }
          });
    uid = AuthService().getUserId().substring(0, 5);
  }

  String isValid(st) {
    if (error) return message;
    if (st == uid) {
      return "Du kannst dich nicht selbst hinzufügen";
    }
    if (st.length != 5) {
      return "Der Token muss 5 Zeichen lang sein";
    }

    return null;
  }

  bool _validateInputs() {
    if (_formKey.currentState.validate()) {
      return true;
    } else {
      _autoValidate = true;
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(15))),
      title: Text("Gib den Token deines Freundes ein."),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Form(
            key: _formKey,
            child: TextFormField(
              controller: controller,
              autovalidate: _autoValidate,
              validator: isValid,
            ),
          ),
          CheckboxListTile(
            title: Text("Auch bei mir hinzufügen"),
            onChanged: (value) {
              setState(() {
                addFriendToYourself = value;
              });
            },
            value: addFriendToYourself,
          )
        ],
      ),
      actions: <Widget>[
        FlatButton(
          child: Text("abbrechen"),
          onPressed: () => Navigator.pop(context),
        ),
        RaisedButton(
          child: Text("Bestätigen"),
          // ignore: missing_return
          onPressed: () async {
            error = false;
            if (_validateInputs()) {
              await pr.show();
              var result = await Functions()
                  .addFriend(controller.text, addFriendToYourself);
              await pr.hide();
              switch (result["code"]) {
                case "SUCCESS":
                  Navigator.pop(context);
                  Flushbar(
                    message: "Als Freund hinzugefügt.",
                    duration: Duration(seconds: 2),
                  )..show(context);
                  break;
                case "EXCEPTION_ALREADY_FRIEND":
                  message = result["message"];
                  error = true;
                  _validateInputs();
                  break;
                case "EXCEPTION_CANT_FIND_FRIEND":
                  message = result["message"];
                  error = true;
                  _validateInputs();
                  break;
                case "DEADLINE_EXCEEDED":
                  Navigator.pop(context);
                  Flushbar(
                    message:
                        "Das hat zu lange gedauert. Versuche es später erneut.",
                    duration: Duration(seconds: 2),
                  )..show(context);
                  break;
                default:
                  Navigator.pop(context);
                  Flushbar(
                    message: "Ein unerwarteter Fehler ist aufgetreten: \"" +
                        result["code"] +
                        "\"",
                    duration: Duration(seconds: 30),
                  )..show(context);
              }
            }
          },
        ),
      ],
    );
  }
}
