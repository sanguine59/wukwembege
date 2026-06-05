import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/profile.dart';
import '../../theme.dart';
import '../../viewmodels/app_viewmodel.dart';
import '../widgets/tab_bar.dart';
import 'organizer/org_home_screen.dart';
import 'shared/inbox_screen.dart';
import 'shared/profile_screen.dart';
import 'vendor/browse_screen.dart';
import 'vendor/vendor_home_screen.dart';

class AppShell extends StatefulWidget {
  const AppShell({super.key});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  int _index = 0;
  final _orgKeys = [GlobalKey<NavigatorState>(), GlobalKey<NavigatorState>(), GlobalKey<NavigatorState>()];
  final _vendorKeys = [GlobalKey<NavigatorState>(), GlobalKey<NavigatorState>(), GlobalKey<NavigatorState>(), GlobalKey<NavigatorState>()];

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<AppViewModel>();
    final isOrg = vm.role == Role.organizer;
    final keys = isOrg ? _orgKeys : _vendorKeys;

    final tabs = isOrg
        ? [
            const TabSpec(id: 'home', label: 'Events', icon: 'home'),
            TabSpec(id: 'inbox', label: 'Inbox', icon: 'inbox', badge: vm.unread),
            const TabSpec(id: 'profile', label: 'Profile', icon: 'user'),
          ]
        : [
            const TabSpec(id: 'home', label: 'Home', icon: 'home'),
            const TabSpec(id: 'browse', label: 'Browse', icon: 'compass'),
            TabSpec(id: 'inbox', label: 'Inbox', icon: 'inbox', badge: vm.unread),
            const TabSpec(id: 'profile', label: 'Profile', icon: 'user'),
          ];

    if (_index >= tabs.length) _index = 0;

    final orgRoots = [
      const OrgHomeScreen(),
      const InboxScreen(),
      const ProfileScreen(),
    ];
    final vendorRoots = [
      VendorHomeScreen(onBrowseAll: () => setState(() => _index = 1)),
      const BrowseScreen(),
      const InboxScreen(),
      const ProfileScreen(),
    ];
    final roots = isOrg ? orgRoots : vendorRoots;

    return Scaffold(
      backgroundColor: AppColors.canvas,
      body: SafeArea(
        bottom: false,
        child: IndexedStack(
          index: _index,
          children: List.generate(roots.length, (i) {
            return Navigator(
              key: keys[i],
              onGenerateRoute: (settings) => MaterialPageRoute(builder: (_) => roots[i]),
            );
          }),
        ),
      ),
      bottomNavigationBar: AppTabBar(
        active: tabs[_index].id,
        onChange: (id) {
          final newIdx = tabs.indexWhere((t) => t.id == id);
          if (newIdx == _index) {
            keys[_index].currentState?.popUntil((r) => r.isFirst);
          } else {
            setState(() => _index = newIdx);
          }
        },
        tabs: tabs,
      ),
    );
  }
}
