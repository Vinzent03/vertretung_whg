import 'package:flutter/material.dart';

const _darkBackground = Color.fromRGBO(18, 18, 18, 1); //#121212
const _primary = Color.fromRGBO(20, 101, 221, 1);

final darkTheme = ThemeData(
  brightness: Brightness.dark,
  primaryColor: _primary, //#1465DD
  accentColor: _primary,
  cardTheme: CardTheme(
    elevation: 4,
    color: Color.fromRGBO(38, 38, 38, 1),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
  ),
  toggleableActiveColor: _primary,
  scaffoldBackgroundColor: _darkBackground,
  canvasColor: _darkBackground, //used for transition in Home()
  snackBarTheme: SnackBarThemeData(
    backgroundColor: Colors.grey[900],
    contentTextStyle: TextStyle(color: Colors.white),
    actionTextColor: Colors.white,
  ),
  appBarTheme: AppBarTheme(
    color: Color.fromRGBO(38, 38, 38, 1),
  ),
  bottomNavigationBarTheme:
      BottomNavigationBarThemeData(backgroundColor: _darkBackground),
);
final lightTheme = ThemeData(
  brightness: Brightness.light,
  primaryColor: _primary,
  cardTheme: CardTheme(
    elevation: 4,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
  ),
  toggleableActiveColor: _primary,
  appBarTheme: AppBarTheme(
    color: _primary,
  ),
);
