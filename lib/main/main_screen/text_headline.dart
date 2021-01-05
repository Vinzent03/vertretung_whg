import 'package:flutter/material.dart';

class TextHeadline extends StatelessWidget {
  final String text;

  TextHeadline(this.text);
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(8, 15, 0, 5),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}
