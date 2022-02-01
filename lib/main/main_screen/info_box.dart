import 'package:flutter/material.dart';

class InfoBox extends StatefulWidget {
  final List list;
  final String title;
  final Function onPressed;
  final bool loaded;

  const InfoBox({
    Key key,
    @required this.list,
    @required this.title,
    @required this.onPressed,
    @required this.loaded,
  }) : super(key: key);

  @override
  _InfoBoxState createState() => _InfoBoxState();
}

class _InfoBoxState extends State<InfoBox> {
  @override
  Widget build(BuildContext context) {
    return Flexible(
      child: Card(
        child: GestureDetector(
          onTap: widget.onPressed,
          behavior: HitTestBehavior.translucent,
          child: Container(
            alignment: Alignment.center,
            child: Column(
              children: [
                AnimatedSwitcher(
                  duration: Duration(milliseconds: 500),
                  child: widget.loaded
                      ? Text(
                          widget.list.length.toString(),
                          key: ValueKey(widget.list.length),
                          style: TextStyle(
                              fontSize: 50,
                              color: Theme.of(context).primaryColor,
                              fontWeight: FontWeight.w600),
                        )
                      : Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: CircularProgressIndicator(),
                        ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 10),
                  child: Text(
                    widget.title,
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 20),
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
