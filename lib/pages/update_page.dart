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
  String _statusMessage = "Press the button to check for updates";
  bool _isError = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkForUpdate();
    });
  }

  Future<void> _checkForUpdate() async {
    setState(() {
      _checking = true;
      _isError = false;
      _statusMessage = "🔍 Checking for updates...";
    });

    final hasUpdate = await updateService.checkForUpdate();

    if (!mounted) return;

    setState(() {
      _checking = false;
      _hasUpdate = hasUpdate;
      _statusMessage =
          hasUpdate
              ? "🚀 New version available. Update now!"
              : "✔ App is up to date";
    });
  }

  Future<void> _downloadUpdate() async {
    updateService.deleteDownloadedApk();
    setState(() {
      _downloading = true;
      _isError = false;
      _downloadProgress = 0.0;
      _statusMessage = "⬇️ Downloading update...";
    });

    final error = await updateService.downloadAndInstallApkWithProgress(
      onProgress: (progress) {
        if (!mounted) return;
        setState(() {
          _downloadProgress = progress;
          _statusMessage =
              "⬇️ Downloading: ${(progress * 100).toStringAsFixed(0)}%";
        });
      },
    );

    if (!mounted) return;

    setState(() {
      _downloading = false;
      if (error != null) {
        _isError = true;
        _statusMessage = error;
      } else {
        _isError = false;
        _statusMessage =
            "✅ Download complete. The installer has been launched.";
      }
    });
  }

  Widget _buildProgressIndicator() {
    return Column(
      children: [
        LinearProgressIndicator(
          value: _downloadProgress,
          backgroundColor: Colors.grey.shade800,
          color: MyColors.secundary,
          minHeight: 8,
        ),
        const SizedBox(height: 10),
        Text(
          "${(_downloadProgress * 100).toStringAsFixed(0)}%",
          style: const TextStyle(color: Colors.white70),
        ),
      ],
    );
  }

  Widget _buildActionButton() {
    if (_checking) {
      return const CircularProgressIndicator(color: MyColors.secundary);
    }

    if (_downloading) {
      return _buildProgressIndicator();
    }

    if (_hasUpdate && !_isError) {
      return ElevatedButton.icon(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.green,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        ),
        icon: const Icon(Icons.download, color: Colors.white),
        label: const Text(
          "Download and install",
          style: TextStyle(color: Colors.white, fontSize: 16),
        ),
        onPressed: _downloadUpdate,
      );
    }

    return ElevatedButton.icon(
      style: ElevatedButton.styleFrom(
        backgroundColor: MyColors.secundary,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
      ),
      icon: const Icon(Icons.refresh, color: Colors.white),
      label: const Text(
        "Check for update",
        style: TextStyle(color: Colors.white, fontSize: 16),
      ),
      onPressed: _checkForUpdate,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: MyColors.dark,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          "Update application",
          style: TextStyle(color: MyColors.light),
        ),
        centerTitle: true,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [MyColors.secundary, MyColors.secundaryContraste],
              begin: Alignment.bottomCenter,
              end: Alignment.topCenter,
            ),
            borderRadius: const BorderRadius.only(
              bottomLeft: Radius.circular(Spacing.sm),
              bottomRight: Radius.circular(Spacing.sm),
            ),
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.max,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: Text(
                'Do not leave the window while the update is downloading',
                style: TextStyle(color: MyColors.lightGray, fontSize: 20),
                textAlign: TextAlign.center,
              ),
            ),
            Expanded(
              child: Center(
                child: Card(
                  color: Colors.grey.shade900,
                  elevation: 6,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.system_update,
                          size: 80,
                          color: MyColors.secundary,
                        ),
                        const SizedBox(height: 20),
                        AnimatedSwitcher(
                          duration: const Duration(milliseconds: 300),
                          child: Text(
                            _statusMessage,
                            key: ValueKey<String>(_statusMessage),
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 18,
                              color:
                                  _isError ? Colors.redAccent : MyColors.light,
                            ),
                          ),
                        ),
                        const SizedBox(height: 30),
                        _buildActionButton(),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
