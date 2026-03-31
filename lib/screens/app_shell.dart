import 'package:flutter/material.dart';
import '../services/cart_service.dart';
import '../utils/constants.dart';
import '../widgets/tab_navigator.dart';
import 'new_homepage.dart';
import 'chat_screen.dart';
import 'cart_screen.dart';
import 'profile_screen.dart';

class AppShell extends StatefulWidget {
  const AppShell({super.key});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  int _currentIndex = homeTab;

  final List<GlobalKey<NavigatorState>> _navigatorKeys = List.generate(
    tabCount,
    (_) => GlobalKey<NavigatorState>(),
  );

  final _screens = const [NewHomepage(), ChatScreen(), CartScreen(), ProfileScreen()];

  void _onTabTapped(int index) {
    if (index == _currentIndex) {
      // Pop to root on re-tap
      _navigatorKeys[index].currentState?.popUntil((route) => route.isFirst);
    } else {
      setState(() => _currentIndex = index);
    }
  }

  Future<bool> _onWillPop() async {
    final navigator = _navigatorKeys[_currentIndex].currentState;
    if (navigator != null && navigator.canPop()) {
      navigator.pop();
      return false;
    }
    if (_currentIndex != homeTab) {
      setState(() => _currentIndex = homeTab);
      return false;
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) async {
        if (didPop) return;
        final shouldPop = await _onWillPop();
        if (shouldPop && context.mounted) Navigator.of(context).maybePop();
      },
      child: Scaffold(
        body: IndexedStack(
          index: _currentIndex,
          children: List.generate(tabCount, (i) => TabNavigator(
            navigatorKey: _navigatorKeys[i],
            child: _screens[i],
          )),
        ),
        bottomNavigationBar: ListenableBuilder(
          listenable: CartService(),
          builder: (context, _) => NavigationBar(
            selectedIndex: _currentIndex,
            onDestinationSelected: _onTabTapped,
            destinations: [
              const NavigationDestination(icon: Icon(Icons.home_outlined), selectedIcon: Icon(Icons.home), label: 'Home'),
              const NavigationDestination(icon: Icon(Icons.chat_bubble_outline), selectedIcon: Icon(Icons.chat_bubble), label: 'Chat'),
              NavigationDestination(
                icon: Badge.count(count: CartService().totalCount, isLabelVisible: CartService().totalCount > 0, child: const Icon(Icons.shopping_cart_outlined)),
                selectedIcon: Badge.count(count: CartService().totalCount, isLabelVisible: CartService().totalCount > 0, child: const Icon(Icons.shopping_cart)),
                label: 'Cart',
              ),
              const NavigationDestination(icon: Icon(Icons.person_outline), selectedIcon: Icon(Icons.person), label: 'Profile'),
            ],
          ),
        ),
      ),
    );
  }
}
