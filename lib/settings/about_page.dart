import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';

class AboutPage extends StatefulWidget {
  @override
  _AboutPageState createState() => _AboutPageState();
}

class _AboutPageState extends State<AboutPage> {
  String version = "Loading";

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
                        leading: Card(
                          child: Image.asset(
                            "assets/icons/icon.png",
                          ),
                          elevation: 5,
                          shape: CircleBorder(),
                        ),
                        subtitle: Text(
                          "Version: $version",
                          style: TextStyle(fontSize: 12),
                        ),
                        trailing: IconButton(
                          icon: Image.asset(
                            "assets/images/Discord-Logo-Color.png",
                          ),
                          onPressed: () =>
                              launch("https://discord.gg/xmTcUhP3Xn"),
                        ),
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
                    onTap: () =>
                        launch("https://github.com/Vinzent03/vertretung_whg"),
                    trailing: IconButton(
                      icon: Image.asset(
                        "assets/images/GitHub.png",
                      ),
                      onPressed: () =>
                          launch("https://github.com/Vinzent03/vertretung_whg"),
                    ),
                  ),
                ),
                Card(
                  elevation: 3,
                  child: ListTile(
                    leading: Image.asset(
                      "assets/images/Vinzent-Icon.png",
                      scale: 28,
                    ),
                    title: Text("Vinzent"),
                    trailing: IconButton(
                      icon: Image.asset(
                        "assets/images/Twitter-Icon.png",
                      ),
                      onPressed: () => launch("https://twitter.com/Vinadon_"),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
