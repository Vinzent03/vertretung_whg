import 'package:Vertretung/models/course_tile_model.dart';

class SubjectsTemplate {
  List<CourseTileModel> subjectsTemplate;

  List<CourseTileModel> _buildVariants(base) {
    List<CourseTileModel> list = [];
    for (int i = 1; i <= 5; i++) {
      list.add(CourseTileModel(title: "$base$i"));
    }
    return list;
  }

  SubjectsTemplate() {
    subjectsTemplate = [
      CourseTileModel(
        title: "Oberstufen Vorlagen",
        children: [
          CourseTileModel(
            title: "BI-GK",
            children: _buildVariants("BI-GK"),
          ),
          CourseTileModel(
            title: "BI-LK",
            children: _buildVariants("BI-LK"),
          ),
          CourseTileModel(
            title: "CH-GK",
            children: _buildVariants("CH-GK"),
          ),
          CourseTileModel(
            title: "CH-LK",
            children: _buildVariants("CH-LK"),
          ),
          CourseTileModel(
            title: "D-GK",
            children: _buildVariants("D-GK"),
          ),
          CourseTileModel(
            title: "D-LK",
            children: _buildVariants("D-LK"),
          ),
          CourseTileModel(
            title: "E-GK",
            children: _buildVariants("E-GK"),
          ),
          CourseTileModel(
            title: "E-LK",
            children: _buildVariants("E-LK"),
          ),
          CourseTileModel(
            title: "EK-GK",
            children: _buildVariants("EK-GK"),
          ),
          CourseTileModel(
            title: "EK-LK",
            children: _buildVariants("EK-LK"),
          ),
          CourseTileModel(
            title: "ER-GK",
            children: _buildVariants("ER-GK"),
          ),
          CourseTileModel(
            title: "F-GK",
            children: _buildVariants("F-GK"),
          ),
          CourseTileModel(
            title: "GE-GK",
            children: _buildVariants("GE-GK"),
          ),
          CourseTileModel(
            title: "GE-LK",
            children: _buildVariants("GE-LK"),
          ),
          CourseTileModel(
            title: "IF-GK",
            children: _buildVariants("IF-GK"),
          ),
          CourseTileModel(
            title: "KR-GK",
            children: _buildVariants("KR-GK"),
          ),
          CourseTileModel(
            title: "KU-GK",
            children: _buildVariants("KU-GK"),
          ),
          CourseTileModel(
            title: "L6-GK",
            children: _buildVariants("L6-GK"),
          ),
          CourseTileModel(
            title: "LI-GK",
            children: _buildVariants("LI-GK"),
          ),
          CourseTileModel(
            title: "M-GK",
            children: _buildVariants("M-GK"),
          ),
          CourseTileModel(
            title: "M-LK",
            children: _buildVariants("M-LK"),
          ),
          CourseTileModel(
            title: "MU-GK",
            children: _buildVariants("MU-GK"),
          ),
          CourseTileModel(
            title: "PA-GK",
            children: _buildVariants("PA-GK"),
          ),
          CourseTileModel(
            title: "PBIO-PK",
            children: _buildVariants("PBIO-PK"),
          ),
          CourseTileModel(
            title: "PCH-PK",
            children: _buildVariants("PCH-PK"),
          ),
          CourseTileModel(
            title: "PH-GK",
            children: _buildVariants("PH-GK"),
          ),
          CourseTileModel(
            title: "PH-LK",
            children: _buildVariants("PH-LK"),
          ),
          CourseTileModel(
            title: "PL-GK",
            children: _buildVariants("PL-GK"),
          ),
          CourseTileModel(
            title: "PPH-PK",
            children: _buildVariants("PPH-PK"),
          ),
          CourseTileModel(
            title: "S0-GK",
            children: _buildVariants("S0-GK"),
          ),
          CourseTileModel(
            title: "S8-GK",
            children: _buildVariants("S8-GK"),
          ),
          CourseTileModel(
            title: "SP-GK",
            children: _buildVariants("SP-GK"),
          ),
          CourseTileModel(
            title: "SW-GK",
            children: _buildVariants("SW-GK"),
          ),
          CourseTileModel(
            title: "GE-ZK",
            children: _buildVariants("GE-ZK"),
          ),
          CourseTileModel(
            title: "SW-ZK",
            children: _buildVariants("SW-ZK"),
          ),
        ],
      )
    ];
  }
}
