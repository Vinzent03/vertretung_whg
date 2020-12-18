import 'package:Vertretung/data/names.dart';
import 'package:Vertretung/logic/sharedPref.dart';
import 'package:flutter/material.dart';

class UserData extends ChangeNotifier {
  String _schoolClass;
  bool _personalSubstitute;
  bool _friendsFeature;
  List<String> _rawSubstituteToday;
  List<String> _rawSubstituteTomorrow;
  String _lastChange;
  List<String> _subjects;
  List<String> _subjectsNot;

  String get schoolClass => _schoolClass;

  set schoolClass(String st) {
    SharedPref().setString(Names.schoolClass, st);
    _schoolClass = st;
    notifyListeners();
  }

  bool get personalSubstitute => _personalSubstitute;

  set personalSubstitute(bool b) {
    SharedPref().setBool(Names.personalSubstitute, b);
    _personalSubstitute = b;
    notifyListeners();
  }

  bool get friendsFeature => _friendsFeature;

  set friendsFeature(bool b) {
    SharedPref().setBool(Names.friendsFeature, b);
    _friendsFeature = b;
    notifyListeners();
  }

  List<String> get rawSubstituteToday => _rawSubstituteToday;

  set rawSubstituteToday(List<String> list) {
    SharedPref().setStringList(Names.substituteToday, list);
    _rawSubstituteToday = list;
    notifyListeners();
  }

  List<String> get rawSubstituteTomorrow => _rawSubstituteTomorrow;

  set rawSubstituteTomorrow(List<String> list) {
    SharedPref().setStringList(Names.substituteTomorrow, list);
    _rawSubstituteTomorrow = list;
    notifyListeners();
  }

  String get lastChange => _lastChange;

  set lastChange(String st) {
    SharedPref().setString(Names.lastChange, st);
    _lastChange = st;
    notifyListeners();
  }

  List<String> get subjects => _subjects;

  set subjects(List<String> list) {
    SharedPref().setStringList(Names.subjects, list);
    _subjects = list;
    notifyListeners();
  }

  List<String> get subjectsNot => _subjectsNot;

  set subjectsNot(List<String> list) {
    SharedPref().setStringList(Names.subjectsNot, list);
    _subjectsNot = list;
    notifyListeners();
  }

  void reset() {
    _subjects = [];
    _subjectsNot = [];
    _schoolClass = "Nicht festgelegt";
    _friendsFeature = true;
    _personalSubstitute = false;
    notifyListeners();
  }
}
