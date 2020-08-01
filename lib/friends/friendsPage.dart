import 'package:Vertretung/friends/friendLogic.dart';
import 'package:Vertretung/logic/myKeys.dart';
import 'package:Vertretung/logic/names.dart';
import 'package:Vertretung/services/authService.dart';
import 'package:Vertretung/services/cloudDatabase.dart';
import 'package:Vertretung/services/dynamicLink.dart';
import 'package:Vertretung/otherWidgets/substituteList.dart';
import 'package:flutter/material.dart';
import 'package:progress_dialog/progress_dialog.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:share/share.dart';
import 'package:Vertretung/friends/friendModel.dart';

class FriendsPage extends StatefulWidget {
  const FriendsPage({Key key}) : super(key: key);

  @override
  String toStringShort() {
    return "FriendsPage";
  }

  @override
  FriendsPageState createState() => FriendsPageState();
}

class FriendsPageState extends State<FriendsPage> {
  RefreshController _refreshController =
      RefreshController(initialRefresh: true);
  List<Map<String, String>> friendsSubstitute = [];
  List<FriendModel> selectedFriends = [];
  List<FriendModel> friendList = [];
  FriendLogic friendLogic = FriendLogic();

  Future<void> reloadAll() async {
    List<FriendModel> newFriendList = await CloudDatabase().getFriendsList();
    if (newFriendList.length != friendList.length) {
      selectedFriends = [];
      friendList = newFriendList;
      for (var friend in friendList) {
        friend.isChecked = true;
        selectedFriends.add(friend);
      }
    }
    await friendLogic.updateFriendsList(selectedFriends);
    await reloadFriendsSubstitute();
    _refreshController.refreshCompleted();
  }

  Future<void> reloadFriendsSubstitute() async {
    List<dynamic> newFriendsSubstitute =
        await friendLogic.getFriendsSubstitute();
    setState(() {
      friendsSubstitute = newFriendsSubstitute;
    });
  }

  void onCheckboxClicked(bool isChecked, index, Function setState) {
    setState(() {
      friendList[index].isChecked = isChecked;
    });
    if (isChecked)
      selectedFriends.add(friendList[index]);
    else
      selectedFriends.remove(friendList[index]);
  }

  @override
  Widget build(BuildContext context) {
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
                ProgressDialog pr = ProgressDialog(context,
                    type: ProgressDialogType.Normal,
                    isDismissible: false,
                    showLogs: false);
                await pr.show();
                String uid = await AuthService().getUserId();
                String link = await DynamicLink().createLink();
                await pr.hide();
                Share.share("Mein Freundestoken: " +
                    uid.substring(0, 5) +
                    " oder einfach über diesen Link: $link"); //If change the message also update the length above in addFriendAlert
              }),
          Builder(builder: (context) {
            return IconButton(
              icon: Icon(Icons.add),
              onPressed: () => FriendLogic().addFriendAlert(context),
            );
          }),
          IconButton(
            icon: Icon(Icons.inbox),
            onPressed: () async {
              await Navigator.pushNamed(context, Names.friendRequests);
              _refreshController.requestRefresh();
            },
          ),
          IconButton(
            icon: Icon(Icons.list),
            onPressed: () async {
              await Navigator.pushNamed(context, Names.friendsList);
              _refreshController.requestRefresh();
            },
          ),
        ],
      ),
      body: SmartRefresher(
        controller: _refreshController,
        onRefresh: reloadAll,
        child: AnimatedSwitcher(
          key: ValueKey(friendsSubstitute),
          duration: Duration(seconds: 1),
          child: SubstituteList(
            key: MyKeys.friendsTab,
            list: friendsSubstitute,
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        heroTag: "add",
        onPressed: () async {
          List<dynamic> beforeChangesSelectedFriends =
              List.from(selectedFriends);
          await showDialog(
            context: context,
            builder: (context) {
              //to change the state
              return StatefulBuilder(
                builder: (context, setState) => AlertDialog(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(Radius.circular(15))),
                  title: Text("Wähle deine Freunde"),
                  content: ListView.builder(
                    shrinkWrap: true,
                    itemBuilder: (context, index) {
                      return CheckboxListTile(
                        title: Text(friendList[index].name),
                        value: friendList[index].isChecked,
                        controlAffinity: ListTileControlAffinity.leading,
                        onChanged: (isChecked) =>
                            onCheckboxClicked(isChecked, index, setState),
                      );
                    },
                    itemCount: friendList.length,
                  ),
                  actions: <Widget>[
                    FlatButton(
                      child: Text("Alle auswählen"),
                      onPressed: () {
                        selectedFriends = [];
                        for (var friend in friendList) {
                          setState(() {
                            friend.isChecked = true;
                          });
                          selectedFriends.add(friend);
                        }
                      },
                    ),
                    FlatButton(
                      child: Text("Alle abwählen"),
                      onPressed: () {
                        selectedFriends = [];
                        for (var friend in friendList) {
                          setState(() {
                            friend.isChecked = false;
                          });
                        }
                      },
                    ),
                  ],
                ),
              );
            },
          );
          if (beforeChangesSelectedFriends.length != selectedFriends.length)
            _refreshController.requestRefresh();
        },
        child: Icon(Icons.filter_list),
        backgroundColor:
            selectedFriends.length != friendList.length ? Colors.red : null,
      ),
    );
  }
}
