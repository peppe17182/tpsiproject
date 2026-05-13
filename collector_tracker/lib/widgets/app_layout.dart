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
    final isExtended = width > 1080;
    final cs = Theme.of(context).colorScheme;

    final currentPath = GoRouterState.of(context).matchedLocation;

    int selectedIndex() {
      if (currentPath.startsWith('/items')) return 2;
      if (currentPath.startsWith('/categories')) return 1;
      if (currentPath.startsWith('/stats')) return 3;
      if (currentPath.startsWith('/settings')) return 4;
      return 0;
    }

    final destinations = const [
      NavigationRailDestination(
        icon: Icon(Icons.space_dashboard_outlined),
        selectedIcon: Icon(Icons.space_dashboard),
        label: Text('Dashboard'),
      ),
      NavigationRailDestination(
        icon: Icon(Icons.folder_outlined),
        selectedIcon: Icon(Icons.folder),
        label: Text('Categories'),
      ),
      NavigationRailDestination(
        icon: Icon(Icons.grid_view_outlined),
        selectedIcon: Icon(Icons.grid_view),
        label: Text('Inventory'),
      ),
      NavigationRailDestination(
        icon: Icon(Icons.insights_outlined),
        selectedIcon: Icon(Icons.insights),
        label: Text('Analytics'),
      ),
    ];

    void onTap(int index) {
      switch (index) {
        case 0:
          context.go('/');
        case 1:
          context.go('/categories');
        case 2:
          context.go('/items');
        case 3:
          context.go('/stats');
        case 4:
          context.go('/settings');
      }
    }

    // ─── Desktop Navigation Rail ───
    Widget desktopNav() {
      return Container(
        margin: const EdgeInsets.all(12),
        child: GlassPanel(
          padding: EdgeInsets.zero,
          borderRadius: 24,
          child: SizedBox(
            width: isExtended ? 220 : 72,
            child: Column(
              children: [
                // Logo
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 28),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [cs.primary, cs.secondary],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(14),
                          boxShadow: [
                            BoxShadow(
                              color: cs.primary.withValues(alpha: 0.3),
                              blurRadius: 16,
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.layers_rounded,
                          color: Colors.white,
                          size: 22,
                        ),
                      ),
                      if (isExtended) ...[
                        const SizedBox(width: 14),
                        Text(
                          'Collectiv',
                          style: Theme.of(context).textTheme.titleLarge
                              ?.copyWith(
                                fontWeight: FontWeight.bold,
                                letterSpacing: -0.5,
                              ),
                        ),
                      ],
                    ],
                  ),
                ),

                // Divider
                Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: isExtended ? 20 : 16,
                  ),
                  child: Divider(
                    color: cs.outline.withValues(alpha: 0.15),
                    height: 1,
                  ),
                ),

                const SizedBox(height: 8),

                // Navigation Items
                ...List.generate(destinations.length, (i) {
                  final isSelected = selectedIndex() == i;
                  final dest = destinations[i];
                  return Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: isExtended ? 12 : 8,
                      vertical: 2,
                    ),
                    child: Material(
                      color: Colors.transparent,
                      borderRadius: BorderRadius.circular(14),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(14),
                        onTap: () => onTap(i),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: EdgeInsets.symmetric(
                            vertical: 12,
                            horizontal: isExtended ? 16 : 0,
                          ),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(14),
                            color: isSelected
                                ? cs.primary.withValues(alpha: 0.12)
                                : Colors.transparent,
                          ),
                          child: Row(
                            mainAxisAlignment: isExtended
                                ? MainAxisAlignment.start
                                : MainAxisAlignment.center,
                            children: [
                              Icon(
                                isSelected
                                    ? (dest.selectedIcon as Icon).icon
                                    : (dest.icon as Icon).icon,
                                color: isSelected
                                    ? cs.primary
                                    : cs.onSurfaceVariant,
                                size: 22,
                              ),
                              if (isExtended) ...[
                                const SizedBox(width: 14),
                                Text(
                                  (dest.label as Text).data!,
                                  style: TextStyle(
                                    color: isSelected
                                        ? cs.primary
                                        : cs.onSurfaceVariant,
                                    fontWeight: isSelected
                                        ? FontWeight.w600
                                        : FontWeight.w400,
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                }),

                const Spacer(),

                // Settings Button
                Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: isExtended ? 12 : 8,
                    vertical: 2,
                  ),
                  child: Material(
                    color: Colors.transparent,
                    borderRadius: BorderRadius.circular(14),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(14),
                      onTap: () => context.go('/settings'),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: EdgeInsets.symmetric(
                          vertical: 12,
                          horizontal: isExtended ? 16 : 0,
                        ),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(14),
                          color: selectedIndex() == 4
                              ? cs.primary.withValues(alpha: 0.12)
                              : Colors.transparent,
                        ),
                        child: Row(
                          mainAxisAlignment: isExtended
                              ? MainAxisAlignment.start
                              : MainAxisAlignment.center,
                          children: [
                            Icon(
                              selectedIndex() == 4
                                  ? Icons.settings
                                  : Icons.settings_outlined,
                              color: selectedIndex() == 4
                                  ? cs.primary
                                  : cs.onSurfaceVariant,
                              size: 22,
                            ),
                            if (isExtended) ...[
                              const SizedBox(width: 14),
                              Text(
                                'Settings',
                                style: TextStyle(
                                  color: selectedIndex() == 4
                                      ? cs.primary
                                      : cs.onSurfaceVariant,
                                  fontWeight: selectedIndex() == 4
                                      ? FontWeight.w600
                                      : FontWeight.w400,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                  ),
                ),

                // Logout Button
                Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: isExtended ? 12 : 8,
                    vertical: 2,
                  ),
                  child: Material(
                    color: Colors.transparent,
                    borderRadius: BorderRadius.circular(14),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(14),
                      onTap: () => context.read<AuthProvider>().logout(),
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          vertical: 12,
                          horizontal: isExtended ? 16 : 0,
                        ),
                        child: Row(
                          mainAxisAlignment: isExtended
                              ? MainAxisAlignment.start
                              : MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.logout_rounded,
                              color: cs.error.withValues(alpha: 0.8),
                              size: 22,
                            ),
                            if (isExtended) ...[
                              const SizedBox(width: 14),
                              Text(
                                'Sign Out',
                                style: TextStyle(
                                  color: cs.error.withValues(alpha: 0.8),
                                  fontWeight: FontWeight.w500,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      );
    }

    // ─── Mobile Bottom Nav ───
    Widget mobileNav() {
      return Positioned(
        bottom: 12,
        left: 12,
        right: 12,
        child: GlassPanel(
          padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
          borderRadius: 28,
          blur: 32,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              ...List.generate(destinations.length, (i) {
                final isSelected = selectedIndex() == i;
                final dest = destinations[i];
                return InkWell(
                  borderRadius: BorderRadius.circular(16),
                  onTap: () => onTap(i),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(
                      vertical: 8,
                      horizontal: 16,
                    ),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      color: isSelected
                          ? cs.primary.withValues(alpha: 0.12)
                          : Colors.transparent,
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          isSelected
                              ? (dest.selectedIcon as Icon).icon
                              : (dest.icon as Icon).icon,
                          color: isSelected ? cs.primary : cs.onSurfaceVariant,
                          size: 22,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          (dest.label as Text).data!,
                          style: TextStyle(
                            color: isSelected
                                ? cs.primary
                                : cs.onSurfaceVariant,
                            fontSize: 10,
                            fontWeight: isSelected
                                ? FontWeight.w600
                                : FontWeight.w400,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }),
              // Settings icon on mobile
              InkWell(
                borderRadius: BorderRadius.circular(16),
                onTap: () => context.go('/settings'),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(
                    vertical: 8,
                    horizontal: 16,
                  ),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    color: selectedIndex() == 4
                        ? cs.primary.withValues(alpha: 0.12)
                        : Colors.transparent,
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        selectedIndex() == 4
                            ? Icons.settings
                            : Icons.settings_outlined,
                        color: selectedIndex() == 4
                            ? cs.primary
                            : cs.onSurfaceVariant,
                        size: 22,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Settings',
                        style: TextStyle(
                          color: selectedIndex() == 4
                              ? cs.primary
                              : cs.onSurfaceVariant,
                          fontSize: 10,
                          fontWeight: selectedIndex() == 4
                              ? FontWeight.w600
                              : FontWeight.w400,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    // ─── Background ───
    Widget background() {
      return Container(
        decoration: BoxDecoration(
          color: cs.surface,
          gradient: RadialGradient(
            center: const Alignment(-0.6, -0.8),
            radius: 1.8,
            colors: [cs.primary.withValues(alpha: 0.07), cs.surface],
          ),
        ),
        child: CustomPaint(
          painter: _SubtleGridPainter(cs.outline.withValues(alpha: 0.04)),
          child: const SizedBox.expand(),
        ),
      );
    }

    return Scaffold(
      backgroundColor: cs.surface,
      body: Stack(
        fit: StackFit.expand,
        children: [
          background(),
          SafeArea(
            bottom: false,
            child: isWide
                ? Row(
                    children: [
                      desktopNav(),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.only(
                            top: 12,
                            right: 12,
                            bottom: 12,
                          ),
                          child: child,
                        ),
                      ),
                    ],
                  )
                : Stack(
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(bottom: 80),
                        child: child,
                      ),
                      mobileNav(),
                    ],
                  ),
          ),
        ],
      ),
    );
  }
}

/// Paints a subtle dot grid for depth.
class _SubtleGridPainter extends CustomPainter {
  final Color color;
  _SubtleGridPainter(this.color);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = color;
    const spacing = 32.0;
    for (double x = 0; x < size.width; x += spacing) {
      for (double y = 0; y < size.height; y += spacing) {
        canvas.drawCircle(Offset(x, y), 0.6, paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
