import 'package:Vertretung/logic/install_apk.dart';
import 'package:flutter/material.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:url_launcher/url_launcher.dart';

class UpdateDialog extends StatefulWidget {
  final String title;
  final String description;
  final String changelogLink;
  final String websiteLink;
  final String downloadLink;
  final bool isForce;

  const UpdateDialog({
    Key key,
    @required this.title,
    @required this.description,
    @required this.changelogLink,
    @required this.websiteLink,
    @required this.downloadLink,
    @required this.isForce,
  }) : super(key: key);
  @override
  _UpdateDialogState createState() => _UpdateDialogState();
}

class _UpdateDialogState extends State<UpdateDialog> {
  InstallApk installApk;
  int value = 0;
  bool isDownloading = false;
  bool isInstalling = false;

  @override
  void initState() {
    super.initState();
    installApk = InstallApk(widget.downloadLink);
    initDownloader(context);
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        if (widget.isForce) {
          return false;
        }
        installApk.dispose();
        return true;
      },
      child: AnimatedSwitcher(
          duration: Duration(milliseconds: 300),
          child: Builder(
            builder: (context) {
              if (isDownloading)
                return AlertDialog(
                  key: ValueKey(isDownloading),
                  title: !isInstalling
                      ? LinearProgressIndicator(
                          valueColor:
                              AlwaysStoppedAnimation<Color>(Colors.green),
                          minHeight: 5,
                          value: value.toDouble() / 100,
                        )
                      : Center(child: CircularProgressIndicator()),
                  content: Text(
                      "Bitte bei Problemen neue APK über die Website herunterladen."),
                  actions: [
                    ElevatedButton(
                      onPressed: () {
                        installApk.cancel();
                        setState(() {
                          isDownloading = false;
                          isInstalling = false;
                        });
                      },
                      child: Text("Abbrechen"),
                    ),
                    OutlinedButton(
                      onPressed: () => launchUrl(Uri.parse(widget.websiteLink)),
                      child: Text("Über Website herunterladen"),
                      style: ButtonStyle(
                          foregroundColor:
                              MaterialStateProperty.all(Colors.red)),
                    ),
                  ],
                );
              else
                return AlertDialog(
                  key: ValueKey(isDownloading),
                  title: Text(widget.title),
                  content: Text(widget.description),
                  actions: <Widget>[
                    if (!widget.isForce)
                      TextButton(
                        child: Text("Abbrechen"),
                        onPressed: () {
                          installApk.dispose();
                          Navigator.of(context, rootNavigator: true).pop();
                        },
                      ),
                    OutlinedButton(
                      child: Text("Changelog"),
                      onPressed: () =>
                          launchUrl(Uri.parse(widget.changelogLink)),
                    ),
                    ElevatedButton(
                      child: Text("Download"),
                      onPressed: () => download(context),
                    ),
                  ],
                );
            },
          )),
    );
  }

  void download(context) {
    setState(() => isDownloading = true);

    installApk.download();
  }

  Future<void> initDownloader(BuildContext context) async {
    await installApk.init();
    installApk.listen((message) async {
      print("MOIN");
      setState(() => value = message[2]);

      if (message[1] == DownloadTaskStatus.complete) {
        setState(() => isInstalling = true);
        await Future.delayed(Duration(seconds: 2));
        installApk.install();
      }
      if (message[1] == DownloadTaskStatus.failed) {
        setState(() => isDownloading = false);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text("Das hat nicht geklappt. Bitte versuche es erneut!"),
          backgroundColor: Colors.red,
        ));
      }
    });
  }
}
