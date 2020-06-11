import 'package:Vertretung/logic/localDatabase.dart';

class Filter {
  LocalDatabase localDatabase = LocalDatabase();

  String stufe;
  Filter(this.stufe);

  Future<List<dynamic>> checker(String day) async {
    //filter the specific class:

    // 0 bevor the class was found in the list, 1 in the class, 2 out of the class
    List<String> rawList = await localDatabase.getStringList(day);
    List<String> listWithoutClasses = [];
    int b = 0;
    stufe = stufe.toLowerCase();
    for (String part in rawList) {
      String stk = part.toLowerCase();
      if (stk.contains("std.")) {
        if (b == 1) {
          listWithoutClasses.add(part);
        }
      } else {
        if (stk.contains(stufe)) {
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

  //check only for the given faecher
  Future<List<dynamic>> checkerFaecher(String day, List<dynamic> faecherList,
      List<dynamic> faecherNotList) async {
    List<dynamic> all = await checker(day);
    List<dynamic> listWithoutClasses = all;
    List<dynamic> listWithoutLessons = [];
    if (faecherList.isEmpty || (faecherList[0] == "")) {
      // Wenn man bei der Eingabe alles weg macht
      faecherList = [""];
    }
    if (faecherNotList.isEmpty || (faecherNotList[0] == "")) {
      faecherNotList = ["customExample"];
    }

    if (listWithoutClasses.isNotEmpty) {
      for (var st in listWithoutClasses) {
        String stLower = st["ver"].toLowerCase();

        for (String fach in faecherList) {
          fach = fach.toLowerCase();
          int i = 0;
          for (String fachNot in faecherNotList) {
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
            listWithoutLessons.add(st["ver"]);
          }
        }
      }
    }
    return mergeList(listWithoutLessons);
  }
}

List<dynamic> mergeList(var list) {
  List<dynamic> finalList = [];
  for (String item in list) {
    finalList.add({"ver": item, "subjectPrefix": getSubjectPrefix(item)});
  }
  return finalList;
}

//get the name of the subject
String getSubjectPrefix(String st) {
  int beginn = st.indexOf("Std. ") + 5;
  int luecke = st.indexOf(" ", beginn);
  int minus = st.indexOf("-", beginn) == -1
      ? 20
      : st.indexOf("-", beginn); // if no "-" is provided
  int end = luecke < minus ? luecke : minus;

  return st.substring(beginn, end);
}
