import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:damu_app/src/app/app.dart';
import 'package:damu_app/src/core/storage/prefs.dart';

void main() {
  testWidgets('App builds', (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [sharedPrefsProvider.overrideWithValue(prefs)],
        child: const DamuApp(),
      ),
    );
    await tester.pump();
    expect(find.byType(DamuApp), findsOneWidget);
  });
}
