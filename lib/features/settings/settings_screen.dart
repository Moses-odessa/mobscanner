import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants.dart';
import '../../core/providers.dart';
import '../../l10n/app_localizations.dart';

/// User preferences: language, theme, scan quality, OCR languages, export.
class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final settings = ref.watch(settingsProvider);
    final controller = ref.read(settingsProvider.notifier);

    return ListView(
      children: [
        _sectionHeader(context, l10n.settingsLanguage),
        RadioGroup<String>(
          groupValue: settings.locale?.languageCode ?? 'system',
          onChanged: (value) => controller.setLocale(
              value == 'system' ? null : Locale(value!)),
          child: Column(
            children: [
              RadioListTile<String>(
                  value: 'system',
                  title: Text(l10n.settingsThemeSystem)),
              RadioListTile<String>(value: 'en', title: const Text('English')),
              RadioListTile<String>(value: 'ru', title: const Text('Русский')),
              RadioListTile<String>(value: 'uk', title: const Text('Українська')),
            ],
          ),
        ),
        const Divider(),
        _sectionHeader(context, l10n.settingsTheme),
        RadioGroup<ThemeMode>(
          groupValue: settings.themeMode,
          onChanged: (value) => controller.setThemeMode(value!),
          child: Column(
            children: [
              RadioListTile<ThemeMode>(
                  value: ThemeMode.system,
                  title: Text(l10n.settingsThemeSystem)),
              RadioListTile<ThemeMode>(
                  value: ThemeMode.light, title: Text(l10n.settingsThemeLight)),
              RadioListTile<ThemeMode>(
                  value: ThemeMode.dark, title: Text(l10n.settingsThemeDark)),
            ],
          ),
        ),
        const Divider(),
        _sectionHeader(context, l10n.settingsScanQuality),
        RadioGroup<ScanQuality>(
          groupValue: settings.scanQuality,
          onChanged: (value) => controller.setScanQuality(value!),
          child: Column(
            children: [
              RadioListTile<ScanQuality>(
                  value: ScanQuality.low, title: Text(l10n.qualityLow)),
              RadioListTile<ScanQuality>(
                  value: ScanQuality.medium, title: Text(l10n.qualityMedium)),
              RadioListTile<ScanQuality>(
                  value: ScanQuality.high, title: Text(l10n.qualityHigh)),
            ],
          ),
        ),
        const Divider(),
        _sectionHeader(context, l10n.settingsOcrLanguages),
        for (final lang in OcrLanguage.all)
          CheckboxListTile(
            title: Text(lang.label),
            value: settings.ocrLanguages.any((l) => l.code == lang.code),
            onChanged: (checked) {
              final current = List<OcrLanguage>.from(settings.ocrLanguages);
              if (checked == true) {
                if (!current.any((l) => l.code == lang.code)) current.add(lang);
              } else {
                current.removeWhere((l) => l.code == lang.code);
              }
              controller.setOcrLanguages(current);
            },
          ),
        const Divider(),
        _sectionHeader(context, l10n.settingsExportFormat),
        RadioGroup<ExportFormat>(
          groupValue: settings.exportFormat,
          onChanged: (value) => controller.setExportFormat(value!),
          child: Column(
            children: [
              RadioListTile<ExportFormat>(
                  value: ExportFormat.pdf, title: const Text('PDF')),
              RadioListTile<ExportFormat>(
                  value: ExportFormat.jpg, title: const Text('JPG')),
            ],
          ),
        ),
        const Divider(),
        AboutListTile(
          icon: const Icon(Icons.info_outline),
          applicationName: l10n.appTitle,
          applicationVersion: '1.0.0',
          child: Text(l10n.settingsAbout),
        ),
      ],
    );
  }

  Widget _sectionHeader(BuildContext context, String title) => Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
        child: Text(title,
            style: Theme.of(context)
                .textTheme
                .titleSmall
                ?.copyWith(color: Theme.of(context).colorScheme.primary)),
      );
}
