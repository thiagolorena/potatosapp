import 'package:flutter/material.dart';

import 'core/config/app_config.dart';
import 'core/navigation/app_route_observer.dart';
import 'core/services/api_client.dart';
import 'core/theme/potatos_theme.dart';
import 'features/auth/login_page.dart';

void main() {
  runApp(const PotatosApp());
}

class PotatosApp extends StatelessWidget {
  const PotatosApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ApiScope(
      client: ApiClient(baseUrl: AppConfig.apiBaseUrl),
      child: MaterialApp(
        title: 'Potatos Racing',
        debugShowCheckedModeBanner: false,
        theme: PotatosTheme.light(),
        darkTheme: PotatosTheme.dark(),
        themeMode: ThemeMode.dark,
        navigatorObservers: [appRouteObserver],
        home: const LoginPage(),
      ),
    );
  }
}
