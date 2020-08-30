import '../../models/courseTileModel.dart';

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
        title: "Q1 Vorlagen",
        children: [
          CourseTileModel(
            title: "BI-GK",
            children: _buildVariants("BI-GK", 2),
          ),
          CourseTileModel(
            title: "BI-LK",
            children: _buildVariants("BI-LK", 1),
          ),
          CourseTileModel(
            title: "CH-GK",
            children: _buildVariants("CH-GK", 2),
          ),
          CourseTileModel(
            title: "CH-LK",
            children: _buildVariants("CH-LK", 1),
          ),
          CourseTileModel(
            title: "D-GK",
            children: _buildVariants("D-GK", 3),
          ),
          CourseTileModel(
            title: "D-LK",
            children: _buildVariants("D-LK", 2),
          ),
          CourseTileModel(
            title: "E-GK",
            children: _buildVariants("E-GK", 3),
          ),
          CourseTileModel(
            title: "E-LK",
            children: _buildVariants("E-LK", 2),
          ),
          CourseTileModel(
            title: "EK-GK",
            children: _buildVariants("EK-GK", 1),
          ),
          CourseTileModel(
            title: "EK-LK",
            children: _buildVariants("EK-LK", 2),
          ),
          CourseTileModel(
            title: "ER-GK",
            children: _buildVariants("ER-GK", 1),
          ),
          CourseTileModel(
            title: "F-GK",
            children: _buildVariants("F-GK", 1),
          ),
          CourseTileModel(
            title: "GE-GK",
            children: _buildVariants("GE-GK", 2),
          ),
          CourseTileModel(
            title: "GE-LK",
            children: _buildVariants("GE-LK", 1),
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
            title: "KU-GK",
            children: _buildVariants("KU-GK", 2),
          ),
          CourseTileModel(
            title: "L6-GK",
            children: _buildVariants("L6-GK", 1),
          ),
          CourseTileModel(
            title: "LI-GK",
            children: _buildVariants("LI-GK", 1),
          ),
          CourseTileModel(
            title: "M-GK",
            children: _buildVariants("M-GK", 3),
          ),
          CourseTileModel(
            title: "M-LK",
            children: _buildVariants("M-LK", 2),
          ),
          CourseTileModel(
            title: "MU-GK",
            children: _buildVariants("MU-GK", 2),
          ),
          CourseTileModel(
            title: "PA-GK",
            children: _buildVariants("PA-GK", 2),
          ),
          CourseTileModel(
            title: "PBIO-PK",
            children: _buildVariants("PBIO-PK", 1),
          ),
          CourseTileModel(
            title: "PCH-PK",
            children: _buildVariants("PCH-PK", 1),
          ),
          CourseTileModel(
            title: "PH-GK",
            children: _buildVariants("PH-GK", 1),
          ),
          CourseTileModel(
            title: "PH-LK",
            children: _buildVariants("PH-LK", 1),
          ),
          CourseTileModel(
            title: "PL-GK",
            children: _buildVariants("PL-GK", 2),
          ),
          CourseTileModel(
            title: "PPH-PK",
            children: _buildVariants("PPH-PK", 1),
          ),
          CourseTileModel(
            title: "S0-GK",
            children: _buildVariants("S0-GK", 1),
          ),
          CourseTileModel(
            title: "S8-GK",
            children: _buildVariants("S8-GK", 1),
          ),
          CourseTileModel(
            title: "SP-GK",
            children: _buildVariants("SP-GK", 4),
          ),
          CourseTileModel(
            title: "SW-GK",
            children: _buildVariants("SW-GK", 2),
          ),
          CourseTileModel(
            title: "WLI-GK",
            children: _buildVariants("WLI-GK", 1),
          ),
        ],
      )
    ];
  }
}
