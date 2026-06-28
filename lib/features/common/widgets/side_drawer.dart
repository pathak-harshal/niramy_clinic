// lib/features/common/widgets/side_drawer.dart
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../app/router/route_names.dart';
import '../../../app/theme/app_text_styles.dart';

class SideDrawer extends StatelessWidget {
  const SideDrawer({super.key});

  Widget _buildHeader(BuildContext context, User? user) {
    final theme = Theme.of(context);
    final email = user?.email ?? 'Guest';
    return DrawerHeader(
      decoration: BoxDecoration(color: theme.colorScheme.primary),
      margin: EdgeInsets.zero,
      child: Row(
        children: [
          CircleAvatar(
            radius: 28,
            backgroundColor: theme.colorScheme.onPrimary,
            child: Icon(
              Icons.person,
              size: 32,
              color: theme.colorScheme.primary,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Welcome',
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: theme.colorScheme.onPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  email,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onPrimary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _menuTile({
    required BuildContext context,
    required IconData icon,
    required String label,
    required String route,
  }) {
    final currentPath = GoRouterState.of(context).uri.path;
    final isSelected = currentPath == route;

    return ListTile(
      leading: Icon(icon),
      title: Text(label, style: AppTextStyles.body),
      selected: isSelected,
      selectedTileColor: Theme.of(
        context,
      ).colorScheme.primary.withValues(alpha: 0.1),
      onTap: () {
        Navigator.of(context).pop(); // close drawer
        if (!isSelected) {
          GoRouter.of(context).go(route);
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Drawer(
      child: SafeArea(
        child: Column(
          children: [
            _buildHeader(context, user),
            _menuTile(
              context: context,
              icon: Icons.dashboard_outlined,
              label: 'Dashboard',
              route: RouteNames.dashboard,
            ),
            _menuTile(
              context: context,
              icon: Icons.event_available_outlined,
              label: 'Appointments',
              route: RouteNames.appointments,
            ),
            _menuTile(
              context: context,
              icon: Icons.people_outline,
              label: 'Patients',
              route: RouteNames.patients,
            ),
            _menuTile(
              context: context,
              icon: Icons.medical_services_outlined,
              label: 'Visit',
              route: RouteNames.visit,
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.settings_outlined),
              title: const Text('Settings'),
              onTap: () {
                Navigator.of(context).pop();
                // add settings route when available
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Settings not implemented')),
                );
              },
            ),
            const Spacer(),
            ListTile(
              leading: const Icon(Icons.logout),
              title: const Text('Logout'),
              onTap: () {
                Navigator.of(context).pop();
                // Use GoRouter to go to login; auth state / AuthBloc should handle actual sign-out
                GoRouter.of(context).go(RouteNames.login);
              },
            ),
          ],
        ),
      ),
    );
  }
}
