import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:integration_test/integration_test.dart';
import 'package:mobscanner/app/app.dart';
import 'package:mobscanner/core/providers.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// On-device smoke test: the app boots, shows the empty library, and the
/// bottom navigation switches to Settings.
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('app boots and navigates', (tester) async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [sharedPrefsProvider.overrideWithValue(prefs)],
        child: const MobScannerApp(),
      ),
    );
    await tester.pumpAndSettle();

    // Library tab with the scan FAB is visible.
    expect(find.byType(NavigationBar), findsOneWidget);

    // Switch to Settings.
    await tester.tap(find.byIcon(Icons.settings_outlined));
    await tester.pumpAndSettle();
    expect(find.byType(RadioListTile<ThemeMode>), findsWidgets);
  });
}
