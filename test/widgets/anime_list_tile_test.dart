import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:network_image_mock/network_image_mock.dart';
import 'package:anime_discovery/widgets/anime_list_tile.dart';
import 'package:anime_discovery/theme/app_theme.dart';
import '../helpers/test_data.dart';

Widget _wrap(Widget child) => MaterialApp(
      theme: AppTheme.dark,
      home: Scaffold(body: child),
    );

void main() {
  group('AnimeListTile', () {
    testWidgets('renders title', (tester) async {
      await mockNetworkImagesFor(() async {
        await tester.pumpWidget(
          _wrap(
            AnimeListTile(
              anime: TestData.naruto,
              onTap: () {},
            ),
          ),
        );

        expect(find.text('Naruto'), findsOneWidget);
      });
    });

    testWidgets('renders score', (tester) async {
      await mockNetworkImagesFor(() async {
        await tester.pumpWidget(
          _wrap(
            AnimeListTile(
              anime: TestData.naruto,
              onTap: () {},
            ),
          ),
        );

        expect(find.text('7.98'), findsOneWidget);
      });
    });

    testWidgets('renders N/A when score is null', (tester) async {
      await mockNetworkImagesFor(() async {
        await tester.pumpWidget(
          _wrap(
            AnimeListTile(
              anime: TestData.animeNoScore,
              onTap: () {},
            ),
          ),
        );

        expect(find.text('N/A'), findsOneWidget);
      });
    });

    testWidgets('renders genres', (tester) async {
      await mockNetworkImagesFor(() async {
        await tester.pumpWidget(
          _wrap(
            AnimeListTile(
              anime: TestData.naruto,
              onTap: () {},
            ),
          ),
        );

        expect(find.textContaining('Action'), findsOneWidget);
      });
    });

    testWidgets('shows rank badge when showRank is true', (tester) async {
      await mockNetworkImagesFor(() async {
        await tester.pumpWidget(
          _wrap(
            AnimeListTile(
              anime: TestData.naruto,
              onTap: () {},
              showRank: true,
            ),
          ),
        );

        expect(find.text('#100 Rank'), findsOneWidget);
      });
    });

    testWidgets('does not show rank badge when showRank is false',
        (tester) async {
      await mockNetworkImagesFor(() async {
        await tester.pumpWidget(
          _wrap(
            AnimeListTile(
              anime: TestData.naruto,
              onTap: () {},
              showRank: false,
            ),
          ),
        );

        expect(find.text('#100 Rank'), findsNothing);
      });
    });

    testWidgets('shows type badge when showTypeBadge is true',
        (tester) async {
      await mockNetworkImagesFor(() async {
        await tester.pumpWidget(
          _wrap(
            AnimeListTile(
              anime: TestData.naruto,
              onTap: () {},
              showTypeBadge: true,
            ),
          ),
        );

        expect(find.text('TV'), findsOneWidget);
      });
    });

    testWidgets('calls onTap when tapped', (tester) async {
      await mockNetworkImagesFor(() async {
        var tapped = false;

        await tester.pumpWidget(
          _wrap(
            AnimeListTile(
              anime: TestData.naruto,
              onTap: () => tapped = true,
            ),
          ),
        );

        await tester.tap(find.byType(InkWell).first);
        expect(tapped, isTrue);
      });
    });

    testWidgets('renders trailing widget when provided', (tester) async {
      await mockNetworkImagesFor(() async {
        await tester.pumpWidget(
          _wrap(
            AnimeListTile(
              anime: TestData.naruto,
              onTap: () {},
              trailing: const Icon(Icons.bookmark_rounded, key: Key('trail')),
            ),
          ),
        );

        expect(find.byKey(const Key('trail')), findsOneWidget);
      });
    });
  });
}