import 'package:Vertretung/logic/filter.dart';
import 'package:Vertretung/logic/shared_pref.dart';
import 'package:Vertretung/models/friend_model.dart';
import 'package:Vertretung/models/substitute_tile_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class FriendLogic {
  final FirebaseFirestore ref = FirebaseFirestore.instance;
  SharedPref sharedPref = SharedPref();

  List<SubstituteModel> _getSubstituteOfFriend(
      FriendModel friend, List<String> rawSubstituteList) {
    List<SubstituteModel> substitute;
    List<SubstituteModel> justCancelledLessons = [];
    if (friend.personalSubstitute) {
      var list = Filter.checkPersonalSubstitute(friend.schoolClass,
          rawSubstituteList, friend.subjects, friend.subjectsNot);
      substitute = list;
    } else {
      var list =
          Filter.checkForSchoolClass(friend.schoolClass, rawSubstituteList);
      substitute = list;
    }
    for (SubstituteModel item in substitute) {
      if (item.title.contains("Entfall")) justCancelledLessons.add(item);
    }
    return justCancelledLessons;
  }

  bool _isLessonOver(int lesson, DateTime now) {
    List<Map<String, int>> lessons = [
      {
        "hour": 8,
        "minute": 45,
      },
      {
        "hour": 9,
        "minute": 35,
      },
      {
        "hour": 10,
        "minute": 25,
      },
      {
        "hour": 11,
        "minute": 35,
      },
      {
        "hour": 12,
        "minute": 25,
      },
      {
        "hour": 13,
        "minute": 30,
      },
      {
        "hour": 14,
        "minute": 20,
      },
      {
        "hour": 15,
        "minute": 10,
      },
      {
        "hour": 16,
        "minute": 00,
      },
    ];
    return now.isAfter(DateTime(now.year, now.month, now.day,
        lessons[lesson - 1]["hour"], lessons[lesson - 1]["minute"]));
  }

  List<SubstituteModel> _getFreeLessonsOfFriend(FriendModel friend) {
    List<SubstituteModel> freeLessons = [];
    DateTime now = DateTime.now();
    //cycle thru free lessons entries
    for (int i = 0; i < friend.freeLessons.length; i++) {
      String entry = friend.freeLessons[i];
      int lesson = int.parse(entry.substring(1, 2));
      int weekday = int.parse(entry.substring(0, 1));
      //use only free lessons of current weekday
      if (weekday != now.weekday - 1) continue;
      if (_isLessonOver(lesson, now)) continue;
      if (freeLessons.isNotEmpty) {
        if (freeLessons.last.title.contains((lesson - 1).toString())) {
          //change lesson range
          if (freeLessons.last.title.contains("-"))
            freeLessons.last.title =
                freeLessons.last.title.replaceRange(5, 6, lesson.toString());
          //change from single to multi lesson
          else
            freeLessons.last.title =
                "${(lesson - 1).toString()}. - ${lesson.toString()} Std. Freistunde";
        } else
          freeLessons.add(
              SubstituteModel("${lesson.toString()}. Std. Freistunde", "YY"));
      } else
        freeLessons.add(
            SubstituteModel("${lesson.toString()}. Std. Freistunde", "YY"));
    }

    return freeLessons;
  }

  /// includes substitute and free lessons
  List<SubstituteModel> getFriendsSubstitute(
      List<FriendModel> friends, List<String> rawSubstituteToday) {
    List<SubstituteModel> friendsSubstitute = [];

    for (FriendModel friend in friends) {
      List<SubstituteModel> substituteAndFreeLessons =
          _getSubstituteOfFriend(friend, rawSubstituteToday) +
              _getFreeLessonsOfFriend(friend);
      for (SubstituteModel substitute in substituteAndFreeLessons) {
        if (friendsSubstitute.map((e) => e.title).contains(substitute.title)) {
          //instead of showing a substitute doubled add the name to the existing one
          friendsSubstitute
              .firstWhere((element) => element.title == substitute.title)
              .names += ", " + friend.name;
        } else {
          //nobody else has this substitute so far
          friendsSubstitute.add(SubstituteModel(
              substitute.title, substitute.subjectPrefix, friend.name));
        }
      }
    }
    friendsSubstitute.sort((a, b) => a.title.compareTo(b.title));
    return friendsSubstitute;
  }
}
