import 'package:flutter/material.dart';
import 'vertretungTile.dart';

class GeneralBlueprint extends StatelessWidget {
  final List<List<String>> list;
  GeneralBlueprint({
    Key key,
    @required this.list,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (list[0].isNotEmpty)
      return ListView.builder(
          physics: ScrollPhysics(),
          shrinkWrap: true,
          itemCount: list[0].length,
          itemBuilder: (context, index) {
            return VertretungTile(
              faecher: list[0][index],
              names: list[1][index],
            );
          });
    else
      return Center(
        child: Icon(
          Icons.business_center,
          color: Colors.blue,
          size: 200,
        ),
      );
  }
}
