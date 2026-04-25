import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:anime_discovery/widgets/pagination_indicator.dart';
import 'package:anime_discovery/theme/app_theme.dart';

Widget _wrap(Widget child) => MaterialApp(
      theme: AppTheme.dark,
      home: Scaffold(body: SingleChildScrollView(child: child)),
    );

void main() {
  group('PaginationIndicator', () {
    testWidgets('shows loaded count', (tester) async {
      await tester.pumpWidget(
        _wrap(
          const PaginationIndicator(
            loadedCount: 25,
            isLoading: false,
            hasMore: true,
          ),
        ),
      );

      expect(find.textContaining('25'), findsOneWidget);
      expect(find.textContaining('anime loaded'), findsOneWidget);
    });

    testWidgets('shows loading state', (tester) async {
      await tester.pumpWidget(
        _wrap(
          const PaginationIndicator(
            loadedCount: 25,
            isLoading: true,
            hasMore: true,
          ),
        ),
      );

      expect(find.text('Loading more...'), findsOneWidget);
      expect(find.byType(LinearProgressIndicator), findsOneWidget);
    });

    testWidgets('shows scroll for more when has more', (tester) async {
      await tester.pumpWidget(
        _wrap(
          const PaginationIndicator(
            loadedCount: 25,
            isLoading: false,
            hasMore: true,
          ),
        ),
      );

      expect(find.text('Scroll for more'), findsOneWidget);
    });

    testWidgets('shows all caught up when no more', (tester) async {
      await tester.pumpWidget(
        _wrap(
          const PaginationIndicator(
            loadedCount: 25,
            isLoading: false,
            hasMore: false,
          ),
        ),
      );

      expect(find.text('All caught up'), findsOneWidget);
    });

    testWidgets('does not show progress bar when not loading',
        (tester) async {
      await tester.pumpWidget(
        _wrap(
          const PaginationIndicator(
            loadedCount: 25,
            isLoading: false,
            hasMore: true,
          ),
        ),
      );

      expect(find.byType(LinearProgressIndicator), findsNothing);
    });

    testWidgets('uses custom itemLabel', (tester) async {
      await tester.pumpWidget(
        _wrap(
          const PaginationIndicator(
            loadedCount: 10,
            isLoading: false,
            hasMore: true,
            itemLabel: 'characters',
          ),
        ),
      );

      expect(find.textContaining('characters loaded'), findsOneWidget);
    });
  });

  group('PageCounter', () {
    testWidgets('shows current page', (tester) async {
      await tester.pumpWidget(
        _wrap(
          const PageCounter(currentPage: 3),
        ),
      );

      expect(find.text('Page 3'), findsOneWidget);
    });

    testWidgets('shows page 1', (tester) async {
      await tester.pumpWidget(
        _wrap(
          const PageCounter(currentPage: 1),
        ),
      );

      expect(find.text('Page 1'), findsOneWidget);
    });
  });
}