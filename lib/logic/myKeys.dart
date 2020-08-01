import 'package:Vertretung/otherWidgets/substituteList.dart';
import 'package:Vertretung/substitute/substitutePage.dart';
import 'package:flutter/material.dart';

class MyKeys {
  //SubstituteListState Keys
  static final GlobalKey<SubstituteListState> friendsTab =
      GlobalKey<SubstituteListState>();
  static final GlobalKey<SubstituteListState> firstTab =
      GlobalKey<SubstituteListState>();
  static final GlobalKey<SubstituteListState> secondTab =
      GlobalKey<SubstituteListState>();
  static final GlobalKey<SubstituteListState> thirdTab =
      GlobalKey<SubstituteListState>();
  static final GlobalKey<SubstituteListState> fourthTab =
      GlobalKey<SubstituteListState>();

  //SubstitutePage Key
  static final GlobalKey<SubstitutePageState> substitutePageKey =
      GlobalKey<SubstitutePageState>();

  static final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

}
