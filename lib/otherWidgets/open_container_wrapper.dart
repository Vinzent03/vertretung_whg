import 'package:animations/animations.dart';
import "package:flutter/material.dart";

class OpenContainerWrapper extends StatelessWidget {
  final Function openBuilder;
  final Function closedBuilder;
  final Function onClosed;
  final bool tappable;
  OpenContainerWrapper({
    Key key,
    this.openBuilder(
      BuildContext context,
      void Function({Object returnValue}) action,
    ),
    this.closedBuilder(BuildContext context, Function action),
    this.onClosed,
    this.tappable = true,
  }) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return OpenContainer(
      tappable: tappable,
      closedColor: Theme.of(context).brightness == Brightness.light
          ? Colors.white
          : Theme.of(context).cardTheme.color,
      openColor: Theme.of(context).scaffoldBackgroundColor,
      closedElevation: 0,
      transitionType: ContainerTransitionType.fade,
      closedShape: Theme.of(context).cardTheme.shape,
      onClosed: onClosed,
      openBuilder: openBuilder,
      closedBuilder: closedBuilder,
    );
  }
}
