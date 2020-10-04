import 'package:Vertretung/logic/sharedPref.dart';
import 'package:Vertretung/models/substituteModel.dart';
import "dart:math";
class Filter {
  SharedPref sharedPref = SharedPref();

  String schoolClass;
  final List<String> rawList;
  Filter(this.schoolClass, this.rawList);

  List<SubstituteModel> checkForSchoolClass() {
    //filter the specific class:

    // 0 bevor the class was found in the list, 1 in the class, 2 out of the class
    List<String> listWithoutClasses = [];
    int b = 0;
    schoolClass = schoolClass.toLowerCase();
    for (String part in rawList) {
      String stk = part.toLowerCase();
      if (stk.contains("std.")) {
        if (b == 1) {
          listWithoutClasses.add(part);
        }
      } else {
        if (stk.contains(schoolClass)) {
          b = 1;
        } else {
          b = 2;
        }
      }
    }

    //just a better formatting of the given text(not especially needed)
    List<String> betterList = [];
    for (String st in listWithoutClasses) {
      if (st.contains("bei +")) {
        if (!st.substring(st.indexOf("bei +")).contains(",")) {
          String beginn = st.substring(0, st.indexOf("bei +") - 1);
          st = "$beginn Entfall";
        } else
          st = st.replaceFirst("bei +", "Entfall");
      }
      betterList.add(st);
    }

    return mergeList(betterList);
  }

  //check only for the given subjects
  List<dynamic> checkForSubjects(
      List<dynamic> subjectsList, List<dynamic> subjectsNotList) {
    List<SubstituteModel> listWithoutClasses = checkForSchoolClass();
    List<String> listWithoutLessons = [];
    if (subjectsList.isEmpty || (subjectsList[0] == "")) {
      // Wenn man bei der Eingabe alles weg macht
      subjectsList = [""];
    }
    if (subjectsNotList.isEmpty || (subjectsNotList[0] == "")) {
      subjectsNotList = ["customExample"];
    }

    if (listWithoutClasses.isNotEmpty) {
      for (SubstituteModel item in listWithoutClasses) {
        String titleLower = item.title.toLowerCase();

        for (String rawSubject in subjectsList) {
          String subject = " " + rawSubject.toLowerCase() + " ";
          int i = 0;
          for (String rawSubjectNot in subjectsNotList) {
            String subjectNot = rawSubjectNot.toLowerCase();
            if (titleLower.contains("bei")) {
              titleLower = titleLower.substring(0, titleLower.indexOf("bei"));
            }
            if (titleLower.contains(subject)) {
              if (i != 2) {
                i = 1;
              }
              if (titleLower.contains(subjectNot)) {
                i = 2;
              }
            }
          }
          if (i == 1) {
            listWithoutLessons.add(item.title);
          }
        }
      }
    }
    return mergeList(listWithoutLessons);
  }
}

List<SubstituteModel> mergeList(List<String> list) {
  List<SubstituteModel> finalList = [];
  for (String item in list) {
    finalList.add(SubstituteModel(item, getSubjectPrefix(item)));
  }
  return finalList;
}

//get the name of the subject
String getSubjectPrefix(String st) {
  //GE-GK1 would be the course
  //GE would be subject 

  int beginIndex = st.indexOf("Std. ") + 5;
  if (st.substring(beginIndex, beginIndex + 7).contains("Entfall"))
    return "";
  int endOfSubject = st.indexOf(" ", beginIndex) == -1
      ? st.length
      : st.indexOf(" ", beginIndex); //if the subject stands at the end
  int endOfCourse = st.indexOf("-", beginIndex) == -1
      ? 20
      : st.indexOf("-", beginIndex); // if no "-" is provided
  // int end = endOfSubject < endOfCourse ? endOfSubject : endOfCourse;
  int end = min(endOfSubject,endOfCourse);

  return st.substring(beginIndex, end);
}
