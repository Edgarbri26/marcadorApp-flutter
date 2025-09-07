import 'package:flutter/material.dart';
import 'package:marcador/config/app_routes.dart';
import 'package:marcador/pages/game_settings_page.dart';
import 'package:marcador/pages/marcador_vertical_page.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Marcador de Puntos',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(primarySwatch: Colors.blue, fontFamily: 'Inter'),
      onGenerateRoute: (settings) {
        switch (settings.name) {
          case AppRoutes.settings:
            return MaterialPageRoute(
              builder: (context) => const GameSettingsPage(),
            );
          case AppRoutes.marcadorVertical:
            return MaterialPageRoute(
              builder: (context) => const MarcadorVerticalPage(),
            );
          default:
            return MaterialPageRoute(builder: (context) => GameSettingsPage());
        }
      },
      // home: GameSettingsPage(),
    );
  }
}
