import 'package:Vertretung/logic/sharedPref.dart';
import 'package:Vertretung/models/substituteModel.dart';

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
        String beginn = st.substring(0, st.indexOf("bei +") - 1);
        String end = st.substring(st.indexOf("bei +") + 6);
        st = "$beginn Entfall $end";
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
      for (var st in listWithoutClasses) {
        String stLower = st.title.toLowerCase();

        for (String fach in subjectsList) {
          fach = fach.toLowerCase();
          int i = 0;
          for (String fachNot in subjectsNotList) {
            fachNot = fachNot.toLowerCase();
            if (stLower.contains("bei")) {
              stLower = stLower.substring(0, stLower.indexOf("bei"));
            }
            if (stLower.contains(fach)) {
              if (i != 2) {
                i = 1;
              }
              if (stLower.contains(fachNot)) {
                i = 2;
              }
            }
          }
          if (i == 1) {
            listWithoutLessons.add(st.title);
          }
        }
      }
    }
    return mergeList(listWithoutLessons);
  }
}

List<SubstituteModel> mergeList(var list) {
  List<SubstituteModel> finalList = [];
  for (String item in list) {
    finalList.add(SubstituteModel(item, getSubjectPrefix(item)));
    // finalList.add({"ver": item, "subjectPrefix": getSubjectPrefix(item)});
  }
  return finalList;
}

//get the name of the subject
String getSubjectPrefix(String st) {
  int beginn = st.indexOf("Std. ") + 5;
  int luecke = st.indexOf(" ", beginn) == -1
      ? st.length
      : st.indexOf(" ", beginn); //if the subject stands at the end
  int minus = st.indexOf("-", beginn) == -1
      ? 20
      : st.indexOf("-", beginn); // if no "-" is provided
  int end = luecke < minus ? luecke : minus;

  return st.substring(beginn, end);
}
