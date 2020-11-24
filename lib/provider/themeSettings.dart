import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

class ThemeSettings with ChangeNotifier {
  ThemeSettings() {
    WidgetsBinding.instance.window.onPlatformBrightnessChanged = () {
      _setBrightness();
      notifyListeners();
    };
  }
  ThemeMode usedThemeMode = ThemeMode.system;
  Brightness brightness;

  ThemeMode getThemeMode() => usedThemeMode;

  setThemeMode(ThemeMode newThemeMode) {
    usedThemeMode = newThemeMode;
    _setBrightness();
    notifyListeners();
  }

  void _setBrightness() {
    switch (usedThemeMode) {
      case ThemeMode.dark:
        brightness = Brightness.dark;
        break;
      case ThemeMode.light:
        brightness = Brightness.light;
        break;
      case ThemeMode.system:
        brightness = SchedulerBinding.instance.window.platformBrightness;
        break;
    }
  }
}
