import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/favourites_provider.dart';
import 'home_screen.dart';
import 'profile_screen.dart';
import 'saved_screen.dart';

class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _currentIndex = 0; // 0 = Home, 1 = Saved, 2 = Profile

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // IndexedStack keeps all 3 screens alive, so Home does not reload
      // when you switch tabs.
      body: IndexedStack(
        index: _currentIndex,
        children: [
          const HomeScreen(),
          SavedScreen(
            onBrowse: () {
              setState(() {
                _currentIndex = 0; // go to Home tab
              });
            },
          ),
          const ProfileScreen(),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (index) {
          // Selected tab is local UI state, so setState is enough.
          setState(() {
            _currentIndex = index;
          });
        },
        destinations: [
          const NavigationDestination(
            icon: Icon(Icons.home_outlined),
            label: 'Home',
          ),
          NavigationDestination(
            // Consumer: only this badge rebuilds when favourites change, so
            // the saved count is visible from every tab (including Home).
            icon: Consumer<Favourites>(
              builder: (context, favourites, child) {
                return Badge(
                  isLabelVisible: favourites.count > 0,
                  label: Text('${favourites.count}'),
                  child: child,
                );
              },
              child: const Icon(Icons.bookmark_border),
            ),
            label: 'Saved',
          ),
          const NavigationDestination(
            icon: Icon(Icons.person_outline),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}
