import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_application_1/repair/app.dart';
import 'package:flutter_application_1/repair/artwork_store.dart';
import 'package:flutter_application_1/repair/image_export.dart';
import 'package:flutter_application_1/repair/services/image_service.dart';

Future<void> _logIn(WidgetTester tester) async {
  await tester.pumpWidget(const ChitraApp());
  await tester.tap(find.text('Skip'));
  await tester.pumpAndSettle();

  await tester.enterText(find.byType(TextFormField).at(0), 'alex@example.com');
  await tester.enterText(find.byType(TextFormField).at(1), 'password123');
  await tester.ensureVisible(find.text('Continue'));
  await tester.tap(find.text('Continue'));
  await tester.pumpAndSettle();
}

Future<void> _generate(WidgetTester tester, String idea) async {
  await tester.enterText(find.byType(TextField).first, idea);
  await tester.scrollUntilVisible(
    find.text('Generate image'),
    250,
    scrollable: find.byType(Scrollable).first,
  );
  await tester.tap(find.text('Generate image'));
  await tester.pump();
  await tester.pump(const Duration(seconds: 4));
  await tester.pumpAndSettle();
}

String _promptText(WidgetTester tester) =>
    tester.widget<TextField>(find.byType(TextField).first).controller!.text;

void main() {
  setUp(() {
    ArtworkStore.reset();
    imageService = DemoImageService();
  });

  testWidgets('onboarding shows the first intro', (tester) async {
    await tester.pumpWidget(const ChitraApp());
    expect(find.text('Describe what you imagine'), findsOneWidget);
  });

  testWidgets('tapping Next very quickly never goes past step 3', (
    tester,
  ) async {
    await tester.pumpWidget(const ChitraApp());
    for (var tap = 0; tap < 5; tap++) {
      await tester.tap(find.text('Next'), warnIfMissed: false);
    }
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    expect(find.text('Welcome to Chitra AI'), findsOneWidget);
  });

  testWidgets('Skip opens login', (tester) async {
    await tester.pumpWidget(const ChitraApp());
    await tester.tap(find.text('Skip'));
    await tester.pumpAndSettle();
    expect(find.text('Welcome to Chitra AI'), findsOneWidget);
  });

  testWidgets(
    'sign up errors sit on the right fields and clear on tab switch',
    (tester) async {
      await tester.pumpWidget(const ChitraApp());
      await tester.tap(find.text('Skip'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Sign up'));
      await tester.pumpAndSettle();
      await tester.ensureVisible(find.text('Create account'));
      await tester.tap(find.text('Create account'));
      await tester.pumpAndSettle();

      expect(find.text('Full name is required.'), findsOneWidget);
      expect(find.text('Email is required.'), findsOneWidget);
      expect(
        find.text('Password must be at least 8 characters.'),
        findsOneWidget,
      );

      await tester.tap(find.text('Log in'));
      await tester.pumpAndSettle();
      expect(find.text('Full name is required.'), findsNothing);
      expect(find.text('Email is required.'), findsNothing);
    },
  );

  testWidgets('login can generate and open the result screen', (tester) async {
    await _logIn(tester);
    await _generate(tester, 'A fox reading in a library');

    expect(find.text('Your image'), findsOneWidget);
    await tester.scrollUntilVisible(
      find.text('A fox reading in a library'),
      250,
      scrollable: find.byType(Scrollable).first,
    );
    expect(find.text('A fox reading in a library'), findsOneWidget);
  });

  testWidgets('Improve with AI never stacks wording', (tester) async {
    await _logIn(tester);
    await tester.enterText(find.byType(TextField).first, 'a fox');

    await tester.tap(find.text('Improve with AI'));
    await tester.pumpAndSettle();
    final first = _promptText(tester);
    expect(first.startsWith('a fox, '), isTrue);

    await tester.tap(find.text('Improve with AI'));
    await tester.pumpAndSettle();
    expect(_promptText(tester), first);
    expect('thoughtfully composed'.allMatches(first).length, 1);
  });

  testWidgets('a blocked idea shows the blocked screen with no retry', (
    tester,
  ) async {
    await _logIn(tester);
    await _generate(tester, 'a fox [blocked]');

    expect(find.text('We cannot create that idea'), findsOneWidget);
    expect(find.text('Try again'), findsNothing);
    expect(find.text('Edit my idea'), findsOneWidget);
  });

  testWidgets('a busy error can be retried and then succeeds', (tester) async {
    await _logIn(tester);
    await _generate(tester, 'a fox [busy]');

    expect(find.text('The image service is busy'), findsOneWidget);
    await tester.tap(find.text('Try again'));
    await tester.pump();
    await tester.pump(const Duration(seconds: 4));
    await tester.pumpAndSettle();

    expect(find.text('Your image'), findsOneWidget);
  });

  testWidgets('Change email errors clear when you type a valid address', (
    tester,
  ) async {
    await _logIn(tester);
    await tester.tap(find.text('Profile'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Change email'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Save changes'));
    await tester.pumpAndSettle();
    expect(find.text('Email is required.'), findsOneWidget);

    await tester.enterText(find.byType(TextFormField).first, 'new@example.com');
    await tester.pumpAndSettle();
    expect(find.text('Email is required.'), findsNothing);
  });

  testWidgets('changing the style after Improve shows an update hint', (
    tester,
  ) async {
    await _logIn(tester);
    await tester.enterText(find.byType(TextField).first, 'a fox');
    await tester.tap(find.text('Improve with AI'));
    await tester.pumpAndSettle();
    expect(find.textContaining('You changed the style'), findsNothing);

    await tester.ensureVisible(find.text('Anime'));
    await tester.tap(find.text('Anime'));
    await tester.pumpAndSettle();
    expect(find.textContaining('You changed the style'), findsOneWidget);
  });

  // The demo pictures have no image file, so these never reach the plugins.
  testWidgets('Download and Share explain that a demo picture has no file', (
    tester,
  ) async {
    await _logIn(tester);
    await _generate(tester, 'A fox reading in a library');

    await tester.tap(find.text('Download'));
    await tester.pump();
    expect(find.text(noImageFileMessage), findsOneWidget);

    await tester.pump(const Duration(seconds: 5));
    await tester.tap(find.text('Share'));
    await tester.pump();
    expect(find.text(noImageFileMessage), findsOneWidget);
  });
}
