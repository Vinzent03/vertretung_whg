import 'courseTileModel.dart';

class SubjectsTemplate {
  List<CourseTileModel> subjectsTemplate;

  List<CourseTileModel> _buildVariants(base, count) {
    List<CourseTileModel> list = [];
    for (int i = 1; i <= count; i++) {
      list.add(CourseTileModel(title: "$base$i"));
    }
    return list;
  }

  SubjectsTemplate() {
    subjectsTemplate = [
      CourseTileModel(
        title: "Ef Vorlagen",
        children: [
          CourseTileModel(
            title: "D-GK",
            children: _buildVariants("D-GK", 5),
          ),
          CourseTileModel(
            title: "DVK-VK",
            children: _buildVariants("DVK-VK", 1),
          ),
          CourseTileModel(
            title: "KU-GK",
            children: _buildVariants("KU-GK", 3),
          ),
          CourseTileModel(
            title: "MU-GK",
            children: _buildVariants("MU-GK", 2),
          ),
          CourseTileModel(
            title: "E5-GK",
            children: _buildVariants("E5-GK", 5),
          ),
          CourseTileModel(
            title: "EVK-VK",
            children: _buildVariants("EVK-VK", 1),
          ),
          CourseTileModel(
            title: "F6-GK",
            children: _buildVariants("F6-GK", 1),
          ),
          CourseTileModel(
            title: "SO-GK",
            children: _buildVariants("SO-GK", 2),
          ),
          CourseTileModel(
            title: "L6-GK",
            children: _buildVariants("L6-GK", 2),
          ),
          CourseTileModel(
            title: "GE-GK",
            children: _buildVariants("GE-GK", 3),
          ),
          CourseTileModel(
            title: "EK-GK",
            children: _buildVariants("EK-GK", 3),
          ),
          CourseTileModel(
            title: "PA-GK",
            children: _buildVariants("PA-GK", 2),
          ),
          CourseTileModel(
            title: "SW-GK",
            children: _buildVariants("SW-GK", 3),
          ),
          CourseTileModel(
            title: "PL-GK",
            children: _buildVariants("PL-GK", 2),
          ),
          CourseTileModel(
            title: "M-GK",
            children: _buildVariants("M-GK", 4),
          ),
          CourseTileModel(
            title: "MVK-VK",
            children: _buildVariants("MVK-VK", 2),
          ),
          CourseTileModel(
            title: "PH-GK",
            children: _buildVariants("PH-GK", 3),
          ),
          CourseTileModel(
            title: "BI-GK",
            children: _buildVariants("BI-GK", 3),
          ),
          CourseTileModel(
            title: "CH-GK",
            children: _buildVariants("CH-GK", 3),
          ),
          CourseTileModel(
            title: "IF-GK",
            children: _buildVariants("IF-GK", 2),
          ),
          CourseTileModel(
            title: "KR-GK",
            children: _buildVariants("KR-GK", 2),
          ),
          CourseTileModel(
            title: "ER-GK",
            children: _buildVariants("ER-GK", 1),
          ),
          CourseTileModel(
            title: "SP-GK",
            children: _buildVariants("SP-GK", 4),
          ),
        ],
      )
    ];
  }

}
