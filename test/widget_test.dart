import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:mobscanner/l10n/app_localizations.dart';

/// Smoke test: the localization delegates resolve strings for each locale.
void main() {
  testWidgets('localizations resolve for supported locales', (tester) async {
    for (final locale in AppLocalizations.supportedLocales) {
      await tester.pumpWidget(MaterialApp(
        locale: locale,
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: AppLocalizations.supportedLocales,
        home: Builder(
          builder: (context) => Text(AppLocalizations.of(context).appTitle),
        ),
      ));
      await tester.pumpAndSettle();
      expect(find.text('MobScanner'), findsOneWidget);
    }
  });
}
