// update_service.dart
import 'dart:convert';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:http/http.dart' as http;
import 'package:package_info_plus/package_info_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:open_filex/open_filex.dart';

class UpdateService {
  Future<Map<String, dynamic>?> _fetchLatestRelease() async {
    final url = Uri.parse(
        "https://api.github.com/repos/Edgarbri26/marcadorApp-flutter/releases/latest");
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        return null;
      }
    } catch (e) {
      return null;
    }
  }

  Future<bool> checkForUpdate() async {
    final releaseData = await _fetchLatestRelease();
    if (releaseData == null) return false;
    final latestVersion = releaseData['tag_name'];
    final packageInfo = await PackageInfo.fromPlatform();
    final currentVersion = packageInfo.version;
    return currentVersion != latestVersion;
  }

  Future<String?> getLatestApkUrl() async {
    final releaseData = await _fetchLatestRelease();
    if (releaseData == null) return null;
    final assets = releaseData['assets'] as List?;
    if (assets == null || assets.isEmpty) {
      return null;
    }
    return assets[0]['browser_download_url'];
  }

  /// Descarga el APK con progreso y abre el instalador. Retorna el mensaje de error o null si es exitoso.
  Future<String?> downloadAndInstallApkWithProgress({
    required Function(double) onProgress,
  }) async {
    final apkUrl = await getLatestApkUrl();
    if (apkUrl == null) {
      return "❌ Error: No se pudo obtener la URL del APK.";
    }

    final status = await Permission.storage.request();
    if (!status.isGranted) {
      return "❌ Error: Permiso de almacenamiento denegado.";
    }

    try {
      final dir = await getTemporaryDirectory();
      final savePath = "${dir.path}/update.apk";
      final dio = Dio();
      await dio.download(
        apkUrl,
        savePath,
        onReceiveProgress: (received, total) {
          if (total != -1) {
            onProgress(received / total);
          }
        },
      );
      final file = File(savePath);
      if (await file.exists()) {
        await OpenFilex.open(savePath);
        return null; // Éxito
      } else {
        return "❌ Error: El archivo no se descargó correctamente.";
      }
    } catch (e) {
      return "❌ Error durante la descarga: $e";
    }
  }
}