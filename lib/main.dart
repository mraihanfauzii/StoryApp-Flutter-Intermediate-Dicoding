import 'package:dicoding_flutter_intermediate/navigation/route_information_parser.dart';
import 'package:dicoding_flutter_intermediate/navigation/router_delegate.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/auth_provider.dart';
import 'providers/story_provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late MyRouteInformationParser _routeInformationParser;
  MyRouterDelegate? _routerDelegate;

  @override
  void initState() {
    super.initState();
    _routeInformationParser = MyRouteInformationParser();
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<AuthProvider>(
          create: (_) => AuthProvider(),
        ),
        ChangeNotifierProvider<StoryProvider>(
          create: (_) => StoryProvider(),
        ),
      ],
      child: Consumer<AuthProvider>(
        builder: (context, authProvider, child) {
          // Inisialisasi _routerDelegate dengan authProvider
          if (_routerDelegate == null) {
            _routerDelegate = MyRouterDelegate(authProvider);
          }

          if (authProvider.isLoading) {
            return const MaterialApp(
              home: Scaffold(
                body: Center(child: CircularProgressIndicator()),
              ),
            );
          } else {
            return MaterialApp.router(
              routerDelegate: _routerDelegate!,
              routeInformationParser: _routeInformationParser,
              title: 'Story App',
              theme: authProvider.isDarkMode
                  ? ThemeData.dark().copyWith(
                primaryColor: Colors.blue,
                colorScheme: const ColorScheme.dark(
                  primary: Colors.blue,
                ),
              )
                  : ThemeData(
                primarySwatch: Colors.blue,
                primaryColor: Colors.blue,
              ),
              locale: authProvider.locale,
              supportedLocales: const [
                Locale('en', ''),
                Locale('id', ''),
              ],
              localizationsDelegates: const [
                AppLocalizations.delegate,
                GlobalMaterialLocalizations.delegate,
                GlobalWidgetsLocalizations.delegate,
                GlobalCupertinoLocalizations.delegate,
              ],
            );
          }
        },
      ),
    );
  }
}