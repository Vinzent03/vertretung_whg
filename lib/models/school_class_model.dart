class SchoolClassModel {
  final String title;
  List<SchoolClassModel> children;
  bool isChecked;

  SchoolClassModel(this.title, [this.children = const [], this.isChecked = false]);
}
