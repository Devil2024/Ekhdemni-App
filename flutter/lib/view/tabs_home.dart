import 'package:flutter/material.dart';
import 'package:my_app/view/chatbot_screen.dart';
import 'package:my_app/view/home_screen.dart';

class TabsHome extends StatefulWidget {
  const TabsHome({super.key});

  @override
  _TabsHomeState createState() => _TabsHomeState();
}

class _TabsHomeState extends State<TabsHome> {
  int _selectedIndex = 0;
  static final List<Widget> tabs = <Widget>[
    const HomeBodyScreen(),
    ChatbotScreen()
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.chat),
            label: 'Chat',
          ),
        ],
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        selectedItemColor: Color.fromARGB(255, 3, 9, 96),
      ),
      body: tabs[_selectedIndex],
    );
  }
}
