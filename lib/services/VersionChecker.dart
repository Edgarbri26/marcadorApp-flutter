import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';

class VersionChecker {
  final String apiUrl;

  VersionChecker({required this.apiUrl});

  /// Obtener versión actual instalada en la app
  Future<String> getCurrentVersion() async {
    final packageInfo = await PackageInfo.fromPlatform();
    return packageInfo.version; // Ejemplo: "1.0.0"
  }

  /// Obtener la versión más reciente desde tu API
  Future<String> getLatestVersion() async {
    final response = await http.get(Uri.parse(apiUrl));

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['version']; // Solo nos interesa este campo
    } else {
      throw Exception('Error al obtener datos de la versión');
    }
  }

  /// Comparar y mostrar alerta si hay actualización
  Future<void> checkForUpdate(BuildContext context) async {
    try {
      final currentVersion = await getCurrentVersion();
      final latestVersion = await getLatestVersion();

      if (_isVersionOlder(currentVersion, latestVersion)) {
        _showUpdateDialog(context);
      }
    } catch (e) {
      debugPrint("Error verificando actualización: $e");
    }
  }

  /// Comparación de versiones "x.y.z"
  bool _isVersionOlder(String current, String latest) {
    final currentParts = current.split('.').map(int.parse).toList();
    final latestParts = latest.split('.').map(int.parse).toList();

    for (int i = 0; i < latestParts.length; i++) {
      if (currentParts[i] < latestParts[i]) return true;
      if (currentParts[i] > latestParts[i]) return false;
    }
    return false;
  }

  /// Mostrar alerta para actualizar
  void _showUpdateDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false, // Obligatorio actualizar
      builder: (context) {
        return AlertDialog(
          title: const Text("Actualización disponible"),
          content: const Text(
              "Hay una nueva versión de la aplicación. Por favor, actualiza para continuar."),
          actions: [
            ElevatedButton(
              onPressed: () async {
                final Uri url = Uri.parse(
                    "https://play.google.com/store/apps/details?id=com.tuapp"); // Cambia este enlace
                if (await canLaunchUrl(url)) {
                  await launchUrl(url, mode: LaunchMode.externalApplication);
                }
              },
              child: const Text("Actualizar"),
            ),
          ],
        );
      },
    );
  }
}
