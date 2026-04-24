import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import 'package:anime_discovery/main.dart';
import 'package:anime_discovery/providers/anime_provider.dart';

void main() {
  testWidgets('App smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (context) => ThemeProvider()),
          ChangeNotifierProvider(create: (context) => AnimeProvider()),
        ],
        child: const ApiReaderApp(),
      ),
    );

    expect(find.byType(ApiReaderApp), findsOneWidget);
  });
}
