import 'package:Vertretung/friends/friendsPage.dart';
import 'package:Vertretung/provider/theme.dart';
import 'package:provider/provider.dart';
import 'package:Vertretung/pages/newsPage.dart';
import 'package:Vertretung/pages/VertretungsPage.dart';
import 'package:flutter/material.dart';
import 'package:Vertretung/logic/functionsForMain.dart';
import 'package:google_nav_bar/google_nav_bar.dart';

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  Widget usedPage = Vertretung();

  int currentIndex = 0;
  @override
  void initState() {
    showUpdateDialog(context);
    super.initState();
  }

  final List<Widget> pages = [
    Vertretung(),
    Friends(),
    NewsPage(),
  ];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        //damit beim page wechsel nichte alles neugeladen werden muss
        children: pages,
        index: currentIndex,
      ),
      bottomNavigationBar: Container(
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 8),
            child: GNav(
                gap: 0,
                //activeColor: Colors.pink,
                iconSize: 24,
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 5),
                duration: Duration(milliseconds: 300),
                tabBackgroundColor: Provider.of<ThemeChanger>(context).getIsDark() ? Colors.grey[900]: Colors.blue[700],
                color: Provider.of<ThemeChanger>(context).getIsDark() ? Colors.white: Colors.black,
                tabs: [
                  GButton(
                    icon: Icons.calendar_view_day,
                    text: 'Vertretung',
                  ),
                  GButton(
                    icon: Icons.group,
                    text: 'Freunde',
                  ),
                  GButton(
                    icon: Icons.inbox,
                    text: 'Nachrichten',
                  ),
                ],
                selectedIndex: currentIndex,
                onTabChange: (index) {
                  setState(() {
                    currentIndex = index;
                  });
                }),
          ),
        ),
      ),
      // BottomNavigationBar(
      //   elevation: 10,
      //   currentIndex: currentIndex,
      //   backgroundColor: Provider.of<ThemeChanger>(context).getIsDark()
      //       ? Colors.black
      //       : Colors.white,
      //   items: [
      //     BottomNavigationBarItem(
      //       icon: Icon(Icons.calendar_today),
      //       title: Text("Vertretung"),
      //     ),
      //     BottomNavigationBarItem(
      //       icon: Icon(Icons.group),
      //       title: Text("Freunde"),
      //     ),
      //     BottomNavigationBarItem(
      //       icon: Icon(Icons.inbox),
      //       title: Text("Nachrichten"),
      //     ),
      //   ],
      //   onTap: (index) {
      //     setState(() {
      //       currentIndex = index;
      //     });
      //   },
      // ),
    );
  }
}
