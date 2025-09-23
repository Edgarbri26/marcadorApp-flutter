import 'package:flutter/material.dart';
import 'package:marcador/design/my_colors.dart';
import 'package:marcador/design/spacing.dart';
import 'package:marcador/services/update_service.dart';

class UpdatePage extends StatefulWidget {
  const UpdatePage({super.key});

  @override
  State<UpdatePage> createState() => _UpdatePageState();
}

class _UpdatePageState extends State<UpdatePage> {
  final UpdateService updateService = UpdateService();

  bool _checking = false;
  bool _hasUpdate = false;
  bool _downloading = false;
  double _downloadProgress = 0.0;
  String _statusMessage = "Presiona el botón para buscar actualizaciones";

  /// 🔹 Método para verificar si hay actualización
  Future<void> _checkForUpdate() async {
    setState(() {
      _checking = true;
      _statusMessage = "Buscando actualizaciones...";
    });

    final hasUpdate = await updateService.checkForUpdate();

    setState(() {
      _checking = false;
      _hasUpdate = hasUpdate;
      _statusMessage =
          hasUpdate
              ? "🚀 Hay una nueva versión disponible"
              : "✔ La aplicación está actualizada";
    });
  }

  /// 🔹 Método para descargar el APK
  Future<void> _downloadUpdate() async {
    setState(() {
      _downloading = true;
      _downloadProgress = 0.0;
      _statusMessage = "Descargando actualización...";
    });

    await updateService.downloadAndInstallApkWithProgress(
      onProgress: (progress) {
        setState(() {
          _downloadProgress = progress;
          _statusMessage =
              "Descargando: ${(progress * 100).toStringAsFixed(0)}%";
        });
      },
    );

    setState(() {
      _downloading = false;
      _statusMessage = "Descarga completada. Iniciando instalación...";
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: MyColors.dark,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        toolbarHeight: 60,
        foregroundColor: MyColors.light,
        title: const Text(
          "Actualizar aplicación",
          style: TextStyle(color: MyColors.light),
        ),
        flexibleSpace: Container(
          decoration: BoxDecoration(
            borderRadius: const BorderRadius.only(
              bottomLeft: Radius.circular(Spacing.sm),
              bottomRight: Radius.circular(Spacing.sm),
            ),
            //// PARA EL BORDE REDONDEADO DEL APPBAR
            gradient: LinearGradient(
              colors: [
                MyColors.secundary,
                MyColors.secundaryContraste,
                // MyColors.dark,
              ],
              begin: Alignment.bottomCenter,
              end: Alignment.topCenter,
            ),
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Center(
              child: Text(
                _statusMessage,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 18, color: MyColors.light),
              ),
            ),
            const SizedBox(height: 20),

            // Barra de progreso durante descarga
            if (_downloading)
              Column(
                children: [
                  LinearProgressIndicator(value: _downloadProgress),
                  const SizedBox(height: 10),
                  Text("${(_downloadProgress * 100).toStringAsFixed(0)}%"),
                ],
              ),

            const SizedBox(height: 30),

            // Botón para buscar actualizaciones
            ElevatedButton.icon(
              onPressed: _checking ? null : _checkForUpdate,
              icon: const Icon(Icons.search),
              label:
                  _checking
                      ? const Text(
                        "Buscando...",
                        style: TextStyle(color: MyColors.light),
                      )
                      : const Text(
                        "Buscar actualización",
                        style: TextStyle(color: MyColors.darkGray),
                      ),
            ),

            const SizedBox(height: 15),

            // Botón para descargar si hay actualización
            if (_hasUpdate)
              ElevatedButton.icon(
                onPressed: _downloading ? null : _downloadUpdate,
                icon: const Icon(Icons.download),
                label: const Text(
                  "Descargar e instalar",
                  style: TextStyle(color: MyColors.light),
                ),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
              ),
          ],
        ),
      ),
    );
  }
}
