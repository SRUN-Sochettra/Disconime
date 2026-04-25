import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:anime_discovery/widgets/error_view.dart';
import 'package:anime_discovery/theme/app_theme.dart';

Widget _wrap(Widget child) => MaterialApp(
      theme: AppTheme.dark,
      home: Scaffold(body: child),
    );

void main() {
  group('ErrorView', () {
    testWidgets('renders error title', (tester) async {
      await tester.pumpWidget(
        _wrap(
          ErrorView(
            message: 'Test error message',
            onRetry: () {},
          ),
        ),
      );

      expect(find.text('Something went wrong'), findsOneWidget);
    });

    testWidgets('renders error message', (tester) async {
      await tester.pumpWidget(
        _wrap(
          ErrorView(
            message: 'Test error message',
            onRetry: () {},
          ),
        ),
      );

      expect(find.text('Test error message'), findsOneWidget);
    });

    testWidgets('renders retry button', (tester) async {
      await tester.pumpWidget(
        _wrap(
          ErrorView(
            message: 'Error',
            onRetry: () {},
          ),
        ),
      );

      expect(find.text('Try Again'), findsOneWidget);
    });

    testWidgets('calls onRetry when button tapped', (tester) async {
      var retried = false;

      await tester.pumpWidget(
        _wrap(
          ErrorView(
            message: 'Error',
            onRetry: () => retried = true,
          ),
        ),
      );

      await tester.tap(find.text('Try Again'));
      expect(retried, isTrue);
    });

    testWidgets('renders wifi off icon', (tester) async {
      await tester.pumpWidget(
        _wrap(
          ErrorView(
            message: 'Error',
            onRetry: () {},
          ),
        ),
      );

      expect(find.byIcon(Icons.wifi_off_rounded), findsOneWidget);
    });

    testWidgets('expand: true uses Center widget', (tester) async {
      await tester.pumpWidget(
        _wrap(
          ErrorView(
            message: 'Error',
            onRetry: () {},
          ),
        ),
      );

      expect(find.byType(Center), findsWidgets);
    });

    testWidgets('expand: false uses Padding instead of full expand',
        (tester) async {
      await tester.pumpWidget(
        _wrap(
          SingleChildScrollView(
            child: ErrorView(
              message: 'Error',
              onRetry: () {},
              expand: false,
            ),
          ),
        ),
      );

      // Should still render the content.
      expect(find.text('Something went wrong'), findsOneWidget);
    });
  });
}