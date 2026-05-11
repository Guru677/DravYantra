import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../core/theme.dart';

class ScaffoldWithNav extends StatelessWidget {
  final Widget child;

  const ScaffoldWithNav({super.key, required this.child});

  int _calculateSelectedIndex(BuildContext context) {
    final String location = GoRouterState.of(context).uri.toString();
    if (location.startsWith('/dashboard')) return 0;
    if (location.startsWith('/live-tracking')) return 1;
    if (location.startsWith('/vehicles')) return 2;
    if (location.startsWith('/fuel')) return 3;
    if (location.startsWith('/alerts')) return 4;
    if (location.startsWith('/settings')) return 5;
    return 0; // Default
  }

  void _onItemTapped(int index, BuildContext context) {
    switch (index) {
      case 0: context.go('/dashboard'); break;
      case 1: context.go('/live-tracking'); break;
      case 2: context.go('/vehicles'); break;
      case 3: context.go('/fuel'); break;
      case 4: context.go('/alerts'); break;
      case 5: context.go('/settings'); break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final bool isSmallScreen = constraints.maxWidth < 800;

        return Scaffold(
          appBar: AppBar(
            title: const Text('DravYantra', style: TextStyle(fontWeight: FontWeight.bold)),
            leading: isSmallScreen ? Builder(
              builder: (context) => IconButton(
                icon: const Icon(LucideIcons.menu),
                onPressed: () => Scaffold.of(context).openDrawer(),
              ),
            ) : null,
            actions: [
              IconButton(
                icon: const Icon(LucideIcons.bell), 
                onPressed: () => context.go('/alerts'),
                tooltip: 'Alerts',
              ),
              const SizedBox(width: 16),
            ],
          ),
          drawer: isSmallScreen ? const _AppDrawer() : null,
          body: Row(
            children: [
              if (!isSmallScreen)
                NavigationRail(
                  selectedIndex: _calculateSelectedIndex(context),
                  onDestinationSelected: (index) => _onItemTapped(index, context),
                  labelType: NavigationRailLabelType.all,
                  selectedIconTheme: const IconThemeData(color: AppTheme.primaryBlue),
                  selectedLabelTextStyle: const TextStyle(color: AppTheme.primaryBlue, fontWeight: FontWeight.bold),
                  unselectedIconTheme: const IconThemeData(color: AppTheme.textSecondary),
                  unselectedLabelTextStyle: const TextStyle(color: AppTheme.textSecondary),
                  destinations: const [
                    NavigationRailDestination(icon: Icon(LucideIcons.layoutDashboard), label: Text('Dashboard')),
                    NavigationRailDestination(icon: Icon(LucideIcons.map), label: Text('Tracking')),
                    NavigationRailDestination(icon: Icon(LucideIcons.truck), label: Text('Vehicles')),
                    NavigationRailDestination(icon: Icon(LucideIcons.fuel), label: Text('Fuel')),
                    NavigationRailDestination(icon: Icon(LucideIcons.alertTriangle), label: Text('Alerts')),
                    NavigationRailDestination(icon: Icon(LucideIcons.settings), label: Text('Settings')),
                  ],
                ),
              if (!isSmallScreen) const VerticalDivider(thickness: 1, width: 1),
              Expanded(
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 100),
                  transitionBuilder: (Widget child, Animation<double> animation) {
                    return FadeTransition(opacity: animation, child: child);
                  },
                  child: KeyedSubtree(
                    key: ValueKey<int>(_calculateSelectedIndex(context)),
                    child: child,
                  ),
                ),
              ),
            ],
          ),
          bottomNavigationBar: isSmallScreen
              ? BottomNavigationBar(
                  currentIndex: _calculateSelectedIndex(context) > 4 ? 4 : _calculateSelectedIndex(context), // Limit to 5 items for bottom nav
                  onTap: (index) {
                     if (index == 4) {
                       context.go('/settings'); 
                     } else {
                       _onItemTapped(index, context);
                     }
                  },
                  type: BottomNavigationBarType.fixed,
                  selectedItemColor: AppTheme.primaryBlue,
                  unselectedItemColor: AppTheme.textSecondary,
                  items: [
                    const BottomNavigationBarItem(icon: Icon(LucideIcons.layoutDashboard), label: 'Dashboard'),
                    const BottomNavigationBarItem(icon: Icon(LucideIcons.map), label: 'Tracking'),
                    const BottomNavigationBarItem(icon: Icon(LucideIcons.truck), label: 'Vehicles'),
                    const BottomNavigationBarItem(icon: Icon(LucideIcons.fuel), label: 'Fuel'),
                    BottomNavigationBarItem(
                      icon: Container(
                        padding: const EdgeInsets.all(2),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: _calculateSelectedIndex(context) >= 4 ? AppTheme.primaryBlue : Colors.transparent, 
                            width: 2
                          ),
                        ),
                        child: CircleAvatar(
                          radius: 10,
                          backgroundColor: AppTheme.primaryBlue,
                          child: Text(
                            (FirebaseAuth.instance.currentUser?.email?.substring(0, 1).toUpperCase() ?? 'D'), 
                            style: const TextStyle(color: Colors.white, fontSize: 8, fontWeight: FontWeight.bold)
                          ),
                        ),
                      ), 
                      label: 'Profile'
                    ),
                  ],
                )
              : null,
        );
      },
    );
  }
}

