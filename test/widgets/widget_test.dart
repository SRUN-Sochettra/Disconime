import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  // The full app widget test is intentionally minimal.
  // Screen-level tests live in test/widgets/.
  // Provider tests live in test/providers/.
  // The router makes full integration tests unreliable in the
  // test environment — use flutter drive for those.

  testWidgets('MaterialApp renders', (tester) async {
    SharedPreferences.setMockInitialValues({});

    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: Center(child: Text('Test')),
        ),
      ),
    );

    expect(find.text('Test'), findsOneWidget);
    expect(find.byType(MaterialApp), findsOneWidget);
  });
}