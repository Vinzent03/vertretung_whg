class FriendModel {
  ///Only used for the filter
  bool isChecked;
  final name;
  final uid;
  String schoolClass;
  bool personalSubstitute;
  List<dynamic> subjects;
  List<dynamic> subjectsNot;
  FriendModel({
    this.name,
    this.uid,
    this.isChecked,
    this.schoolClass,
    this.personalSubstitute,
    this.subjects,
    this.subjectsNot,
  });
}
