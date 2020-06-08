import 'package:Vertretung/friends/friendLogic.dart';
import 'package:Vertretung/logic/names.dart';
import 'package:Vertretung/provider/providerData.dart';
import 'package:Vertretung/services/authService.dart';
import 'package:connectivity/connectivity.dart';
import 'package:Vertretung/services/cloudFunctions.dart';
import 'package:Vertretung/otherWidgets/generalBlueprint.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:provider/provider.dart';
import 'package:share/share.dart';

class Friends extends StatefulWidget {
  @override
  _FriendsState createState() => _FriendsState();
}

class _FriendsState extends State<Friends> {
  List<Map<String, String>> friendsList = [];
  RefreshController _refreshController =
      RefreshController(initialRefresh: true);

  @override
  void initState() {
    //reload();
    super.initState();
  }

  Future<void> reload() async {
    await FriendLogic().getLists().then((newFriendsList) {
      setState(() {
        friendsList = newFriendsList;
      });
    });
    _refreshController.refreshCompleted();
  }

  addFriendAlert(scaffoldContext) async {
    final TextEditingController controller = TextEditingController();
    ClipboardData clipboardData = await Clipboard.getData("text/plain");
    final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
    bool _autoValidate = false;
    String message;
    String uid;
    bool error = false;
    AuthService().getUserId().then((value) => uid = value.substring(0, 5));
    if (clipboardData != null) {
      if (clipboardData.text.length ==
          25) //If the user has the complet share sentence
        controller.text = clipboardData.text.substring(20);
      if (clipboardData.text.length == 5)
        controller.text = clipboardData.text; //if the user has just the code
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
        setState(() {
          _autoValidate = true;
        });
        return false;
      }
    }

    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text("Gib den Token deines Freundes ein"),
            content: Form(
              key: _formKey,
              child: TextFormField(
                controller: controller,
                autovalidate: _autoValidate,
                validator: isValid,
              ),
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
                      var connectivityResult =
                          await (Connectivity().checkConnectivity());
                      if (connectivityResult == ConnectivityResult.none) {
                        Navigator.pop(context);
                        return Scaffold.of(scaffoldContext)
                            .showSnackBar(SnackBar(
                          content: Text("Keine Verbindung"),
                          behavior: SnackBarBehavior.floating,
                        ));
                      }
                      var result = await Functions()
                          .callAddFriendRequest(controller.text);
                      switch (result["code"]) {
                        case "Successful":
                          Navigator.pop(context);
                          Scaffold.of(scaffoldContext).showSnackBar(SnackBar(
                            content: Text("Freundesanfrage geschickt"),
                            behavior: SnackBarBehavior.floating,
                          ));
                          break;
                        case "ERROR_ALREADY_REQUESTED":
                          setState(() {
                            message = result["message"];
                            error = true;
                            _validateInputs();
                          });
                          break;
                        case "ERROR_ALREADY_FRIEND":
                          setState(() {
                            message = result["message"];
                            error = true;
                            _validateInputs();
                          });
                          break;
                        case "ERROR_CANT_FIND_FRIEND":
                          setState(() {
                            message = result["message"];
                            error = true;
                            _validateInputs();
                          });
                          break;
                      }
                    }
                  }),
            ],
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    if (Provider.of<ProviderData>(context).getFriendReload()) {
      reload().then((value) => Provider.of<ProviderData>(context, listen: false)
          .setFriendReload(false));
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Freunde",
          textAlign: TextAlign.left,
        ),
        actions: <Widget>[
          IconButton(
              icon: Icon(Icons.share),
              onPressed: () async {
                String uid = await AuthService().getUserId();
                Share.share("Mein Freundestoken: " +
                    uid.substring(0,
                        5)); //If change the message also update the length above in addFriendAlert
              }),
          Builder(builder: (context) {
            return IconButton(
              icon: Icon(Icons.add),
              onPressed: () => addFriendAlert(context),
            );
          }),
          IconButton(
            icon: Icon(Icons.inbox),
            onPressed: () => Navigator.pushNamed(context, Names.friendRequests),
          ),
          IconButton(
            icon: Icon(Icons.list),
            onPressed: () => Navigator.pushNamed(context, Names.friendsList),
          ),
        ],
      ),
      body: SmartRefresher(
          controller: _refreshController,
          onRefresh: reload,
          child: GeneralBlueprint(
            list: friendsList,
          )),
    );
  }
}
