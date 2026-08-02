import 'package:flutter/material.dart';
import 'config/theme/app_theme.dart';
import 'config/routes.dart';
import 'config/app_config.dart';

/// Root application widget.
class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: AppConfig.appName,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: ThemeMode.light,
      routerConfig: AppRoutes.router,
    );
  }
}
