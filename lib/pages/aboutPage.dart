import 'package:Vertretung/services/push_notifications.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:package_info/package_info.dart';
import 'package:url_launcher/url_launcher.dart';

class AboutPage extends StatefulWidget {
  @override
  _AboutPageState createState() => _AboutPageState();
}

class _AboutPageState extends State<AboutPage> {
  String version = "Laden";

  @override
  void initState() {
    PackageInfo.fromPlatform()
        .then((onValue) => setState(() => version = onValue.version));
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Über Uns"),
      ),
      body: Builder(
        builder: (context) {
          return SingleChildScrollView(
            child: Column(
              children: <Widget>[
                Card(
                  elevation: 3,
                  child: Column(
                    children: <Widget>[
                      ListTile(
                        title: Text("Vertretung"),
                        leading:
                            Image.asset("assets/icons/ic_launcher_round.png"),
                        subtitle: Text(
                          "Version: $version",
                          style: TextStyle(fontSize: 12),
                        ),
                        trailing: IconButton(
                          icon: Image.asset(
                            "assets/images/Discord-Logo-Color.png",
                          ),
                          onPressed: () => launch("https://discord.gg/X6gdJZg"),
                        ),
                        onTap: () {
                          final SnackBar snack = SnackBar(
                              behavior: SnackBarBehavior.floating,
                              content: Text(
                                  "Benachrichtigungstoken wurde zur Zwischenablage hinzugefügt"),
                              backgroundColor: Colors.red);
                          Scaffold.of(context).showSnackBar(snack);
                          PushNotificationsManager().getToken().then((onValue) {
                            Clipboard.setData(ClipboardData(text: onValue));
                          });
                        },
                      ),
                    ],
                  ),
                ),
                Card(
                  elevation: 3,
                  child: ListTile(
                    leading: Image.asset(
                      "assets/images/Octocat.png",
                      scale: 15,
                    ),
                    title: Text("Wir sind auf GitHub!"),
                    trailing: IconButton(
                      icon: Image.asset(
                        "assets/images/GitHub.png",
                      ),
                      onPressed: () => launch(
                          "https://github.com/Vinzent03/Vertretung-fuer-das-Werner-Heisenberg-Gymnasium"),
                    ),
                  ),
                ),
                Card(
                  elevation: 3,
                  child: Column(
                    children: <Widget>[
                      ListTile(
                        leading: Image.asset(
                          "assets/images/Vinzent-Icon.png",
                          scale: 28,
                        ),
                        title: Text("Vinzent"),
                        trailing: IconButton(
                          icon: Image.asset(
                            "assets/images/Twitter-Icon.png",
                          ),
                          onPressed: () =>
                              launch("https://twitter.com/Vinadon_"),
                        ),
                      ),
                      ListTile(
                        leading: Image.asset(
                          "assets/images/Johannes-Icon.png",
                          scale: 9,
                        ),
                        title: Text("Johannes"),
                      )
                    ],
                  ),
                )
              ],
            ),
          );
        },
      ),
    );
  }
}
