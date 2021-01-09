import 'package:flutter/material.dart';

class TextHeadline extends StatelessWidget {
  final String text;
  final String count;

  TextHeadline(this.text, [this.count]);
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(8, 15, 0, 5),
      child: Row(
        children: [
          Text(
            text,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w500,
            ),
          ),
          if (count != null)
            Text(
              count,
              style: TextStyle(
                color: Theme.of(context).primaryColor,
                fontSize: 20,
                fontWeight: FontWeight.w700,
              ),
            )
        ],
      ),
    );
  }
}
