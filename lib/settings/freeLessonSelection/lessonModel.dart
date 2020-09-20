import 'package:Vertretung/settings/freeLessonSelection/freeLessonSelection.dart';

class LessonModel {
  final Weekdays day;
  final int lesson;
  bool isChecked = false;
  final List<LessonModel> children;

  LessonModel({this.day, this.lesson, this.children = const []});
}
