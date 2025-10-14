import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:marcador/config/app_routes.dart';
import 'package:marcador/design/my_colors.dart';
import 'package:marcador/design/spacing.dart';
import 'package:marcador/pages/amistoso_page.dart';
import 'package:marcador/pages/tournament_page.dart';
import 'package:marcador/services/update_service.dart';
import 'package:marcador/widget/signal_off.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  final UpdateService updateService = UpdateService();
  // late final StreamSubscription _connectionSub;

  @override
  void initState() {
    super.initState();
    // 🔹 Bloquea orientación vertical
    // SystemChrome.setPreferredOrientations([
    //   DeviceOrientation.portraitUp,
    //   DeviceOrientation.portraitDown,
    // ]);

    
    // debugVersion();
    if (!kIsWeb) {
      SystemChrome.setPreferredOrientations([
        DeviceOrientation.portraitUp,
        DeviceOrientation.portraitDown,
      ]);
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _checkForUpdate(showDialogOnUpdate: true);
      });
    }
  }

  

  @override
  void dispose() {
    // 🔹 Restaurar orientación libre al salir
    kIsWeb
        ? null
        : SystemChrome.setPreferredOrientations(DeviceOrientation.values);
    super.dispose();
    // _connectionSub.cancel();
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

  int _selectedIndex = 0;
  String title = 'Amistoso';

  // Índice inicial en Configuración
  void _onItemTapped(int index) {
    if (index == 0) {
      title = 'Partido sin conexion';
    } else if (index == 1) {
      title = 'Partidos de Duelos';
    } else if (index == 2) {
      title = 'Partidos por Torneos';
    }
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // backgroundColor: MyColors.dark,
      appBar: AppBar(
        systemOverlayStyle: const SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.dark,
        ),
        // toolbarHeight: 60,
        title: Container(
          margin: const EdgeInsets.only(top: Spacing.xs),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            mainAxisSize: MainAxisSize.max,
            children: [
              Expanded(
                //padding: const EdgeInsets.only(left: Spacing.md),
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: MyColors.lightGray,
                  ),
                ),
              ),
              kIsWeb
                  ? const SizedBox.shrink()
                  : IconButton(
                    onPressed: () {
                      Navigator.pushNamed(context, AppRoutes.update);
                    },
                    icon: Icon(
                      // Icons.account_circle,
                      Icons.update,
                      color: MyColors.lightGray,
                      size: 25,
                    ),
                  ),
              IconButton(
                icon: const Icon(
                  Icons.logout,
                  color: MyColors.lightGray,
                  size: 25,
                ),

                onPressed: () async {
                  final prefs = await SharedPreferences.getInstance();
                  await prefs.remove('ci');
                  // ignore: use_build_context_synchronously
                  Navigator.of(context).pushReplacementNamed(AppRoutes.logIn);
                },
              ),
              IconButton(
                onPressed: () {
                  Navigator.pushNamed(context, AppRoutes.matches);
                },
                icon: const Icon(
                  Icons.cloud_upload,
                  color: MyColors.lightGray,
                  size: 25,
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
            children: [SignalOff(), AmistosoPage(), const PartidoPage()],
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
            icon: Icon(Icons.sports_esports),
            label: 'Duelo',
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
