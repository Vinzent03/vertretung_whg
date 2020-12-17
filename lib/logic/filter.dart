import "dart:math";

import 'package:Vertretung/models/substituteModel.dart';

class Filter {
  /// Get list containing only the substitute of the given schoolClass
  static List<SubstituteModel> checkForSchoolClass(
      String schoolClass, List<String> rawList) {
    List<String> listWithoutClasses = [];
    bool inSchoolClass = false;
    String schoolClassLow = schoolClass.toLowerCase();
    for (String item in rawList) {
      String itemLow = item.toLowerCase();
      // If the item contains `std.` its substitute and not the information about which schoolClass
      if (itemLow.contains("std.")) {
        if (inSchoolClass) {
          listWithoutClasses.add(item);
        }
      } else {
        if (itemLow.contains(schoolClassLow)) {
          //Until the next occurrence of a schoolClass, it contains only substitute of the given schoolClass
          inSchoolClass = true;
        } else {
          // not in substitute of the given schoolClass
          inSchoolClass = false;
        }
      }
    }

    return _addSubjectPrefixes(_formatList(listWithoutClasses));
  }

  ///Get list containing only the substitute for the schoolClass and the subjects
  static List<SubstituteModel> checkPersonalSubstitute(String schoolClass,
      List<String> rawList, List<dynamic> subjects, List<dynamic> subjectsNot) {
    List<SubstituteModel> substituteWithSchoolClass =
        checkForSchoolClass(schoolClass, rawList);
    List<String> resultList = [];

    for (SubstituteModel item in substituteWithSchoolClass) {
      String substitute = item.title.toLowerCase();
      if (substitute.contains("bei")) {
        substitute = substitute.substring(0, substitute.indexOf("bei"));
      }
      if (["EF", "Q1", "Q2"].contains(schoolClass)) {
        if (_isWhitelist(substitute, subjects)) {
          resultList.add(item.title);
        }
      } else {
        if (!_isBlacklist(substitute, subjectsNot)) {
          resultList.add(item.title);
        }
      }
    }
    return _addSubjectPrefixes(resultList);
  }
}

List<SubstituteModel> _addSubjectPrefixes(List<String> list) {
  List<SubstituteModel> finalList = [];
  for (String item in list) {
    finalList.add(SubstituteModel(item, _getSubjectPrefix(item)));
  }
  return finalList;
}

bool _isWhitelist(String substitute, List<String> subjects) {
  bool isWhitelist = false;
  for (String subject in subjects) {
    String formattedSubject = " " + subject.toLowerCase() + " ";
    if (substitute.contains(formattedSubject)) {
      isWhitelist = true;
      break;
    }
  }
  return isWhitelist;
}

bool _isBlacklist(String substitute, List<String> subjectsNot) {
  bool isBlacklist = false;
  for (String subject in subjectsNot) {
    String formattedSubject = " " + subject.toLowerCase() + " ";
    if (substitute.contains(formattedSubject)) {
      isBlacklist = true;
      break;
    }
  }
  return isBlacklist;
}

///just a better formatting of the given text(not especially needed)
List<String> _formatList(List<String> list) {
  List<String> formattedList = [];
  for (String st in list) {
    if (st.contains("bei +")) {
      bool textContainsSubject = false;
      for (String subjectSuffix in ["-GK", "-LK", "-PK", "-ZK"]) {
        if (st.contains(subjectSuffix)) textContainsSubject = true;
      }

      if (textContainsSubject) {
        String beginn = st.substring(0, st.indexOf("bei +") - 1);
        st = "$beginn Entfall";
      } else
        st = st.replaceFirst("bei +", "Entfall");
    }
    formattedList.add(st);
  }
  return formattedList;
}

///get the name of the subject
String _getSubjectPrefix(String st) {
  //GE-GK1 would be the course
  //GE would be subject

  int beginIndex = st.indexOf("Std. ") + 5;
  if (st.substring(beginIndex, beginIndex + 7).contains("Entfall")) return "";
  int endOfSubject = st.indexOf(" ", beginIndex) == -1
      ? st.length
      : st.indexOf(" ", beginIndex); //if the subject stands at the end
  int endOfCourse = st.indexOf("-", beginIndex) == -1
      ? 20
      : st.indexOf("-", beginIndex); // if no "-" is provided
  int end = min(endOfSubject, endOfCourse);

  return st.substring(beginIndex, end);
}
