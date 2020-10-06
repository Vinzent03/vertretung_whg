import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

class ProviderData with ChangeNotifier {
  ThemeData themeData;
  ProviderData({this.themeData, this.usedThemeMode = ThemeMode.system});
  ThemeMode usedThemeMode;

  ThemeMode getThemeMode() => usedThemeMode;

  setThemeMode(ThemeMode newThemeMode) {
    usedThemeMode = newThemeMode;
    notifyListeners();
  }

  Brightness getUsedTheme() {
    WidgetsBinding.instance.window.onPlatformBrightnessChanged = () {
      notifyListeners();
    };
    addListener(getThemeMode);
    switch (usedThemeMode) {
      case ThemeMode.dark:
        return Brightness.dark;
        break;
      case ThemeMode.light:
        return Brightness.light;
        break;
      case ThemeMode.system:
        return SchedulerBinding.instance.window.platformBrightness;
        break;
      default:
        return Brightness.light;
    }
  }
}
