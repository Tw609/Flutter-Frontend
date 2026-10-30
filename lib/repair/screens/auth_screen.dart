import 'package:flutter/material.dart';

import '../artwork_store.dart';
import '../styles.dart';
import '../explore_ideas.dart';
import '../widgets/chitra_logo.dart';
import '../widgets/explore_image.dart';
import 'home_screen.dart';
import 'account_pages.dart';
import '../app_icons.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  int _step = 0;
  bool _leaving = false;

  static const _headlines = [
    'Describe what you imagine',
    'Pick a style',
    'Get your image in seconds',
  ];
  static const _descriptions = [
    'Type a sentence like “a fox reading in a library”. No art skills needed.',
    'Choose from ten styles, from photorealistic to pixel art. The style changes how your image looks.',
    'Improve your words first, so the picture matches your idea.',
  ];

  // Two quick taps can run before the screen rebuilds, so the check on
  // _step must happen inside the tap, not when the button is built.
  void _next() {
    if (_step < 2) {
      setState(() => _step++);
    } else {
      _openAuth();
    }
  }

  void _openAuth() {
    if (_leaving) return;
    _leaving = true;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const AuthScreen()),
    );
  }

  /// A small picture of each step instead of a generic icon.
  Widget _illustration(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    if (_step == 2) {
      return SizedBox(
        width: 220,
        height: 220,
        child: ExploreImage(idea: exploreIdeas.first, radius: 32),
      );
    }
    return Container(
      width: 220,
      height: 220,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: scheme.secondaryContainer,
        borderRadius: BorderRadius.circular(32),
      ),
      child: Center(
        child: _step == 0
            ? Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: scheme.surface,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Your idea',
                      style: Theme.of(context).textTheme.labelSmall
                          ?.copyWith(color: scheme.onSurfaceVariant),
                    ),
                    const SizedBox(height: 6),
                    const Text('A fox reading a book in a cozy library'),
                  ],
                ),
              )
            : Wrap(
                spacing: 6,
                runSpacing: 6,
                alignment: WrapAlignment.center,
                children: [
                  for (final style in artStyles.take(6))
                    Chip(
                      label: Text(style.name),
                      visualDensity: VisualDensity.compact,
                      backgroundColor: scheme.surface,
                    ),
                ],
              ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    body: SafeArea(
      child: LayoutBuilder(
        builder: (context, constraints) => SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: constraints.maxHeight - 36),
            child: IntrinsicHeight(
              child: Column(
                children: [
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: _openAuth,
                      style: TextButton.styleFrom(
                        textStyle: const TextStyle(fontSize: 16),
                      ),
                      child: const Text('Skip'),
                    ),
                  ),
                  const Spacer(),
                  _illustration(context),
                  const SizedBox(height: 22),
                  Chip(label: Text('Step ${_step + 1} of 3')),
                  const SizedBox(height: 8),
                  Text(
                    _headlines[_step],
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.headlineSmall
                        ?.copyWith(fontWeight: FontWeight.w800),
                  ),
                  const SizedBox(height: 12),
                  Text(_descriptions[_step], textAlign: TextAlign.center),
                  const Spacer(),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      3,
                      (index) => AnimatedContainer(
                        duration: const Duration(milliseconds: 180),
                        margin: const EdgeInsets.all(3),
                        width: index == _step ? 18 : 6,
                        height: 5,
                        decoration: BoxDecoration(
                          color: index == _step
                              ? Theme.of(context).colorScheme.primary
                              : Theme.of(context).colorScheme.outlineVariant,
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: FilledButton(
                      onPressed: _next,
                      child: Text(_step < 2 ? 'Next' : 'Get started'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    ),
  );
}

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _signUp = false;
  bool _hidePassword = true;
  bool _leaving = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _continue() {
    FocusScope.of(context).unfocus();
    if (!_formKey.currentState!.validate()) return;

    final email = _emailController.text.trim();
    ArtworkStore.email.value = email;
    if (_signUp) {
      final enteredName = _nameController.text.trim();
      final name = enteredName.isEmpty ? email.split('@').first : enteredName;
      ArtworkStore.updateProfile(
        name: name,
        username: name.toLowerCase().replaceAll(' ', ''),
      );
    } else if (ArtworkStore.userName.value == ArtworkStore.defaultName) {
      ArtworkStore.updateProfile(
        name: email.split('@').first,
        username: email.split('@').first,
      );
    }
    _openHome();
  }

  void _continueWithGoogle() {
    // TODO: Replace with real Google sign-in. Until then there is no email.
    ArtworkStore.email.value = '';
    _openHome();
  }

  void _openHome() {
    if (_leaving) return;
    _leaving = true;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => HomeScreen(onLogout: _openLoginAfterLogout),
      ),
    );
  }

  void _openLoginAfterLogout(BuildContext homeContext) {
    Navigator.of(homeContext).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const AuthScreen()),
      (_) => false,
    );
  }

  String? _validateEmail(String? value) {
    final email = value?.trim() ?? '';
    if (email.isEmpty) return 'Email is required.';
    if (!RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$').hasMatch(email)) {
      return 'Enter a valid email address.';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    body: SafeArea(
      child: LayoutBuilder(
        builder: (context, constraints) => SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: constraints.maxHeight - 48),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 24),
                  const Center(child: ChitraLogo(size: 72, animate: false)),
                  const SizedBox(height: 18),
                  Text(
                    'Welcome to Chitra AI',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.headlineSmall
                        ?.copyWith(fontWeight: FontWeight.w800),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Describe an idea and turn it into an image.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 24),
                  SegmentedButton<bool>(
                    segments: const [
                      ButtonSegment(value: false, label: Text('Log in')),
                      ButtonSegment(value: true, label: Text('Sign up')),
                    ],
                    selected: {_signUp},
                    onSelectionChanged: (selection) =>
                        setState(() => _signUp = selection.first),
                  ),
                  const SizedBox(height: 18),
                  // Each field has its own key. Without keys, Flutter reuses
                  // the Full name field for Email when you switch tabs, which
                  // shifted the error messages onto the wrong fields.
                  if (_signUp) ...[
                    TextFormField(
                      key: const ValueKey('signup-name'),
                      controller: _nameController,
                      textCapitalization: TextCapitalization.words,
                      textInputAction: TextInputAction.next,
                      autovalidateMode: AutovalidateMode.onUserInteraction,
                      decoration: const InputDecoration(
                        labelText: 'Full name',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) => (value?.trim().isEmpty ?? true)
                          ? 'Full name is required.'
                          : null,
                    ),
                    const SizedBox(height: 14),
                  ],
                  TextFormField(
                    key: ValueKey('email-$_signUp'),
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    textInputAction: TextInputAction.next,
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                    decoration: const InputDecoration(
                      labelText: 'Email',
                      hintText: 'you@example.com',
                      border: OutlineInputBorder(),
                    ),
                    validator: _validateEmail,
                  ),
                  const SizedBox(height: 14),
                  TextFormField(
                    key: ValueKey('password-$_signUp'),
                    controller: _passwordController,
                    obscureText: _hidePassword,
                    textInputAction: TextInputAction.done,
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                    onFieldSubmitted: (_) => _continue(),
                    decoration: InputDecoration(
                      labelText: 'Password',
                      hintText: 'At least 8 characters',
                      border: const OutlineInputBorder(),
                      suffixIcon: IconButton(
                        tooltip: _hidePassword
                            ? 'Show password'
                            : 'Hide password',
                        onPressed: () =>
                            setState(() => _hidePassword = !_hidePassword),
                        icon: Icon(
                          _hidePassword ? AppIcons.eye : AppIcons.eyeSlash,
                        ),
                      ),
                    ),
                    validator: (value) => (value?.length ?? 0) < 8
                        ? 'Password must be at least 8 characters.'
                        : null,
                  ),
                  if (!_signUp)
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const ForgotPasswordPage(),
                          ),
                        ),
                        child: const Text('Forgot password?'),
                      ),
                    ),
                  const SizedBox(height: 8),
                  SizedBox(
                    height: 50,
                    child: FilledButton(
                      onPressed: _continue,
                      child: Text(_signUp ? 'Create account' : 'Continue'),
                    ),
                  ),
                  const SizedBox(height: 14),
                  Center(
                    child: Text(
                      'or',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  OutlinedButton(
                    onPressed: _continueWithGoogle,
                    child: const Text('Continue with Google'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    ),
  );
}
