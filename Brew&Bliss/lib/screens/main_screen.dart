import 'package:flutter/material.dart';

import '../widgets/bottom_nav_bar.dart';

import 'home/home_screen.dart';
import 'menu/menu_screen.dart';
import 'order/order_screen.dart';
import 'favorites/favorites_screen.dart';
import 'profile/profile_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int currentIndex = 0;

  // Tabs that have been opened at least once. A tab's screen is only built
  // the first time it is visited (lazy loading) and then kept alive by the
  // IndexedStack, so startup is lighter and state is not lost on switching.
  final Set<int> _visited = {0};

  void _goToTab(int index) {
    setState(() {
      currentIndex = index;
      _visited.add(index);
    });
  }

  late final List<Widget> screens = [
    HomeScreen(onTabSelected: _goToTab),
    const MenuScreen(),
    const OrderScreen(),
    const FavoritesScreen(showBackButton: false),
    const ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: currentIndex,
        children: List.generate(
          screens.length,
          (i) => _visited.contains(i) ? screens[i] : const SizedBox.shrink(),
        ),
      ),
      bottomNavigationBar: BottomNavBar(
        currentIndex: currentIndex,
        onTap: _goToTab,
      ),
    );
  }
}
