import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../providers/auth_provider.dart';

import 'glass_panel.dart';

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
        label: Text('Dashboard'),
      ),
      const NavigationRailDestination(
        icon: Icon(Icons.category_outlined),
        selectedIcon: Icon(Icons.category),
        label: Text('Categories'),
      ),
      const NavigationRailDestination(
        icon: Icon(Icons.list_alt_outlined),
        selectedIcon: Icon(Icons.list_alt),
        label: Text('Inventory'),
      ),
      const NavigationRailDestination(
        icon: Icon(Icons.bar_chart_outlined),
        selectedIcon: Icon(Icons.bar_chart),
        label: Text('Nerd Stats'),
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

    Widget buildDesktopNav() {
      final colorScheme = Theme.of(context).colorScheme;
      return Container(
        color: colorScheme.background, // fallback for lowest
        child: NavigationRail(
          extended: width > 1000,
          backgroundColor: Colors.transparent,
          destinations: destinations,
          selectedIndex: getSelectedIndex(),
          onDestinationSelected: onDestinationSelected,
          unselectedIconTheme: IconThemeData(color: colorScheme.outline),
          selectedIconTheme: IconThemeData(color: colorScheme.primary),
          unselectedLabelTextStyle: TextStyle(color: colorScheme.outline),
          selectedLabelTextStyle: TextStyle(color: colorScheme.primary, fontWeight: FontWeight.bold),
          leading: Padding(
            padding: const EdgeInsets.symmetric(vertical: 24.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.layers, color: colorScheme.primary, size: 32),
                if (width > 1000) ...[
                  const SizedBox(width: 12),
                  Text(
                    'Collectiv',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          color: colorScheme.onSurface,
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ],
              ],
            ),
          ),
          trailing: Expanded(
            child: Align(
              alignment: Alignment.bottomCenter,
              child: Padding(
                padding: const EdgeInsets.only(bottom: 24.0),
                child: IconButton(
                  icon: Icon(Icons.logout, color: colorScheme.error),
                  onPressed: () {
                    context.read<AuthProvider>().logout();
                  },
                  tooltip: 'Logout',
                ),
              ),
            ),
          ),
        ),
      );
    }

    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.background,
      appBar: isWide
          ? null
          : AppBar(
              backgroundColor: colorScheme.background,
              title: const Text('Collectiv'),
              actions: [
                IconButton(
                  icon: Icon(Icons.logout, color: colorScheme.error),
                  onPressed: () => context.read<AuthProvider>().logout(),
                ),
              ],
            ),
      body: isWide
          ? Row(
              children: [
                buildDesktopNav(),
                VerticalDivider(thickness: 1, width: 1, color: colorScheme.outlineVariant),
                Expanded(child: child),
              ],
            )
          : Stack(
              children: [
                child,
                Positioned(
                  bottom: 16,
                  left: 16,
                  right: 16,
                  child: GlassPanel(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    borderRadius: 32,
                    child: BottomNavigationBar(
                      elevation: 0,
                      backgroundColor: Colors.transparent,
                      type: BottomNavigationBarType.fixed,
                      currentIndex: getSelectedIndex(),
                      onTap: onDestinationSelected,
                      selectedItemColor: colorScheme.primary,
                      unselectedItemColor: colorScheme.outline,
                      showUnselectedLabels: true,
                      items: destinations
                          .map((d) => BottomNavigationBarItem(
                                icon: d.icon,
                                activeIcon: d.selectedIcon,
                                label: (d.label as Text).data,
                              ))
                          .toList(),
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}
