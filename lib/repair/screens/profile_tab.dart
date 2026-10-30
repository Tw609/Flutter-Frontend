import 'package:flutter/material.dart';

import '../artwork_store.dart';
import '../theme_state.dart';
import '../widgets/user_avatar.dart';
import 'account_pages.dart';
import '../app_icons.dart';

/// The fourth tab: account details, settings and log out.
class ProfileTab extends StatelessWidget {
  const ProfileTab({super.key, required this.onLogout});

  final VoidCallback onLogout;

  void _toggleTheme() {
    appThemeMode.value = appThemeMode.value == ThemeMode.dark
        ? ThemeMode.light
        : ThemeMode.dark;
  }

  void _push(BuildContext context, Widget page) =>
      Navigator.push(context, MaterialPageRoute(builder: (_) => page));

  Widget _row(
    BuildContext context,
    IconData icon,
    String title,
    VoidCallback onTap,
  ) => Card(
    child: ListTile(
      onTap: onTap,
      leading: Icon(icon, color: Theme.of(context).colorScheme.primary),
      title: Text(title),
      trailing: const Icon(AppIcons.caretRight),
    ),
  );

  @override
  Widget build(BuildContext context) {
    final muted = Theme.of(context).colorScheme.onSurfaceVariant;
    return ListView(
      padding: const EdgeInsets.all(22),
      children: [
        Row(
          children: [
            Text(
              'Profile',
              style: Theme.of(context).textTheme.headlineSmall
                  ?.copyWith(fontWeight: FontWeight.w800),
            ),
            const Spacer(),
            ValueListenableBuilder<ThemeMode>(
              valueListenable: appThemeMode,
              builder: (context, mode, _) => IconButton(
                tooltip: 'Toggle light and dark mode',
                onPressed: _toggleTheme,
                icon: Icon(
                  mode == ThemeMode.dark ? AppIcons.sun : AppIcons.moon,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
        const Center(child: UserAvatar(radius: 42)),
        const SizedBox(height: 12),
        ValueListenableBuilder<String>(
          valueListenable: ArtworkStore.userName,
          builder: (context, name, _) => Center(
            child: Text(
              name,
              style: Theme.of(context).textTheme.titleLarge
                  ?.copyWith(fontWeight: FontWeight.bold),
            ),
          ),
        ),
        ValueListenableBuilder<String>(
          valueListenable: ArtworkStore.username,
          builder: (context, username, _) => Center(
            child: Text(username, style: TextStyle(color: muted)),
          ),
        ),
        Center(
          child: OutlinedButton(
            onPressed: () => _push(context, const EditProfilePage()),
            child: const Text('Edit profile'),
          ),
        ),
        const SizedBox(height: 12),
        _row(
          context,
          AppIcons.palette,
          'Appearance',
          () => _push(context, const AppearancePage()),
        ),
        _row(
          context,
          AppIcons.at,
          'Change email',
          () => _push(context, const ChangeEmailPage()),
        ),
        _row(
          context,
          AppIcons.lock,
          'Change password',
          () => _push(context, const ChangePasswordPage()),
        ),
        _row(
          context,
          AppIcons.question,
          'Help and support',
          () => _push(context, const HelpSupportPage()),
        ),
        _row(context, AppIcons.signOut, 'Log out', onLogout),
      ],
    );
  }
}
