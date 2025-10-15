import 'package:flutter/foundation.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:flutter/material.dart';
import 'package:marcador/app.dart';
import 'package:marcador/models/match_repository.dart';
import 'package:flutter_fullscreen/flutter_fullscreen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
  await MatchRepository().init();

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

  runApp(MyApp());
}
