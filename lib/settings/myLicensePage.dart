import 'package:flutter/material.dart';
import 'package:flutter_linkify/flutter_linkify.dart';
import 'package:url_launcher/url_launcher.dart';

class MyLicensePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Lizenzen"),
      ),
      body: Column(
        children: [
          Card(
            elevation: 3,
            child: ListTile(
              title: Text("Plugins"),
              leading: Icon(Icons.library_books),
              onTap: () => showLicensePage(
                context: context,
                applicationName: "Vertretung",
                applicationIcon: Image.asset(
                  "assets/icons/icon.png",
                  width: 150,
                ),
              ),
            ),
          ),
          Card(
            elevation: 3,
            child: ListTile(
              title: Linkify(
                text:
                    "Icon made by https://www.freeicons.io/profile/3335 from https://www.freeicons.io",
                onOpen: (link) => launch(link.url),
              ),
              leading: Card(
                child: Image.asset(
                  "assets/icons/icon.png",
                ),
                elevation: 5,
                shape: CircleBorder(),
              ),
            ),
          )
        ],
      ),
    );
  }
}
