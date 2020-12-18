import 'package:Vertretung/models/substitute_tile_model.dart';
import 'package:Vertretung/provider/user_data.dart';
import 'package:Vertretung/substitute/no_substitute.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

import 'substitute_tile.dart';

class SubstitutePullToRefresh extends StatefulWidget {
  final List<SubstituteModel> list;
  final RefreshController controller;
  final VoidCallback reload;

  SubstitutePullToRefresh({
    Key key,
    this.list = const [],
    this.controller,
    this.reload,
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
          child: NoSubstitute(widget.list.isEmpty &&
              context.watch<UserData>().lastChange.substring(7) == "00:09"),
        ),
      );
  }

  @override
  dispose() {
    _controller.dispose();
    super.dispose();
  }
}
