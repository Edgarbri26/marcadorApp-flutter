import 'dart:io'
    show Platform; // Importa 'Platform' para verificar la plataforma
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:flutter/material.dart';
import 'package:marcador/app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);

  try {
    if (Platform.isAndroid || Platform.isIOS) {
      await FlutterDownloader.initialize(
        debug: true, // Cambia a false en producción
        ignoreSsl: false,
      );
    }
  } catch (e) {
    // Manejar cualquier error si es necesario, aunque el if debería prevenirlo
    print('Error al inicializar FlutterDownloader: $e');
  }

  runApp(MyApp());
}
