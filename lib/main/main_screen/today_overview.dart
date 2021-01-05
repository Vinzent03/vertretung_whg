import 'dart:math';

import 'package:Vertretung/models/substitute_tile_model.dart';
import 'package:Vertretung/provider/user_data.dart';
import 'package:Vertretung/substitute/no_substitute.dart';
import 'package:Vertretung/substitute/substitute_tile.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class TodayOverview extends StatefulWidget {
  final bool today;
  final bool loaded;
  TodayOverview({
    Key key,
    @required this.today,
    @required this.loaded,
  }) : super(key: key);

  @override
  _TodayOverviewState createState() => _TodayOverviewState();
}

class _TodayOverviewState extends State<TodayOverview> {
  final GlobalKey<AnimatedListState> _listKey = GlobalKey<AnimatedListState>();
  List<SubstituteModel> list = [];
  bool expanded = false;
  @override
  void didChangeDependencies() {
    UserData provider = Provider.of<UserData>(context);
    List<SubstituteModel> tempList = List.from(list);
    if (widget.today) {
      list = provider.substituteToday;
    } else {
      list = provider.substituteTomorrow;
    }
    if (_listKey.currentState == null) return;

    if (expanded) {
      handleListUpdate(tempList);
    } else {
      handleListUpdate(tempList, 2);
    }
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        if (list.length <= 2) return;
        if (expanded) {
          shrink();
        } else {
          expand();
        }
        setState(() {
          expanded = !expanded;
        });
      },
      child: widget.loaded
          ? list.isNotEmpty
              ? Container(
                  decoration: BoxDecoration(
                      border: Border.all(color: Colors.black45),
                      borderRadius: BorderRadius.all(Radius.circular(15))),
                  padding: EdgeInsets.all(8),
                  alignment: Alignment.center,
                  child: Column(
                    children: [
                      AnimatedList(
                        physics: NeverScrollableScrollPhysics(),
                        key: _listKey,
                        initialItemCount: min(2, list.length),
                        shrinkWrap: true,
                        itemBuilder: (BuildContext context, int index,
                            Animation<double> animation) {
                          return SizeTransition(
                            axisAlignment: -1,
                            axis: Axis.vertical,
                            sizeFactor: animation,
                            child: SubstituteListTile(list[index]),
                          );
                        },
                      ),
                      AnimatedSwitcher(
                        duration: Duration(milliseconds: 300),
                        transitionBuilder: (child, animation) => SizeTransition(
                          sizeFactor: animation,
                          child: child,
                        ),
                        child: (!expanded && list.length > 2)
                            ? Column(
                                children: [
                                  Divider(
                                    height: 8,
                                    endIndent: 110,
                                    indent: 110,
                                    thickness: 3,
                                  ),
                                  Divider(
                                    height: 8,
                                    endIndent: 130,
                                    indent: 130,
                                    thickness: 3,
                                  ),
                                  Divider(
                                    height: 8,
                                    endIndent: 150,
                                    indent: 150,
                                    thickness: 3,
                                  ),
                                ],
                              )
                            : SizedBox(),
                      ),
                    ],
                  ),
                )
              : NoSubstitute()
          : Center(
              child: Container(
                decoration: BoxDecoration(
                    border: Border.all(color: Colors.black45),
                    borderRadius: BorderRadius.all(Radius.circular(15))),
                padding: const EdgeInsets.all(8),
                alignment: Alignment.center,
                child: CircularProgressIndicator(),
              ),
            ),
    );
  }

  void expand() {
    if (list.length > 2) {
      for (var i = 2; i < list.length; i++) {
        insertItem(i);
      }
    }
  }

  void shrink() {
    if (list.length > 2) {
      for (var i = list.length - 1; i >= 2; i--) {
        removeItem(i, list[i]);
      }
    }
  }

  /// Default targetedLength is infinity (show whole list)
  void handleListUpdate(List<SubstituteModel> tempList,
      [double targetedLength = double.infinity]) {
    //expand
    if (list.length > tempList.length) {
      for (var i = tempList.length; i < min(targetedLength, list.length); i++) {
        insertItem(i);
      }
    }
    //shrink
    else if (list.length < tempList.length) {
      for (var i = min(targetedLength - 1, tempList.length - 1);
          i >= list.length;
          i--) {
        removeItem(i, tempList[i]);
      }
    }
  }

  void insertItem(int index) => _listKey.currentState.insertItem(index);
  void removeItem(int index, SubstituteModel item) {
    _listKey.currentState.removeItem(
      index,
      (context, animation) => SizeTransition(
        axisAlignment: 1,
        sizeFactor: animation,
        child: SubstituteListTile(item),
      ),
    );
  }
}
