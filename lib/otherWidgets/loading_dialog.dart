import 'package:flutter/material.dart';

class LoadingDialog {
  final BuildContext _context;
  BuildContext _dialogContext;

  LoadingDialog(this._context);
  void hide() {
    if (_dialogContext != null)
      Navigator.pop(_dialogContext);
    else
      Future.delayed(Duration(milliseconds: 200))
          .then((value) => Navigator.pop(_dialogContext));
  }

  void show() {
    showDialog(
      context: _context,
      barrierDismissible: false,
      builder: (context) {
        _dialogContext = context;
        return Dialog(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Padding(
                  padding: const EdgeInsets.only(right: 40),
                  child: CircularProgressIndicator(),
                ),
                Expanded(
                    child: Text(
                  "Lade...",
                  style: TextStyle(fontSize: 18),
                )),
              ],
            ),
          ),
        );
      },
    );
  }
}
