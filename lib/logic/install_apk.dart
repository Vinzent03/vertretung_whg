import 'dart:async';
import 'dart:isolate';
import 'dart:ui';

import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:path_provider/path_provider.dart';

class InstallApk {
  String _path;
  String _taskId;
  ReceivePort _port = ReceivePort();
  final String _downloadLink;

  InstallApk(this._downloadLink);

  Future<void> init() async {
    await FlutterDownloader.initialize(debug: false);
    _bindBackgroundIsolate();
    FlutterDownloader.registerCallback(downloadCallback);
  }

  StreamSubscription<dynamic> listen(void Function(dynamic) message) =>
      _port.listen(message);

  void _bindBackgroundIsolate() {
    IsolateNameServer.registerPortWithName(
        _port.sendPort, "downloader_send_port");
  }

  Future<void> download() async {
    _path = (await getExternalStorageDirectory()).path;
    _taskId = await FlutterDownloader.enqueue(
        url: _downloadLink, savedDir: _path, fileName: "Vertretung.apk");
    await FlutterDownloader.loadTasks();
  }

  Future<void> install() async {
    await FlutterDownloader.open(taskId: _taskId);
  }

  static void downloadCallback(
      String id, DownloadTaskStatus status, int progress) {
    final SendPort send =
        IsolateNameServer.lookupPortByName('downloader_send_port');
    send.send([id, status, progress]);
  }

  void dispose() {
    IsolateNameServer.removePortNameMapping("downloader_send_port");
  }

  Future<void> cancel() {
    return FlutterDownloader.cancelAll();
  }
}
