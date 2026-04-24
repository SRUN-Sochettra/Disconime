import 'dart:ui';
import 'package:flutter/material.dart';
import 'home_screen.dart';
import 'search_screen.dart';
import 'about_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;
  final List<Widget> _screens = [
    const HomeScreen(),
    const SearchScreen(),
    const AboutScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: ClipRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: BottomNavigationBar(
            currentIndex: _currentIndex,
            onTap: (index) => setState(() => _currentIndex = index),
            items: const [
              BottomNavigationBarItem(icon: Icon(Icons.terminal), label: 'SYS.HOME'),
              BottomNavigationBarItem(icon: Icon(Icons.search), label: 'SYS.SEARCH'),
              BottomNavigationBarItem(icon: Icon(Icons.info_outline), label: 'SYS.ABOUT'),
            ],
          ),
        ),
      ),
    );
  }
}