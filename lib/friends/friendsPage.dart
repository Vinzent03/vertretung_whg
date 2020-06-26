import 'package:Vertretung/friends/friendLogic.dart';
import 'package:Vertretung/logic/names.dart';
import 'package:Vertretung/provider/providerData.dart';
import 'package:Vertretung/services/authService.dart';
import 'package:Vertretung/services/cloudDatabase.dart';
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
  RefreshController _refreshController =
      RefreshController(initialRefresh: true);
  List<Map<String, String>> friendVertretung = [];
  List<FriendFilterModel> friendFilterList = [];
  List<dynamic> selectedFriends = [];
  List<dynamic> friendList = [];

  Future<void> reload() async {
    friendList = await CloudDatabase().getFriendsList();
    if (friendFilterList.isEmpty ||
        friendList.length != friendFilterList.length) {
      friendFilterList = [];
      for (var friend in friendList) {
        friendFilterList.add(FriendFilterModel(true, friend));
        selectedFriends.add(friend);
      }
    }

    await FriendLogic()
        .getFriendVertretung(selectedFriends)
        .then((newFriendVertretung) {
      setState(() {
        friendVertretung = newFriendVertretung;
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
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(15))),
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
                      var result =
                          await Functions().addFriendRequest(controller.text);
                      switch (result["code"]) {
                        case "SUCCESS":
                          Navigator.pop(context);
                          Scaffold.of(scaffoldContext).showSnackBar(SnackBar(
                            content: Text("Freundesanfrage geschickt"),
                          ));
                          break;
                        case "EXCEPTION_ALREADY_REQUESTED":
                          setState(() {
                            message = result["message"];
                            error = true;
                            _validateInputs();
                          });
                          break;
                        case "EXCEPTION_ALREADY_FRIEND":
                          setState(() {
                            message = result["message"];
                            error = true;
                            _validateInputs();
                          });
                          break;
                        case "EXCEPTION_CANT_FIND_FRIEND":
                          setState(() {
                            message = result["message"];
                            error = true;
                            _validateInputs();
                          });
                          break;
                        case "DEADLINE_EXCEEDED":
                          Navigator.pop(context);
                          Scaffold.of(scaffoldContext).showSnackBar(
                            SnackBar(
                              content: Text(
                                  "Das hat zu lange gedauert. Versuche es später erneut."),
                              duration: Duration(seconds: 5),
                            ),
                          );
                          break;
                        default:
                          Navigator.pop(context);
                          Scaffold.of(scaffoldContext).showSnackBar(
                            SnackBar(
                              content: Text(
                                  "Ein unerwarteter Fehler ist aufgetreten: \"" +
                                      result["code"] +
                                      "\""),
                              duration: Duration(minutes: 1),
                            ),
                          );
                      }
                    }
                  }),
            ],
          );
        });
  }

  void onChanged(bool isChecked, index, Function setState) {
    setState(() {
      friendFilterList[index].isChecked = isChecked;
    });
    if (isChecked)
      selectedFriends.add(friendFilterList[index].user);
    else
      selectedFriends.remove(friendFilterList[index].user);

    setState(() {
      friendFilterList[index].isChecked = isChecked;
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
        child: AnimatedSwitcher(
          key: ValueKey(friendVertretung),
          duration: Duration(seconds: 1),
          child: GeneralBlueprint(
            list: friendVertretung,
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        heroTag: "add",
        onPressed: () async {
          await showDialog(
            context: context,
            builder: (context) {
              //to chagne the state
              return StatefulBuilder(
                builder: (context, setState) => AlertDialog(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(Radius.circular(15))),
                  title: Text("Wähle deine Freunde"),
                  content: ListView.builder(
                    shrinkWrap: true,
                    itemBuilder: (context, index) {
                      return CheckboxListTile(
                        title: Text(friendFilterList[index].user["name"]),
                        value: friendFilterList[index].isChecked,
                        controlAffinity: ListTileControlAffinity.leading,
                        onChanged: (isChecked) =>
                            onChanged(isChecked, index, setState),
                      );
                    },
                    itemCount: friendFilterList.length,
                  ),
                  actions: <Widget>[
                    FlatButton(
                      child: Text("Alle auswählen"),
                      onPressed: () {
                        selectedFriends = [];
                        for (var user in friendFilterList) {
                          setState(() {
                            user.isChecked = true;
                          });
                          selectedFriends.add(user.user);
                        }
                      },
                    ),
                    FlatButton(
                      child: Text("Alle abwählen"),
                      onPressed: () {
                        selectedFriends = [];
                        for (var user in friendFilterList) {
                          setState(() {
                            user.isChecked = false;
                          });
                        }
                      },
                    ),
                  ],
                ),
              );
            },
          );
          _refreshController.requestRefresh();
        },
        child: Icon(Icons.filter_list),
        backgroundColor:
            selectedFriends.length != friendList.length ? Colors.red : null,
      ),
    );
  }
}

class FriendFilterModel {
  bool isChecked;
  final user;
  FriendFilterModel(this.isChecked, this.user);
}
