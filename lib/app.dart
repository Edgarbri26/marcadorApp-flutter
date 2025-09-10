import 'package:flutter/material.dart';
import 'package:marcador/config/app_routes.dart';
import 'package:marcador/pages/marcador_vertical_page.dart';
import 'package:marcador/pages/settings_page.dart';
import 'package:marcador/services/marker.dart';

class MyApp extends StatelessWidget {
  MyApp({super.key});
  Marker marker = Marker();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Marcador de Puntos',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(primarySwatch: Colors.blue, fontFamily: 'Inter'),
      onGenerateRoute: (settings) {
        switch (settings.name) {
          case AppRoutes.settings:
            return MaterialPageRoute(builder: (context) => SettingsPage(marker: marker));
          case AppRoutes.marcadorVertical:
            return MaterialPageRoute(
              builder: (context) => MarcadorVerticalPage(marker: marker),
            );
          default:
            return MaterialPageRoute(builder: (context) => SettingsPage(marker: marker));
        }
      },
      // home: GameSettingsPage(),
    );
  }
}
