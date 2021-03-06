import 'package:Vertretung/provider/theme_data.dart';
import 'package:flutter/material.dart';

class SingleIntroPage extends StatelessWidget {
  final String title;
  final Widget body;
  final Widget footer;

  const SingleIntroPage({
    Key key,
    this.title,
    @required this.body,
    this.footer,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: ListView(
        children: [
          if (title != null)
            Padding(
              padding: const EdgeInsets.only(top: 75, bottom: 20),
              child: Text(
                title,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: lightTheme.primaryColor,
                  fontSize: 30,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 40),
            child: body,
          ),
          if (footer != null)
            Align(
              alignment: Alignment.center,
              child: footer,
            )
        ],
      ),
    );
  }
}
