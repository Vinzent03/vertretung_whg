class FriendModel {
  ///Only used for the filter
  bool isChecked;
  final name;
  final uid;
  String schoolClass;
  bool personalSubstitute;
  List<dynamic> subjects;
  List<dynamic> subjectsNot;
  List<dynamic> freeLessons;
  FriendModel({
    this.name,
    this.uid,
  });
}
