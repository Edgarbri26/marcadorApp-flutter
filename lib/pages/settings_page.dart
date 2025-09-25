import 'package:flutter/material.dart';
import 'package:marcador/config/app_routes.dart';
import 'package:marcador/design/my_colors.dart';
import 'package:marcador/design/spacing.dart';
import 'package:marcador/pages/amistoso_page.dart';
import 'package:marcador/pages/tournament_page.dart';
import 'package:marcador/services/marker.dart';
import 'package:marcador/services/update_service.dart';
import 'package:marcador/widget/signal_off.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:package_info_plus/package_info_plus.dart';

class SettingsPage extends StatefulWidget {
  final Marker marker;
  const SettingsPage({super.key, required this.marker});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  final UpdateService updateService = UpdateService();

  @override
  void initState() {
    super.initState();
    // // 🔹 Bloquea orientación vertical
    // SystemChrome.setPreferredOrientations([
    //   DeviceOrientation.portraitUp,
    //   DeviceOrientation.portraitDown,
    // ]);
    _loadSettings(); // Cargar datos guardados
    debugVersion();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkForUpdate(showDialogOnUpdate: true);
    });
  }

  Future<void> _checkForUpdate({bool showDialogOnUpdate = false}) async {
    final hasUpdate = await updateService.checkForUpdate();

    if (!mounted) return;

    // Si hay una actualización, mostrar el dialog
    if (hasUpdate && showDialogOnUpdate) {
      _showUpdateDialog();
    }
  }

  /// 🔹 Mostrar un diálogo cuando hay nueva versión
  void _showUpdateDialog() {
    showDialog(
      context: context,
      barrierDismissible: false, // No cerrar al tocar fuera
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.grey.shade900,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: const Text(
            "Nueva versión disponible",
            style: TextStyle(
              color: MyColors.light,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: const Text(
            "Se ha detectado una nueva versión de la aplicación. "
            "¿Deseas descargarla e instalarla ahora?",
            style: TextStyle(color: MyColors.light),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Cierra el diálogo
              },
              child: const Text(
                "Más tarde",
                style: TextStyle(color: Colors.grey),
              ),
            ),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.of(context).pop(); // Cierra el diálogo
                Navigator.of(context).pushNamed(AppRoutes.update);
              },
              icon: const Icon(Icons.download, color: Colors.white),
              label: const Text(
                "Actualizar",
                style: TextStyle(color: Colors.white),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: MyColors.secundary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
  /////////////////////////////////////////////////////////////////////////////////////

  Future<void> debugVersion() async {
    final packageInfo = await PackageInfo.fromPlatform();
    print(
      "📱 Versión instalada: ${packageInfo.version}+${packageInfo.buildNumber}",
    );
  }

  int _selectedIndex = 0;
  String title = 'Amistoso';

  // Índice inicial en Configuración
  void _onItemTapped(int index) {
    if (index == 0) {
      title = 'Partido sin conexion';
    } else if (index == 1) {
      title = 'Partido amistoso';
    } else if (index == 2) {
      title = 'Configuracion de partido';
    }
    setState(() {
      _selectedIndex = index;
    });
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();

    setState(() {
      widget.marker.targetPoints = prefs.getInt('points') ?? 5;
      widget.marker.targetSets = prefs.getInt('sets') ?? 3;
    });
  }

  /// Cargar ajustes desde SharedPreferences

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: MyColors.dark,

      appBar: AppBar(
        toolbarHeight: 60,
        title: Container(
          margin: const EdgeInsets.only(top: Spacing.xs),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            mainAxisSize: MainAxisSize.max,
            children: [
              Padding(
                padding: const EdgeInsets.only(left: Spacing.md),
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: MyColors.lightGray,
                  ),
                ),
              ),
              IconButton(
                onPressed: () {
                  Navigator.pushNamed(context, AppRoutes.update);
                },
                icon: Icon(
                  // Icons.account_circle,
                  Icons.update,
                  color: MyColors.lightGray,
                  size: 30,
                ),
              ),
            ],
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            borderRadius: const BorderRadius.only(
              bottomLeft: Radius.circular(Spacing.sm),
              bottomRight: Radius.circular(Spacing.sm),
            ), // PARA EL BORDE REDONDEADO DEL APPBAR
            gradient: LinearGradient(
              colors: [MyColors.secundary, MyColors.secundaryContraste],
              begin: Alignment.bottomCenter,
              end: Alignment.topCenter,
            ),
          ),
        ),
      ),

      body: Padding(
        padding: const EdgeInsets.all(Spacing.lg),
        child: Center(
          child: IndexedStack(
            index: _selectedIndex,
            children: [
              SignalOff(marker: widget.marker),
              AmistosoPage(),
              const PartidoPage(),
            ],
          ),
        ),
      ),

      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: MyColors.darkUltra,
        unselectedItemColor: Colors.white70,
        selectedItemColor: MyColors.secundary,
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.wifi_off_outlined),
            label: 'sin conexion',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.handshake_rounded),
            label: 'Amistoso',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.emoji_events),
            label: 'Torneo',
          ),
        ],
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
      ),
    );
  }
}
