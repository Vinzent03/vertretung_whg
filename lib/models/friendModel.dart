class FriendModel {
  final uid;
  final String name;
  final String schoolClass;
  final bool personalSubstitute;
  final List<dynamic> subjects;
  final List<dynamic> subjectsNot;
  final List<dynamic> freeLessons;
  const FriendModel(
    this.uid,
    this.name, [
    this.schoolClass,
    this.personalSubstitute,
    this.subjects,
    this.subjectsNot,
    this.freeLessons,
  ]);
}