class _AppDrawer extends StatelessWidget {
  const _AppDrawer();

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          const DrawerHeader(
            decoration: BoxDecoration(color: AppTheme.primaryBlue),
            child: Text(
              'DravYantra\nFleet Management',
              style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ),
          const _DrawerItem(icon: LucideIcons.layoutDashboard, title: 'Dashboard', path: '/dashboard'),
          const _DrawerItem(icon: LucideIcons.map, title: 'Live Tracking', path: '/live-tracking'),
          const _DrawerItem(icon: LucideIcons.truck, title: 'Vehicles', path: '/vehicles'),
          const _DrawerItem(icon: LucideIcons.users, title: 'Drivers', path: '/drivers'),
          const _DrawerItem(icon: LucideIcons.mapPin, title: 'Trips', path: '/trips'),
          const _DrawerItem(icon: LucideIcons.fuel, title: 'Fuel Management', path: '/fuel'),
          const _DrawerItem(icon: LucideIcons.alertTriangle, title: 'Alerts', path: '/alerts'),
          const _DrawerItem(icon: LucideIcons.barChart2, title: 'Analytics', path: '/analytics'),
          const _DrawerItem(icon: LucideIcons.fileText, title: 'Reports', path: '/reports'),
          const _DrawerItem(icon: LucideIcons.settings, title: 'Settings', path: '/settings'),
          const Divider(),
          ListTile(
            leading: const Icon(LucideIcons.logOut, color: AppTheme.danger),
            title: const Text('Logout', style: TextStyle(color: AppTheme.danger, fontWeight: FontWeight.w600)),
            onTap: () async {
              Navigator.pop(context); // Close drawer
              await FirebaseAuth.instance.signOut();
              if (context.mounted) context.go('/login');
            },
          ),
        ],
      ),
    );
  }
}

class _DrawerItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String path;

  const _DrawerItem({required this.icon, required this.title, required this.path});

  @override
  Widget build(BuildContext context) {
    final bool isSelected = GoRouterState.of(context).uri.toString().startsWith(path);
    return ListTile(
      leading: Icon(icon, color: isSelected ? AppTheme.primaryBlue : AppTheme.textSecondary),
      title: Text(title, style: TextStyle(
        color: isSelected ? AppTheme.primaryBlue : AppTheme.textPrimary,
        fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
      )),
      selected: isSelected,
      onTap: () {
        Navigator.pop(context); // Close drawer
        context.go(path);
      },
    );
  }
}

