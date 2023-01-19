import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:universal_html/html.dart' as html;

const _darkBackground = Color.fromRGBO(18, 18, 18, 1); //#121212
const _primary = Color.fromRGBO(20, 101, 221, 1);

final darkTheme = ThemeData(
  fontFamily: _isIOS15 ? "--apple-system" : null,
  brightness: Brightness.dark,
  primaryColor: _primary,
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
  colorScheme: ColorScheme.dark(
      primary: _primary, secondary: _primary, onPrimary: Colors.white),
);

final lightTheme = ThemeData(
  fontFamily: _isIOS15 ? "--apple-system" : null,
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
  colorScheme: ColorScheme.light(primary: _primary, secondary: _primary),
);
// https://github.com/flutter/flutter/issues/93140
bool get _isIOS15 {
  return kIsWeb &&
      _detectOperatingSystem() == _OperatingSystem.iOs &&
      html.window.navigator.userAgent.contains('OS 15_');
}

_OperatingSystem _detectOperatingSystem({
  String overridePlatform,
  String overrideUserAgent,
  int overrideMaxTouchPoints,
}) {
  final String platform = overridePlatform ?? html.window.navigator.platform;
  final String userAgent = overrideUserAgent ?? html.window.navigator.userAgent;

  if (platform.startsWith('Mac')) {
    // iDevices requesting a "desktop site" spoof their UA so it looks like a Mac.
    // This checks if we're in a touch device, or on a real mac.
    final int maxTouchPoints =
        overrideMaxTouchPoints ?? html.window.navigator.maxTouchPoints ?? 0;
    if (maxTouchPoints > 2) {
      return _OperatingSystem.iOs;
    }
    return _OperatingSystem.macOs;
  } else if (platform.toLowerCase().contains('iphone') ||
      platform.toLowerCase().contains('ipad') ||
      platform.toLowerCase().contains('ipod')) {
    return _OperatingSystem.iOs;
  } else if (userAgent.contains('Android')) {
    // The Android OS reports itself as "Linux armv8l" in
    // [html.window.navigator.platform]. So we have to check the user-agent to
    // determine if the OS is Android or not.
    return _OperatingSystem.android;
  } else if (platform.startsWith('Linux')) {
    return _OperatingSystem.linux;
  } else if (platform.startsWith('Win')) {
    return _OperatingSystem.windows;
  } else {
    return _OperatingSystem.unknown;
  }
}

enum _OperatingSystem {
  /// iOS: <http://www.apple.com/ios/>
  iOs,

  /// Android: <https://www.android.com/>
  android,

  /// Linux: <https://www.linux.org/>
  linux,

  /// Windows: <https://www.microsoft.com/windows/>
  windows,

  /// MacOs: <https://www.apple.com/macos/>
  macOs,

  /// We were unable to detect the current operating system.
  unknown,
}
