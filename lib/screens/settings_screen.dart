import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../navigation/router_delegate.dart';
import '../providers/auth_provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final localizations = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(localizations.settings),
      ),
      body: ListView(
        children: [
          ListTile(
            title: Text(localizations.language),
            trailing: DropdownButton<Locale>(
              value: authProvider.locale,
              items: const [
                DropdownMenuItem(
                  value: Locale('en'),
                  child: Text('English'),
                ),
                DropdownMenuItem(
                  value: Locale('id'),
                  child: Text('Indonesia'),
                ),
              ],
              onChanged: (Locale? locale) {
                if (locale != null) {
                  authProvider.changeLanguage(locale);
                }
              },
            ),
          ),
          SwitchListTile(
            title: Text(localizations.darkMode),
            value: authProvider.isDarkMode,
            onChanged: (bool value) {
              authProvider.toggleDarkMode(value);
            },
          ),
          ListTile(
            title: Text(localizations.logout),
            onTap: () {
              authProvider.logout();
              final routerDelegate = Router.of(context).routerDelegate as MyRouterDelegate;
              routerDelegate.logout();
            },
          ),
        ],
      ),
    );
  }
}
