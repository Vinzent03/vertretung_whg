import 'package:Vertretung/provider/theme.dart';
import 'package:flutter/material.dart';
import 'vertretungTile.dart';
import "package:provider/provider.dart";
import 'dart:math';

class GeneralBlueprint extends StatefulWidget {
  final List<dynamic> list;

  GeneralBlueprint({
    Key key,
    this.list = const [],
  }) : super(key: key);

  @override
  _GeneralBlueprintState createState() => _GeneralBlueprintState();
}

class _GeneralBlueprintState extends State<GeneralBlueprint>
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

  @override
  Widget build(BuildContext context) {
    if (Provider.of<ThemeChanger>(context).getAnimation()) {
      _controller.reset();
      _controller.forward().then((value) =>
          Provider.of<ThemeChanger>(context, listen: false)
              .setAnimation(false));
    }
    if (widget.list.isNotEmpty)
      return ScaleTransition(
        scale: _animation,
        child: ListView.builder(
            physics: ScrollPhysics(),
            shrinkWrap: true,
            itemCount: widget.list.length,
            itemBuilder: (context, index) {

              return VertretungTile(
                title: widget.list[index]["ver"],
                subjectPrefix: widget.list[index]["subjectPrefix"],
                names: widget.list[index]["name"],
              );
            }),
      );
    else
      return ScaleTransition(
        scale: _animation,
        child: Center(
          child: Icon(
            Icons.business_center,
            color: Colors.blue,
            size: 200,
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
