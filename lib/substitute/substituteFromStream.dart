import 'package:Vertretung/models/substituteModel.dart';
import 'package:Vertretung/substitute/noSubstitute.dart';
import 'package:Vertretung/substitute/substituteTile.dart';
import 'package:flutter/material.dart';

class SubstituteFromStream extends StatefulWidget {
  final List<SubstituteModel> list;
  final bool isNotUpdated;
  SubstituteFromStream({Key key, this.list, this.isNotUpdated})
      : super(key: key);
  @override
  SubstituteFromStreamState createState() => SubstituteFromStreamState();
}

class SubstituteFromStreamState extends State<SubstituteFromStream>
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
          itemCount: widget.list.length,
          itemBuilder: (BuildContext context, int index) => SubstituteListTile(
            widget.list[index],
          ),
        ),
      );
    else
      return ScaleTransition(
        scale: _animation,
        child: NoSubstitute(widget.isNotUpdated),
      );
  }
}
