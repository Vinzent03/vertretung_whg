import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

class ProviderData with ChangeNotifier {
  ThemeData themeData;
  ProviderData(
      {this.themeData,
      this.isVertretungReload = false,
      this.startAnimation = false,
      this.usedThemeMode = ThemeMode.system});
  bool isVertretungReload;
  bool startAnimation;
  ThemeMode usedThemeMode;
  final GlobalKey<NavigatorState> _navigatorKey = GlobalKey<NavigatorState>();

  ThemeMode getThemeMode() => usedThemeMode;

  setThemeMode(ThemeMode newThemeMode) {
    usedThemeMode = newThemeMode;
    notifyListeners();
  }

  Brightness getUsedTheme() {
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

  GlobalKey<NavigatorState> getNavigatorKey() => _navigatorKey;

  getVertretungReload() => isVertretungReload;

  setVertretungReload(newBool) {
    isVertretungReload = newBool;
    notifyListeners();
  }

  getAnimation() => startAnimation;

  setAnimation(newBool) {
    startAnimation = newBool;
    notifyListeners();
  }
}
