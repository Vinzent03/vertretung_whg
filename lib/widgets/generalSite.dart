import 'package:flutter/material.dart';

import 'generalBlueprint.dart';

class GeneralSite extends StatelessWidget {
  bool faecherOn;
  bool twoPages;
  int currentIndex;
  bool shouldShowBanner;
  String change;
  PageController controller;
  List<List<String>> myListToday;
  List<List<String>> listToday;
  List<List<String>> myListTomorrow;
  List<List<String>> listTomorrow;

  GeneralSite(
      {this.faecherOn,
      this.twoPages,
      this.currentIndex,
      this.shouldShowBanner,
      this.change,
      this.controller,
      this.myListToday,
      this.listToday,
      this.myListTomorrow,
      this.listTomorrow});

  @override
  Widget build(BuildContext context) {
    return faecherOn
        ? twoPages
            //// mit faecher und zwei seiten
            ? PageView(
                physics: ScrollPhysics(),
                scrollDirection: Axis.horizontal,
                controller: controller,
                children: <Widget>[
                  currentIndex == 0
                      ? GeneralBlueprint(
                          today: true,
                          list: myListToday,
                          change: change,
                          isMy: true,
                        )
                      : GeneralBlueprint(
                          today: false,
                          list: myListTomorrow,
                          change: change,
                          isMy: true,
                        ),
                  currentIndex == 0
                      ? GeneralBlueprint(
                          today: true,
                          list: listToday,
                          change: change,
                          isMy: false,
                        )
                      : GeneralBlueprint(
                          today: false,
                          list: listTomorrow,
                          change: change,
                          isMy: false,
                        ),
                ],
              )
            // mit fächer aber mit nut  einer Seite
            : ListView(
                children: <Widget>[
                  currentIndex == 0
                      ? GeneralBlueprint(
                          today: true,
                          list: myListToday,
                          change: change,
                          isMy: true,
                        )
                      : GeneralBlueprint(
                          today: false,
                          list: myListTomorrow,
                          change: change,
                          isMy: true,
                        ),
                  Divider(
                    thickness: 8,
                    indent: 5,
                    endIndent: 5,
                  ),
                  currentIndex == 0
                      ? GeneralBlueprint(
                          today: true,
                          list: listToday,
                          change: change,
                          isMy: false,
                        )
                      : GeneralBlueprint(
                          today: false,
                          list: listTomorrow,
                          change: change,
                          isMy: false,
                        ),
                ],
              )
        // ohne fächer
        : currentIndex == 0
            ? GeneralBlueprint(
                today: true,
                list: listToday,
                change: change,
                isMy: false,
              )
            : GeneralBlueprint(
                today: false,
                list: listTomorrow,
                change: change,
                isMy: false,
              );
  }
}
