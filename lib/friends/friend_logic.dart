import 'package:Vertretung/logic/filter.dart';
import 'package:Vertretung/models/friend_model.dart';
import 'package:Vertretung/models/substitute_tile_model.dart';
import 'package:Vertretung/provider/user_data.dart';
import 'package:Vertretung/services/auth_service.dart';
import 'package:Vertretung/services/cloud_database.dart';
import 'package:Vertretung/services/dynamic_link.dart';
import 'package:flutter/material.dart';
import 'package:progress_dialog/progress_dialog.dart';
import 'package:share/share.dart';

class FriendLogic {
  static List<SubstituteModel> _getSubstituteOfFriend(
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

  static bool _isLessonOver(int lesson, DateTime now) {
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

  static List<SubstituteModel> _getFreeLessonsOfFriend(
      List<String> friendFreeLessons) {
    List<SubstituteModel> freeLessons = [];
    DateTime now = DateTime.now();
    //cycle through free lesson entries
    for (int i = 0; i < friendFreeLessons.length; i++) {
      String entry = friendFreeLessons[i];
      int lesson = int.parse(entry.substring(1, 2));
      int weekday = int.parse(entry.substring(0, 1));
      //use only free lessons of current weekday
      if (weekday != now.weekday - 1) continue;
      if (_isLessonOver(lesson, now)) continue;
      if (freeLessons.isNotEmpty) {
        if (freeLessons.last.title.contains((lesson - 1).toString())) {
          //change lesson range
          if (freeLessons.last.title.contains("-")) {
            freeLessons.last.title =
                freeLessons.last.title.replaceRange(5, 6, lesson.toString());
          }
          //change from single to multi lesson
          else {
            freeLessons.last.title =
                "${(lesson - 1).toString()}. - ${lesson.toString()} Std. Freistunde";
          }
        } else {
          freeLessons.add(
              SubstituteModel("${lesson.toString()}. Std. Freistunde", "YY"));
        }
      } else {
        freeLessons.add(
            SubstituteModel("${lesson.toString()}. Std. Freistunde", "YY"));
      }
    }

    return freeLessons;
  }

  /// includes substitute and free lessons
  static List<SubstituteModel> getFriendsSubstitute(
      List<FriendModel> friends, List<String> rawSubstituteToday) {
    List<SubstituteModel> friendsSubstitute = [];

    for (FriendModel friend in friends) {
      List<SubstituteModel> substituteAndFreeLessons =
          _getSubstituteOfFriend(friend, rawSubstituteToday) +
              _getFreeLessonsOfFriend(friend.freeLessons);
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

  static List<String> friendsFreeWithUser(
      List<FriendModel> friendsSettings, UserData provider) {
    List<int> lessonRange(String title) {
      String begin = title.substring(0, 1);
      String end = title.substring(5, 6);

      List<int> lessonsRange = [];
      //check for integer; if substitute is multi lesson

      if (int.tryParse(end) != null) {
        for (int i = int.parse(begin); i <= int.parse(end); i++) {
          lessonsRange.add(i);
        }
      } else {
        lessonsRange.add(int.parse(begin));
      }
      return lessonsRange;
    }

    List<SubstituteModel> equalSubstitute = [];
    List<SubstituteModel> userFreeTime = provider.substituteToday
        .where((element) => element.title.contains("Entfall"))
        .toList();
    userFreeTime.addAll(_getFreeLessonsOfFriend(provider.freeLessons));
    List<SubstituteModel> friendsSubstitute =
        getFriendsSubstitute(friendsSettings, provider.rawSubstituteToday);

    for (var friendSubstitute in friendsSubstitute) {
      List<int> friendLessons = lessonRange(friendSubstitute.title);
      for (var userSubstitute in userFreeTime) {
        List<int> userLessons = lessonRange(userSubstitute.title);
        for (int i in friendLessons) {
          for (int j in userLessons) {
            if (i == j) {
              if (!equalSubstitute.contains(userSubstitute)) {
                equalSubstitute.add(friendSubstitute);
              }
            }
          }
        }
      }
    }

    return friendsWithFreetime(equalSubstitute);
  }

  static List<String> friendsWithFreetime(
      List<SubstituteModel> friendsSubstitute) {
    List<String> friends = [];
    for (var item in friendsSubstitute) {
      for (var friend in item.names.split(",")) {
        if (!friends.contains(friend.trim())) {
          friends.add(friend.trim());
        }
      }
    }
    return friends;
  }

  static void shareFriendsToken(BuildContext context) async {
    ProgressDialog pr = ProgressDialog(context,
        type: ProgressDialogType.Normal, isDismissible: false, showLogs: false);
    await pr.show();
    String uid = AuthService().getUserId();
    String link = await DynamicLink().createLink();
    String name = await CloudDatabase().getName();
    await pr.hide();
    Share.share("Hier ist der Freundestoken von $name: '" +
        uid.substring(0, 5) +
        "' Dieser muss nun unter 'als Freund eintagen' eingegeben werden. Oder einfach auf diesen Link klicken(nur Android): $link");
  }
}
