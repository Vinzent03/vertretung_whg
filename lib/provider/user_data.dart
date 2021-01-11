import 'package:Vertretung/data/names.dart';
import 'package:Vertretung/logic/filter.dart';
import 'package:Vertretung/logic/shared_pref.dart';
import 'package:Vertretung/models/substitute_tile_model.dart';
import 'package:flutter/material.dart';

class UserData extends ChangeNotifier {
  String _schoolClass;
  bool _personalSubstitute;
  bool _friendsFeature;
  List<String> _rawSubstituteToday;
  List<String> _rawSubstituteTomorrow;
  String _lastChange;
  List<String> _dayNames;
  List<String> _subjects;
  List<String> _subjectsNot;
  List<String> _freeLessons;

  String get schoolClass => _schoolClass;

  set schoolClass(String st) {
    SharedPref.setString(Names.schoolClass, st);
    _schoolClass = st;
    notifyListeners();
  }

  bool get personalSubstitute => _personalSubstitute;

  set personalSubstitute(bool b) {
    SharedPref.setBool(Names.personalSubstitute, b);
    _personalSubstitute = b;
    notifyListeners();
  }

  bool get friendsFeature => _friendsFeature;

  set friendsFeature(bool b) {
    SharedPref.setBool(Names.friendsFeature, b);
    _friendsFeature = b;
    notifyListeners();
  }

  List<String> get rawSubstituteToday => _rawSubstituteToday;

  set rawSubstituteToday(List<String> list) {
    SharedPref.setStringList(Names.substituteToday, list);
    _rawSubstituteToday = list;
    notifyListeners();
  }

  List<String> get rawSubstituteTomorrow => _rawSubstituteTomorrow;

  set rawSubstituteTomorrow(List<String> list) {
    SharedPref.setStringList(Names.substituteTomorrow, list);
    _rawSubstituteTomorrow = list;
    notifyListeners();
  }

  String get lastChange => _lastChange;

  set lastChange(String st) {
    SharedPref.setString(Names.lastChange, st);
    _lastChange = st;
    notifyListeners();
  }

  /// If the data of today is for the current day it returns 'Heute', if not it returns the name of the weekday.
  /// Set today false to check for tomorrow.
  List<String> get formattedDayNames {
    List<String> weekdays = [
      "Montag",
      "Dienstag",
      "Mittwoch",
      "Donnerstag",
      "Freitag",
      "Samstag",
      "Sonntag"
    ];

    String today = weekdays[DateTime.now().weekday - 1];
    String tomorrow =
        weekdays[DateTime.now().add(Duration(days: 1)).weekday - 1];
    List<String> resultList = ["Heute", "Morgen"];
    if (_dayNames.isEmpty) {
      return resultList;
    }
    if (today != _dayNames[0]) {
      resultList[0] = _dayNames[0];
    }
    if (tomorrow != _dayNames[1]) {
      resultList[1] = _dayNames[1];
    }
    return resultList;
  }

  set dayNames(List<String> list) {
    SharedPref.setStringList(Names.dayNames, list);
    _dayNames = list;
    notifyListeners();
  }

  List<String> get subjects => _subjects;

  set subjects(List<String> list) {
    SharedPref.setStringList(Names.subjects, list);
    _subjects = list;
    notifyListeners();
  }

  List<String> get subjectsNot => _subjectsNot;

  set subjectsNot(List<String> list) {
    SharedPref.setStringList(Names.subjectsNot, list);
    _subjectsNot = list;
    notifyListeners();
  }

  ///Get substitute of today, handles personalSubstitute too
  List<SubstituteModel> get substituteToday {
    if (_personalSubstitute) {
      return Filter.checkPersonalSubstitute(
          _schoolClass, _rawSubstituteToday, _subjects, _subjectsNot);
    } else {
      return Filter.checkForSchoolClass(_schoolClass, _rawSubstituteToday);
    }
  }

  ///Get substitute of tomorrow, handles personalSubstitute too
  List<SubstituteModel> get substituteTomorrow {
    if (_personalSubstitute) {
      return Filter.checkPersonalSubstitute(
          _schoolClass, _rawSubstituteTomorrow, _subjects, _subjectsNot);
    } else {
      return Filter.checkForSchoolClass(_schoolClass, _rawSubstituteTomorrow);
    }
  }

  List<String> get freeLessons => _freeLessons;

  set freeLessons(List<String> list) {
    SharedPref.setStringList(Names.freeLessons, list);
    _freeLessons = list;
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
