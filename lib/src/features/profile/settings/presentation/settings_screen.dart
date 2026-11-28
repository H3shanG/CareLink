import 'package:flutter/material.dart';
import 'package:carelink/l10n/app_localizations.dart';

import '../../../../core/localization/locale_controller.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.settings), centerTitle: true),
      body: ListView(
        children: [
          const SizedBox(height: 10),

          SwitchListTile(
            title: Text(l10n.pushNotifications),
            subtitle: Text(l10n.receiveNotifications),
            value: true,
            onChanged: (value) {},
          ),

          const Divider(),

          ListTile(
            leading: const Icon(Icons.lock_outline),
            title: Text(l10n.privacySecurity),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () {
              showDialog(
                context: context,
                builder: (dialogContext) => AlertDialog(
                  title: Text(l10n.privacySecurity),
                  content: Text(l10n.privacyMessage),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(dialogContext),
                      child: Text(l10n.close),
                    ),
                  ],
                ),
              );
            },
          ),

          ValueListenableBuilder<Locale>(
            valueListenable: LocaleController.currentLocale,
            builder: (context, locale, child) {
              final languageNames = {
                'en': 'English',
                'si': 'සිංහල',
                'ta': 'தமிழ்',
              };

              return ListTile(
                leading: const Icon(Icons.language),
                title: Text(l10n.language),
                subtitle: Text(languageNames[locale.languageCode] ?? 'English'),
                trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                onTap: () {
                  showDialog(
                    context: context,
                    builder: (dialogContext) => AlertDialog(
                      title: Text(l10n.selectLanguage),
                      content: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          ListTile(
                            title: const Text('English'),
                            onTap: () async {
                              await LocaleController.setLanguage('en');
                              if (dialogContext.mounted) {
                                Navigator.pop(dialogContext);
                              }
                            },
                          ),
                          ListTile(
                            title: const Text('සිංහල'),
                            onTap: () async {
                              await LocaleController.setLanguage('si');
                              if (dialogContext.mounted) {
                                Navigator.pop(dialogContext);
                              }
                            },
                          ),
                          ListTile(
                            title: const Text('தமிழ்'),
                            onTap: () async {
                              await LocaleController.setLanguage('ta');
                              if (dialogContext.mounted) {
                                Navigator.pop(dialogContext);
                              }
                            },
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
            },
          ),

          ListTile(
            leading: const Icon(Icons.info_outline),
            title: Text(l10n.aboutCareLink),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () {
              showDialog(
                context: context,
                builder: (dialogContext) => AlertDialog(
                  title: Text(l10n.aboutCareLink),
                  content: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.volunteer_activism, size: 55),
                      const SizedBox(height: 16),
                      Text(
                        l10n.careLinkDescription,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        l10n.appVersion,
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(dialogContext),
                      child: Text(l10n.close),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
