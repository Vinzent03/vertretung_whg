import 'package:flutter/material.dart';

final darkTheme = ThemeData(
  brightness: Brightness.dark,
  accentColor: Colors.blue[800],
  cardColor: Colors.grey[900],
  toggleableActiveColor: Colors.blue[800],
  scaffoldBackgroundColor: Colors.black,
  snackBarTheme: SnackBarThemeData(
      backgroundColor: Colors.grey[900],
      contentTextStyle: TextStyle(color: Colors.white),
      actionTextColor: Colors.white),
  appBarTheme: AppBarTheme(
    color: Colors.grey[900],
  ),
);
final lightTheme = ThemeData(
  brightness: Brightness.light,
  accentColor: Colors.blue[800],
  cardColor: Colors.white,
  toggleableActiveColor: Colors.blue[800],
  scaffoldBackgroundColor: Colors.white,
  appBarTheme: AppBarTheme(
    color: Colors.blue[800],
  ),
);
