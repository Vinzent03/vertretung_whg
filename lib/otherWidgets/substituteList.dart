import 'package:flutter/material.dart';
import '../substitute/substituteTile.dart';

class SubstituteList extends StatefulWidget {
  final List<dynamic> list;

  SubstituteList({
    Key key,
    this.list = const [],
  }) : super(key: key);

  @override
  SubstituteListState createState() => SubstituteListState();
}

class SubstituteListState extends State<SubstituteList>
    with TickerProviderStateMixin {
  AnimationController _controller;

  Animation<double> _animation;
  @override
  initState() {
    super.initState();
    _controller = AnimationController(
        duration: const Duration(milliseconds: 300), vsync: this, value: 0.1);
    _animation = CurvedAnimation(parent: _controller, curve: Curves.ease);
    _controller.forward();
  }

  Future<void> reAnimate() async {
    _controller.reset();
    await _controller.forward();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.list.isNotEmpty)
      return ScaleTransition(
        scale: _animation,
        child: ListView.builder(
          physics: ScrollPhysics(),
          itemCount: widget.list.length,
          itemBuilder: (context, index) {
            return SubstituteListTile(
              title: widget.list[index]["ver"],
              subjectPrefix: widget.list[index]["subjectPrefix"],
              names: widget.list[index]["name"],
            );
          },
        ),
      );
    else
      return ScaleTransition(
        scale: _animation,
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Icon(
                Icons.business_center,
                color: Colors.blue,
                size: 200,
              ),
              Text(
                "Leider keine Vertretung",
                style: TextStyle(fontSize: 19),
              )
            ],
          ),
        ),
      );
  }

  @override
  dispose() {
    _controller.dispose();
    super.dispose();
  }
}