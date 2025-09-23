// update_page.dart
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

  @override
  void initState() {
    super.initState();
    _checkForUpdate();
  }

  bool _checking = false;
  bool _hasUpdate = false;
  bool _downloading = false;
  double _downloadProgress = 0.0;
  String _statusMessage = "Presiona el botón para buscar actualizaciones";
  bool _isError = false; // Nueva variable de estado para errores

  Future<void> _checkForUpdate() async {
    setState(() {
      _checking = true;
      _isError = false;
      _statusMessage = "Buscando actualizaciones...";
    });

    final hasUpdate = await updateService.checkForUpdate();

    setState(() {
      _checking = false;
      _hasUpdate = hasUpdate;
      _statusMessage =
          hasUpdate ? "🚀 Hay una nueva versión disponible" : "✔ La aplicación está actualizada";
    });
  }

  Future<void> _downloadUpdate() async {
    setState(() {
      _downloading = true;
      _isError = false;
      _downloadProgress = 0.0;
      _statusMessage = "Descargando actualización...";
    });

    final error = await updateService.downloadAndInstallApkWithProgress(
      onProgress: (progress) {
        setState(() {
          _downloadProgress = progress;
          _statusMessage = "Descargando: ${(progress * 100).toStringAsFixed(0)}%";
        });
      },
    );

    setState(() {
      _downloading = false;
      if (error != null) {
        _isError = true;
        _statusMessage = error; // Muestra el mensaje de error del servicio
      } else {
        _isError = false;
        _statusMessage = "Descarga completada. Iniciando instalación...";
      }
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
            gradient: LinearGradient(
              colors: [
                MyColors.secundary,
                MyColors.secundaryContraste,
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
                style: TextStyle(
                  fontSize: 18,
                  color: _isError ? Colors.red : MyColors.light, // Cambia el color si hay error
                ),
              ),
            ),
            const SizedBox(height: 20),
            if (_downloading)
              Column(
                children: [
                  LinearProgressIndicator(value: _downloadProgress),
                  const SizedBox(height: 10),
                  Text("${(_downloadProgress * 100).toStringAsFixed(0)}%"),
                ],
              ),
            const SizedBox(height: 30),
            if (_hasUpdate && !_isError) // No mostrar el botón si hay un error
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