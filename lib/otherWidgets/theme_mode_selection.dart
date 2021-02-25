import 'package:Vertretung/data/names.dart';
import 'package:Vertretung/logic/shared_pref.dart';
import 'package:Vertretung/provider/theme_settings.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ThemeModeSelection extends StatelessWidget {
  final ThemeMode selectedThemeMode;
  ThemeModeSelection(this.selectedThemeMode);

  final List<String> modes = ["System Modus", "Heller Modus", "Dunkler Modus"];

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(Icons.color_lens),
      title: Text("Theme"),
      trailing: Text(modes[selectedThemeMode.index]),
      onTap: () => showSelection(context),
    );
  }

  showSelection(context) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return ListView.builder(
          shrinkWrap: true,
          itemCount: modes.length,
          itemBuilder: (context, index) {
            return ListTile(
              title: Text(modes[index]),
              onTap: () {
                SharedPref.setInt(Names.themeMode, index);
                context
                    .read<ThemeSettings>()
                    .setThemeMode(ThemeMode.values[index]);
                Navigator.pop(context);
              },
            );
          },
        );
      },
    );
  }
}
