import 'package:flutter/material.dart';
import 'package:marcador/config/app_routes.dart';
import 'package:marcador/pages/marcador_vertical_page.dart';
import 'package:marcador/pages/settings_page.dart';
import 'package:marcador/services/marker.dart';
// import 'package:firebase_app_distribution/firebase_app_distribution.dart';

// Llama a esta función al inicio de tu app, por ejemplo, en initState()
// Llama a esta función al inicio de tu app, por ejemplo, en initState()
// Future<void> checkForUpdates() async {
//   // Ahora usas el .instance para acceder a la funcionalidad
//   final appDistribution = FirebaseAppDistribution.instance; 

//   // Llama a la función de Firebase para buscar actualizaciones
//   final release = await appDistribution.checkForUpdate();

//   if (release != null) {
//     // Si hay una nueva versión, muestra un diálogo de actualización
//     _showUpdateDialog(release);
//   }
// }

// // Muestra el diálogo de actualización
// void _showUpdateDialog(AppDistributionRelease release) {
//   showDialog(
//     context: navigatorKey.currentState!.context,
//     barrierDismissible: false,
//     builder: (BuildContext context) {
//       return AlertDialog(
//         title: const Text('Nueva Versión Beta Disponible'),
//         content: Column(
//           mainAxisSize: MainAxisSize.min,
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Text('Versión: ${release.displayVersion} (${release.buildVersion})'),
//             const SizedBox(height: 8),
//             Text(release.releaseNotes ?? 'Sin notas de la versión.'),
//             const SizedBox(height: 16),
//             const Text('¿Quieres descargarla e instalarla ahora?'),
//           ],
//         ),
//         actions: <Widget>[
//           TextButton(
//             child: const Text('Actualizar'),
//             onPressed: () {
//               // Redirige al usuario para que instale la nueva versión
//               // Aquí también usas .instance para acceder al método updateApp
//               FirebaseAppDistribution.instance.updateApp();
//               Navigator.of(context).pop();
//             },
//           ),
//           TextButton(
//             child: const Text('Más tarde'),
//             onPressed: () {
//               Navigator.of(context).pop();
//             },
//           ),
//         ],
//       );
//     },
//   );
// }

// Asegúrate de tener una GlobalKey en tu MaterialApp para acceder al contexto
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

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
