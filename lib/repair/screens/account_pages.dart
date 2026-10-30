import 'package:flutter/material.dart';

import '../artwork_store.dart';
import '../theme_state.dart';
import '../ui_helpers.dart';
import '../app_icons.dart';

class AppearancePage extends StatelessWidget {
  const AppearancePage({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Appearance')),
    body: ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Text(
          'Choose how Chitra AI looks. Use the sun or moon button on your profile to switch between Light and Dark.',
          style: TextStyle(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 18),
        ValueListenableBuilder<ThemeMode>(
          valueListenable: appThemeMode,
          builder: (context, selected, _) => RadioGroup<ThemeMode>(
            groupValue: selected,
            onChanged: (value) {
              if (value != null) appThemeMode.value = value;
            },
            child: Column(
              children: [
                for (final mode in [
                  ThemeMode.light,
                  ThemeMode.dark,
                  ThemeMode.system,
                ])
                  Card(
                    child: RadioListTile<ThemeMode>(
                      value: mode,
                      title: Text(_modeTitle(mode)),
                      subtitle: Text(_modeSubtitle(mode)),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ],
    ),
  );

  String _modeTitle(ThemeMode mode) => switch (mode) {
    ThemeMode.light => 'Light',
    ThemeMode.dark => 'Dark',
    ThemeMode.system => 'System',
  };

  String _modeSubtitle(ThemeMode mode) => switch (mode) {
    ThemeMode.light => 'Always light',
    ThemeMode.dark => 'Always dark',
    ThemeMode.system => 'Match your device settings',
  };
}

class ChangeEmailPage extends StatefulWidget {
  const ChangeEmailPage({super.key});

  @override
  State<ChangeEmailPage> createState() => _ChangeEmailPageState();
}

class _ChangeEmailPageState extends State<ChangeEmailPage> {
  final _formKey = GlobalKey<FormState>();
  final _email = TextEditingController();
  final _currentEmail = TextEditingController(text: ArtworkStore.email.value);

  @override
  void dispose() {
    _email.dispose();
    _currentEmail.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Change email')),
    body: Form(
      key: _formKey,
      child: ListView(
        padding: const EdgeInsets.all(22),
        children: [
          Text(
            'We will send a confirmation link to your new address.',
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 20),
          const Text('Current email'),
          const SizedBox(height: 6),
          // readOnly keeps the text easy to read. A disabled field is faint.
          TextField(
            controller: _currentEmail,
            readOnly: true,
            decoration: InputDecoration(
              hintText: ArtworkStore.email.value.isEmpty
                  ? 'Signed in with Google'
                  : null,
              filled: true,
              fillColor: Theme.of(context).colorScheme.surfaceContainerHighest,
              border: const OutlineInputBorder(),
              suffixIcon: const Icon(AppIcons.lock, size: 18),
            ),
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _email,
            keyboardType: TextInputType.emailAddress,
            autovalidateMode: AutovalidateMode.onUserInteraction,
            decoration: const InputDecoration(
              labelText: 'New email',
              border: OutlineInputBorder(),
            ),
            validator: validEmail,
          ),
          const SizedBox(height: 22),
          FilledButton(
            onPressed: () {
              if (_formKey.currentState!.validate()) {
                showNotice(context, 'Confirmation email sent.');
              }
            },
            child: const Text('Save changes'),
          ),
        ],
      ),
    ),
  );
}

class ChangePasswordPage extends StatefulWidget {
  const ChangePasswordPage({super.key});

  @override
  State<ChangePasswordPage> createState() => _ChangePasswordPageState();
}

class _ChangePasswordPageState extends State<ChangePasswordPage> {
  final _formKey = GlobalKey<FormState>();
  final _password = TextEditingController();
  final _confirmation = TextEditingController();

  @override
  void dispose() {
    _password.dispose();
    _confirmation.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // No email means the user signed in with Google, so Google owns the password.
    final isGoogle = ArtworkStore.email.value.isEmpty;
    return Scaffold(
      appBar: AppBar(title: const Text('Change password')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(22),
          children: [
            if (isGoogle) ...[
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(14),
                  child: Text(
                    'You signed in with Google, so your password is managed by Google.',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],
            TextFormField(
              controller: _password,
              enabled: !isGoogle,
              obscureText: true,
              autovalidateMode: AutovalidateMode.onUserInteraction,
              decoration: const InputDecoration(
                labelText: 'New password',
                hintText: 'At least 8 characters',
                border: OutlineInputBorder(),
              ),
              validator: (value) => (value?.length ?? 0) < 8
                  ? 'Use at least 8 characters.'
                  : null,
            ),
            const SizedBox(height: 14),
            TextFormField(
              controller: _confirmation,
              enabled: !isGoogle,
              obscureText: true,
              autovalidateMode: AutovalidateMode.onUserInteraction,
              decoration: const InputDecoration(
                labelText: 'Confirm new password',
                border: OutlineInputBorder(),
              ),
              validator: (value) =>
                  value != _password.text ? 'Passwords do not match.' : null,
            ),
            const SizedBox(height: 20),
            FilledButton(
              onPressed: isGoogle
                  ? null
                  : () {
                      if (_formKey.currentState!.validate()) {
                        showNotice(context, 'Password updated.');
                      }
                    },
              child: const Text('Save changes'),
            ),
          ],
        ),
      ),
    );
  }
}

class HelpSupportPage extends StatelessWidget {
  const HelpSupportPage({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Help and support')),
    body: ListView(
      padding: const EdgeInsets.all(18),
      children: [
        const Text(
          'Common questions',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        const ExpansionTile(
          title: Text('How does Improve with AI work?'),
          children: [
            ListTile(
              title: Text(
                'It adds detail about the scene, lighting and mood to your idea, matched to the style you picked. You can edit the result or tap Undo.',
              ),
            ),
          ],
        ),
        const ExpansionTile(
          title: Text('Why did my image fail?'),
          children: [
            ListTile(
              title: Text(
                'The image service may be busy, you may have reached the limit for now, or your idea may have been blocked by our content rules. Wait a moment and try again, or change your idea.',
              ),
            ),
          ],
        ),
        const ExpansionTile(
          title: Text('Where are my images saved?'),
          children: [
            ListTile(
              title: Text(
                'For now, images stay on this device only while the app is open. Saving to your account is coming.',
              ),
            ),
          ],
        ),
        const ExpansionTile(
          title: Text('How do I change the style?'),
          children: [
            ListTile(
              title: Text(
                'Pick Photorealistic, Anime, Cyberpunk, Watercolor or 3D on the Create page.',
              ),
            ),
          ],
        ),
        const SizedBox(height: 30),
        const Text('Still need help?'),
        Text(
          'Send us a message and tell us what happened.',
          style: TextStyle(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 10),
        OutlinedButton(
          onPressed: () => _openSupportForm(context),
          child: const Text('Contact support'),
        ),
      ],
    ),
  );

  void _openSupportForm(BuildContext context) {
    final messenger = ScaffoldMessenger.of(context);
    // The sheet closes with an animation, so the controller is left for the
    // garbage collector instead of being disposed while the field is visible.
    final controller = TextEditingController();
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (sheetContext) => Padding(
        padding: EdgeInsets.fromLTRB(
          22,
          4,
          22,
          22 + MediaQuery.of(sheetContext).viewInsets.bottom,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Contact support',
              style: Theme.of(sheetContext).textTheme.titleLarge
                  ?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 14),
            TextField(
              controller: controller,
              maxLines: 5,
              decoration: const InputDecoration(
                labelText: 'What happened?',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 14),
            FilledButton(
              onPressed: () {
                if (controller.text.trim().isEmpty) return;
                // TODO: Send this message to your support inbox or backend.
                Navigator.pop(sheetContext);
                messenger.showSnackBar(
                  const SnackBar(
                    content: Text('Thanks. Your message was sent.'),
                  ),
                );
              },
              child: const Text('Send message'),
            ),
          ],
        ),
      ),
    );
  }
}

class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({super.key});

  @override
  State<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  final _formKey = GlobalKey<FormState>();
  final _email = TextEditingController();

  @override
  void dispose() {
    _email.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Reset password')),
    body: Form(
      key: _formKey,
      child: ListView(
        padding: const EdgeInsets.all(22),
        children: [
          const SizedBox(height: 20),
          Text(
            'Forgot your password?',
            style: Theme.of(context).textTheme.headlineSmall
                ?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            'Enter your email and we will send you a link to reset it.',
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 22),
          TextFormField(
            controller: _email,
            keyboardType: TextInputType.emailAddress,
            autovalidateMode: AutovalidateMode.onUserInteraction,
            decoration: const InputDecoration(
              labelText: 'Email',
              hintText: 'you@example.com',
              border: OutlineInputBorder(),
            ),
            validator: validEmail,
          ),
          const SizedBox(height: 18),
          FilledButton(
            onPressed: () {
              if (_formKey.currentState!.validate()) {
                showNotice(
                  context,
                  'If your account exists, a reset link will be sent.',
                );
              }
            },
            child: const Text('Send reset link'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Back to log in'),
          ),
        ],
      ),
    ),
  );
}

class EditProfilePage extends StatefulWidget {
  const EditProfilePage({super.key});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  late final TextEditingController _name;
  late final TextEditingController _username;
  final _bio = TextEditingController();

  @override
  void initState() {
    super.initState();
    _name = TextEditingController(text: ArtworkStore.userName.value);
    _username = TextEditingController(text: ArtworkStore.username.value);
  }

  @override
  void dispose() {
    _name.dispose();
    _username.dispose();
    _bio.dispose();
    super.dispose();
  }

  void _save() {
    final name = _name.text.trim();
    final username = _username.text.trim();
    if (name.isEmpty || username.isEmpty) {
      showNotice(context, 'Name and username are required.');
      return;
    }
    ArtworkStore.updateProfile(name: name, username: username);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: const Text('Edit profile'),
      actions: [TextButton(onPressed: _save, child: const Text('Save'))],
    ),
    body: ListView(
      padding: const EdgeInsets.all(22),
      children: [
        Center(
          child: CircleAvatar(radius: 38, child: Text(_initials(_name.text))),
        ),
        const SizedBox(height: 20),
        TextField(
          controller: _name,
          textCapitalization: TextCapitalization.words,
          decoration: const InputDecoration(
            labelText: 'Full name',
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 14),
        TextField(
          controller: _username,
          decoration: const InputDecoration(
            labelText: 'Username',
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 14),
        TextField(
          controller: _bio,
          maxLines: 3,
          decoration: const InputDecoration(
            labelText: 'Bio',
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 18),
        FilledButton(onPressed: _save, child: const Text('Save changes')),
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
      ],
    ),
  );

  String _initials(String name) {
    final parts = name
        .trim()
        .split(RegExp(r'\s+'))
        .where((part) => part.isNotEmpty);
    final firstTwo = parts.take(2).map((part) => part[0].toUpperCase());
    final initials = firstTwo.join();
    return initials.isEmpty ? 'AI' : initials;
  }
}
