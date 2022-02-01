import 'package:Vertretung/otherWidgets/loading_dialog.dart';
import 'package:Vertretung/services/auth_service.dart';
import 'package:Vertretung/services/cloud_functions.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

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
  LoadingDialog ld;
  @override
  void didChangeDependencies() {
    ld = LoadingDialog(context);
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
              autovalidateMode: _autoValidate
                  ? AutovalidateMode.always
                  : AutovalidateMode.disabled,
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
        TextButton(
          child: Text("Abbrechen"),
          onPressed: () => Navigator.pop(context),
        ),
        ElevatedButton(
          child: Text("Bestätigen"),
          // ignore: missing_return
          onPressed: () async {
            error = false;
            if (_validateInputs()) {
              ld.show();
              var result = await Functions()
                  .addFriend(controller.text, addFriendToYourself);
              ld.hide();
              switch (result["code"]) {
                case "SUCCESS":
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    content: Text("Als Freund hinzugefügt."),
                  ));
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
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    content: Text(
                        "Das hat zu lange gedauert. Versuche es später erneut."),
                  ));
                  break;
                default:
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    content: Text(
                        "Ein unerwarteter Fehler ist aufgetreten: \"${result["code"]}\""),
                    duration: Duration(seconds: 20),
                    backgroundColor: Colors.red,
                  ));
              }
            }
          },
        ),
      ],
    );
  }
}
