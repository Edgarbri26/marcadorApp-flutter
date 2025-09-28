import 'package:flutter/material.dart';
import 'package:marcador/config/app_routes.dart';
import 'package:marcador/design/my_colors.dart';
import 'package:marcador/pages/marker_off_line_page.dart';
import 'package:marcador/pages/marker_tournament_page.dart';
import 'package:marcador/pages/settings_page.dart';
import 'package:marcador/pages/update_page.dart';
import 'package:marcador/pages/login_page.dart';
import 'package:marcador/services/marker.dart';
import 'package:marcador/models/match.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

class MyApp extends StatelessWidget {
  MyApp({super.key});
  final Marker marker = Marker();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Marcador de Puntos',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: MyColors.secundary,
          brightness: Brightness.dark, // Si tu app es oscura
        ),
        fontFamily: 'Inter',
      ),
      onGenerateRoute: (settings) {
        switch (settings.name) {
          case AppRoutes.settings:
            return MaterialPageRoute(builder: (context) => SettingsPage(marker: marker));
          case AppRoutes.markerOffLine:
            return MaterialPageRoute(builder: (context) => MarkerOffLinePage());
          case AppRoutes.update:
            return MaterialPageRoute(builder: (context) => UpdatePage());
          case AppRoutes.markerTournament:
            return MaterialPageRoute(builder:(context) => MarkerTournamentPage(match: settings.arguments as Match));
          default:
            return MaterialPageRoute(builder: (context) => LogInPage());
        }
      },
      // home: GameSettingsPage(),
    );
  }
}
