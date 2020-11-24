import 'package:Vertretung/substitute/substituteFromStream.dart';
import 'package:Vertretung/substitute/substitutePullToRefresh.dart';
import 'package:flutter/material.dart';

class MyKeys {
  //SubstituteListState Keys
  static final GlobalKey<SubstituteFromStreamState> friendsTab =
      GlobalKey<SubstituteFromStreamState>();
  static final GlobalKey<SubstitutePullToRefreshState> firstTab =
      GlobalKey<SubstitutePullToRefreshState>();
  static final GlobalKey<SubstitutePullToRefreshState> secondTab =
      GlobalKey<SubstitutePullToRefreshState>();
  static final GlobalKey<SubstitutePullToRefreshState> thirdTab =
      GlobalKey<SubstitutePullToRefreshState>();
  static final GlobalKey<SubstitutePullToRefreshState> fourthTab =
      GlobalKey<SubstitutePullToRefreshState>();

  static final GlobalKey<NavigatorState> navigatorKey =
      GlobalKey<NavigatorState>();
}
