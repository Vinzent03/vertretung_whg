class CourseTileModel {
  String title;
  bool isChecked;
  bool isCustom;
  List<CourseTileModel> children;

  CourseTileModel({
    this.title,
    this.children = const [],
    this.isChecked = false,
    this.isCustom = false,
  });
}
