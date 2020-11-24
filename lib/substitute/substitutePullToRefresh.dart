import 'package:Vertretung/models/substituteModel.dart';
import 'package:Vertretung/substitute/noSubstitute.dart';
import 'package:flutter/material.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

import 'substituteTile.dart';

class SubstitutePullToRefresh extends StatefulWidget {
  final List<SubstituteModel> list;
  final RefreshController controller;
  final VoidCallback reload;
  final bool isNotUpdated;

  SubstitutePullToRefresh({
    Key key,
    this.list = const [],
    this.controller,
    this.reload,
    this.isNotUpdated,
  }) : super(key: key);

  @override
  SubstitutePullToRefreshState createState() => SubstitutePullToRefreshState();
}

class SubstitutePullToRefreshState extends State<SubstitutePullToRefresh>
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
          child: NoSubstitute(widget.isNotUpdated),
        ),
      );
  }

  @override
  dispose() {
    _controller.dispose();
    super.dispose();
  }
}
