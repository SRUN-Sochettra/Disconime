import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import 'package:anime_discovery/main.dart';

void main() {
  testWidgets('App smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(
      ChangeNotifierProvider(
        create: (context) => ThemeProvider(),
        child: const ApiReaderApp(),
      ),
    );

    expect(find.byType(ApiReaderApp), findsOneWidget);
  });
}
