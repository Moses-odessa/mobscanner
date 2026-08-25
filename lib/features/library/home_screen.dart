import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../l10n/app_localizations.dart';
import '../scanner/scan_flow.dart';
import '../settings/settings_screen.dart';
import 'library_screen.dart';

/// App shell: Library / Settings tabs with a central Scan action.
class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  int _index = 0;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final titles = [l10n.libraryTitle, l10n.settingsTitle];

    return Scaffold(
      appBar: AppBar(title: Text(titles[_index])),
      body: IndexedStack(
        index: _index,
        children: const [
          LibraryScreen(),
          SettingsScreen(),
        ],
      ),
      floatingActionButton: _index == 0
          ? FloatingActionButton.extended(
              onPressed: () => _openScanSheet(context),
              icon: const Icon(Icons.document_scanner),
              label: Text(l10n.actionScan),
            )
          : null,
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (i) => setState(() => _index = i),
        destinations: [
          NavigationDestination(
            icon: const Icon(Icons.folder_outlined),
            selectedIcon: const Icon(Icons.folder),
            label: l10n.navLibrary,
          ),
          NavigationDestination(
            icon: const Icon(Icons.settings_outlined),
            selectedIcon: const Icon(Icons.settings),
            label: l10n.navSettings,
          ),
        ],
      ),
    );
  }

  void _openScanSheet(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final flow = ScanFlow(ref);
    showModalBottomSheet(
      context: context,
      builder: (sheetContext) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.document_scanner_outlined),
              title: Text(l10n.actionScan),
              onTap: () {
                Navigator.pop(sheetContext);
                flow.startNativeScan(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library_outlined),
              title: Text(l10n.actionImport),
              onTap: () {
                Navigator.pop(sheetContext);
                flow.startImport(context);
              },
            ),
          ],
        ),
      ),
    );
  }
}
