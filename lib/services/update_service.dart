import 'dart:convert';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:http/http.dart' as http;
import 'package:package_info_plus/package_info_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'package:open_filex/open_filex.dart';

// @pragma('vm:entry-point')
// void downloadCallback(dynamic id, dynamic status, dynamic progress) {
//   final SendPort? sendPort = IsolateNameServer.lookupPortByName(
//     UpdateService._portName,
//   );
//   sendPort?.send([id, status, progress]);
// }

class UpdateService {
  static const String githubRepoOwner = "Edgarbri26";
  static const String githubRepoName = "marcadorApp-flutter";
  // static const String _portName = 'downloader_send_port';

  /// Obtiene información del último release en GitHub
  Future<Map<String, dynamic>?> _fetchLatestRelease() async {
    final url = Uri.parse(
      "https://api.github.com/repos/$githubRepoOwner/$githubRepoName/releases/latest",
    );
    try {
      final response = await http.get(
        url,
        headers: {
          'User-Agent': 'FlutterAppUpdater', // GitHub requiere un User-Agent
        },
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        print("❌ Error GitHub API: ${response.statusCode}");
        return null;
      }
    } catch (e) {
      print("❌ Error de conexión: $e");
      return null;
    }
  }

  /// Verifica si hay una versión más reciente en GitHub
  Future<bool> checkForUpdate() async {
    final releaseData = await _fetchLatestRelease();
    if (releaseData == null) return false;

    final latestVersion = releaseData['tag_name'] ?? '';
    final packageInfo = await PackageInfo.fromPlatform();
    final currentVersion = packageInfo.version;

    print("📱 Versión instalada: $currentVersion");
    print("☁ Última versión en GitHub: $latestVersion");

    return currentVersion.trim() != latestVersion.trim();
  }

  /// Obtiene la URL directa del APK más reciente
  Future<String?> getLatestApkUrl() async {
    final releaseData = await _fetchLatestRelease();
    if (releaseData == null) return null;

    final assets = releaseData['assets'] as List?;
    if (assets == null || assets.isEmpty) {
      print("❌ No se encontraron assets en el release.");
      return null;
    }

    return assets[0]['browser_download_url'];
  }

  /// Obtiene la ruta local donde se guarda el APK descargado
  Future<String> _getLocalApkPath() async {
    final dir =
        await getApplicationSupportDirectory(); // Carpeta privada de la app
    return "${dir.path}/update.apk";
  }

  /// Comprueba si ya existe una actualización descargada previamente
  Future<File?> getDownloadedApkIfExists() async {
    final path = await _getLocalApkPath();
    final file = File(path);
    if (await file.exists()) {
      final size = await file.length();
      return size > 40 ? file : null;
    }
    return null;
  }

  /// Descarga el APK y abre el instalador.
  /// Retorna un mensaje de error o `null` si es exitoso.
  Future<String?> downloadAndInstallApkWithProgress({
    required Function(double) onProgress,
  }) async {
    final apkUrl = await getLatestApkUrl();
    if (apkUrl == null) {
      return "❌ Error: No se pudo obtener la URL del APK.";
    }

    try {
      final savePath = await _getLocalApkPath();

      print("HOlaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa");
      // Verificar si ya existe un APK previamente descargado
      final existingFile = await getDownloadedApkIfExists();
      if (existingFile != null) {
        print("📂 APK ya descargado previamente en: $savePath");

        await OpenFilex.open(savePath); // Abre el instalador existente
        return null;

        // deleteDownloadedApk();
      }

      print("📂 Guardando APK en: $savePath");

      final dio = Dio();
      await dio.download(
        apkUrl,
        savePath,
        onReceiveProgress: (received, total) {
          if (total != -1) {
            onProgress(received / total);
          }
        },
        options: Options(
          headers: {
            'User-Agent': 'FlutterAppUpdater', // GitHub requiere este header
          },
        ),
      );

      final file = File(savePath);
      if (await file.exists()) {
        print("📂 abriendo APK en: $savePath");

        await OpenFilex.open(file.path); // Abre el instalador
      } else {
        print("❌ El archivo no se descargó correctamente.");
      }
      return null;
    } catch (e) {
      return "❌ Error durante la descarga: $e";
    }
  }

  /// Borra el APK descargado previamente
  Future<void> deleteDownloadedApk() async {
    try {
      final path = await _getLocalApkPath();
      final file = File(path);
      if (await file.exists()) {
        await file.delete();
        print("🗑 APK descargado eliminado correctamente.");
      }
    } catch (e) {
      print("❌ Error al eliminar el APK descargado: $e");
    }
  }

  // /// Descarga el APK en segundo plano
  // static Future<void> downloadApk(String apkUrl) async {
  //   final dir = await getExternalStorageDirectory();
  //   final savedDir = dir!.path;

  //   final dirs =
  //       await getApplicationSupportDirectory(); // Carpeta privada de la app
  //   var path = "${dirs.path}/update.apk";

  //   // Verificar si ya existe un APK previamente descargado
  //   final file = File(path);
  //   if (await file.exists()) {
  //     file.delete();
  //   }

  //   await FlutterDownloader.enqueue(
  //     url: apkUrl,
  //     savedDir: savedDir,
  //     fileName: "update.apk",
  //     showNotification: true, // Muestra notificación nativa
  //     openFileFromNotification: true, // Abre al presionar la notificación
  //   );
  // }

  /// Abre el APK descargado después de la actualización
  Future<void> openDownloadedApk(String filePath) async {
    final file = File(filePath);
    if (await file.exists()) {
      print("📂 Abriendo APK en: $filePath");
      await OpenFilex.open(
        '/data/user/0/com.example.marcador/files/update.apk',
      );
    } else {
      print("❌ El archivo APK no existe en: $filePath");
    }
  }

  // @pragma('vm:entry-point')
  // void downloadCallback(dynamic id, dynamic status, dynamic progress) {
  //   final SendPort? sendPort = IsolateNameServer.lookupPortByName(UpdateService._portName);
  //   sendPort?.send([id, status, progress]); // Enviar los datos
  // }

  // void initializeDownloaderListener(
  //   Function(DownloadTaskStatus, int) onUpdate,
  // ) {
  //   final port = ReceivePort();

  //   IsolateNameServer.removePortNameMapping(UpdateService._portName);
  //   IsolateNameServer.registerPortWithName(
  //     port.sendPort,
  //     UpdateService._portName,
  //   );

  //   port.listen((dynamic data) {
  //     final DownloadTaskStatus status = data[1] as DownloadTaskStatus;
  //     final int progress = data[2] as int;

  //     onUpdate(status, progress);
  //   });

  //   FlutterDownloader.registerCallback(downloadCallback); // ✅ Ahora funciona
  // }
}
