import 'dart:ui';

import 'package:Vertretung/models/substituteModel.dart';
import 'package:flutter/material.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import '../substitute/substituteTile.dart';

class SubstituteList extends StatefulWidget {
  final List<SubstituteModel> list;
  final RefreshController controller;
  final VoidCallback reload;
  final bool isNotUpdated;

  SubstituteList({
    Key key,
    this.list = const [],
    this.controller,
    this.reload,
    this.isNotUpdated,
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
        child: SmartRefresher(
          controller: widget.controller,
          onRefresh: widget.reload,
          child: ListView.builder(
            physics: ScrollPhysics(),
            itemCount: widget.list.length,
            itemBuilder: (context, index) {
              return SubstituteListTile(
                widget.list[index],
              );
            },
          ),
        ),
      );
    else
      return ScaleTransition(
        scale: _animation,
        child: SmartRefresher(
          controller: widget.controller,
          onRefresh: widget.reload,
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
                  widget.isNotUpdated
                      ? "Leider keine Vertretung, aber der Plan hat noch nicht aktualisiert."
                      : "Leider keine Vertretung",
                  style: TextStyle(fontSize: 19),
                  textAlign: TextAlign.center,
                )
              ],
            ),
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
