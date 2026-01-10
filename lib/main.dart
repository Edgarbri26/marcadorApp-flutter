import 'package:flutter/foundation.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:marcador/firebase_options.dart';
import 'package:marcador/app.dart';
import 'package:marcador/models/match_repository.dart';
import 'package:flutter_fullscreen/flutter_fullscreen.dart';
import 'package:provider/provider.dart';
import 'package:marcador/providers/jugadores_provider.dart';
import 'package:marcador/providers/match_provider.dart';
import 'package:marcador/services/offline_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  // SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
  await MatchRepository().init();
  OfflineService().init();

  try {
    if (!kIsWeb) {
      await FlutterDownloader.initialize(
        debug: false, // Cambia a false en producción
        ignoreSsl: false,
      );
    }
  } catch (e) {
    // Manejar cualquier error si es necesario, aunque el if debería prevenirlo
    print('Error al inicializar FlutterDownloader: $e');
  }

  WidgetsFlutterBinding.ensureInitialized();
  await FullScreen.ensureInitialized();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => JugadoresProvider()..fetchJugadores(),
        ),
        ChangeNotifierProvider(
          create: (_) => MatchProvider()..fetchPendingMatches(),
        ),
      ],
      child: MyApp(),
    ),
  );
}
