import 'package:Vertretung/provider/theme.dart';
import 'package:flutter/material.dart';
import 'vertretungTile.dart';
import "package:provider/provider.dart";

class GeneralBlueprint extends StatefulWidget {
  final List<List<String>> list;
  final List<Map<String, String>> friendsList;
  final bool isFriendList;
  GeneralBlueprint({
    Key key,
    this.isFriendList = false,
    this.friendsList = const[],
    this.list= const[[],[]],
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
      _controller.forward().then((value) => Provider.of<ThemeChanger>(context, listen: false)
          .setAnimation(false));
    }
    if (! (widget.list[0].isEmpty && widget.friendsList.isEmpty))
      return ScaleTransition(
        scale: _animation,
        child: !widget.isFriendList? ListView.builder(
            physics: ScrollPhysics(),
            shrinkWrap: true,
            itemCount: widget.list[0].length,
            itemBuilder: (context, index) {
              return VertretungTile(
                faecher: widget.list[0][index],
                names: widget.list[1][index],
              );
            }): 
            ListView.builder(
                shrinkWrap: true,
                itemCount: widget.friendsList.length,
                physics: ScrollPhysics(),
                itemBuilder: (context, index) {
                  return Card(
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.all(Radius.circular(15))),
                    color: Colors.blue[700],
                    child: ListTile(
                      dense: true,
                      leading: CircleAvatar(
                        child: Text(widget.friendsList[index]["name"].substring(0, 2)),
                        backgroundColor: Colors.white,
                      ),
                      title: Text(widget.friendsList[index]["ver"]),
                      subtitle: Text(widget.friendsList[index]["name"]),
                    ),
                  );
                },
              ),
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
