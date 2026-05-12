import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../providers/auth_provider.dart';

class AppLayout extends StatelessWidget {
  final Widget child;

  const AppLayout({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final isWide = width > 800;
    
    final currentPath = GoRouterState.of(context).matchedLocation;
    
    int getSelectedIndex() {
      if (currentPath.startsWith('/items')) return 2;
      if (currentPath.startsWith('/categories')) return 1;
      if (currentPath.startsWith('/stats')) return 3;
      return 0; // home
    }

    final destinations = [
      const NavigationRailDestination(
        icon: Icon(Icons.home_outlined),
        selectedIcon: Icon(Icons.home),
        label: Text('Home'),
      ),
      const NavigationRailDestination(
        icon: Icon(Icons.category_outlined),
        selectedIcon: Icon(Icons.category),
        label: Text('Categories'),
      ),
      const NavigationRailDestination(
        icon: Icon(Icons.list_alt_outlined),
        selectedIcon: Icon(Icons.list_alt),
        label: Text('Items'),
      ),
      const NavigationRailDestination(
        icon: Icon(Icons.bar_chart_outlined),
        selectedIcon: Icon(Icons.bar_chart),
        label: Text('Stats'),
      ),
    ];

    void onDestinationSelected(int index) {
      switch (index) {
        case 0:
          context.go('/');
          break;
        case 1:
          context.go('/categories');
          break;
        case 2:
          context.go('/items');
          break;
        case 3:
          context.go('/stats');
          break;
      }
    }

    return Scaffold(
      appBar: isWide ? null : AppBar(
        title: const Text('Collector Tracker'),
      ),
      drawer: isWide ? null : Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primaryContainer,
              ),
              child: const Text('Collector Tracker', style: TextStyle(fontSize: 24)),
            ),
            ListTile(
              leading: const Icon(Icons.home),
              title: const Text('Home'),
              selected: getSelectedIndex() == 0,
              onTap: () {
                Navigator.pop(context);
                onDestinationSelected(0);
              },
            ),
            ListTile(
              leading: const Icon(Icons.category),
              title: const Text('Categories'),
              selected: getSelectedIndex() == 1,
              onTap: () {
                Navigator.pop(context);
                onDestinationSelected(1);
              },
            ),
            ListTile(
              leading: const Icon(Icons.list_alt),
              title: const Text('Items'),
              selected: getSelectedIndex() == 2,
              onTap: () {
                Navigator.pop(context);
                onDestinationSelected(2);
              },
            ),
            ListTile(
              leading: const Icon(Icons.bar_chart),
              title: const Text('Stats'),
              selected: getSelectedIndex() == 3,
              onTap: () {
                Navigator.pop(context);
                onDestinationSelected(3);
              },
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.logout),
              title: const Text('Logout'),
              onTap: () {
                context.read<AuthProvider>().logout();
              },
            ),
          ],
        ),
      ),
      body: Row(
        children: [
          if (isWide)
            NavigationRail(
              extended: width > 1000,
              destinations: destinations,
              selectedIndex: getSelectedIndex(),
              onDestinationSelected: onDestinationSelected,
              trailing: Expanded(
                child: Align(
                  alignment: Alignment.bottomCenter,
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 16.0),
                    child: IconButton(
                      icon: const Icon(Icons.logout),
                      onPressed: () {
                        context.read<AuthProvider>().logout();
                      },
                      tooltip: 'Logout',
                    ),
                  ),
                ),
              ),
            ),
          if (isWide) const VerticalDivider(thickness: 1, width: 1),
          Expanded(child: child),
        ],
      ),
    );
  }
}
