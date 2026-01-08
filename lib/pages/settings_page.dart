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
import 'package:material_symbols_icons/symbols.dart';
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

  int _selectedIndex = 1;
  String title = 'Duelos';

  // Índice inicial en Configuración
  void _onItemTapped(int index) {
    if (index == 0) {
      title = 'Partido sin conexion';
    } else if (index == 1) {
      title = 'Duelos';
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
          statusBarIconBrightness: Brightness.light,
        ),
        title: Text(
          title,
          style: const TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: MyColors.light,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            borderRadius: const BorderRadius.only(
              bottomLeft: Radius.circular(20),
              bottomRight: Radius.circular(20),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.3),
                blurRadius: 10,
                offset: const Offset(0, 5),
              ),
            ],
            gradient: const LinearGradient(
              colors: [MyColors.secundary, MyColors.secundaryContraste],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        actions: [
          if (!kIsWeb)
            IconButton(
              onPressed: () {
                Navigator.pushNamed(context, AppRoutes.update);
              },
              icon: const Icon(Icons.update, color: MyColors.light, size: 28),
              tooltip: 'Buscar Actualización',
            ),
          IconButton(
            onPressed: () {
              Navigator.pushNamed(context, AppRoutes.matches);
            },
            icon: const Icon(
              Icons.cloud_upload,
              color: MyColors.light,
              size: 28,
            ),
            tooltip: 'Sincronizar Partidos',
          ),
          IconButton(
            onPressed: () async {
              final prefs = await SharedPreferences.getInstance();
              await prefs.remove('ci');
              await prefs.remove('session_ci'); // Clear active session
              if (mounted) {
                Navigator.of(context).pushReplacementNamed(AppRoutes.logIn);
              }
            },
            icon: const Icon(Icons.logout, color: MyColors.light, size: 28),
            tooltip: 'Cerrar Sesión',
          ),
          const SizedBox(width: 8),
        ],
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

      bottomNavigationBar: NavigationBarTheme(
        data: NavigationBarThemeData(
          indicatorColor: MyColors.secundary.withOpacity(0.2),
          labelTextStyle: MaterialStateProperty.all(
            const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: MyColors.lightGray,
            ),
          ),
          iconTheme: MaterialStateProperty.resolveWith((states) {
            if (states.contains(MaterialState.selected)) {
              return const IconThemeData(color: MyColors.secundary);
            }
            return const IconThemeData(color: MyColors.lightGray);
          }),
        ),
        child: NavigationBar(
          height: 70,
          backgroundColor: MyColors.darkUltra,
          elevation: 10,
          selectedIndex: _selectedIndex,
          onDestinationSelected: _onItemTapped,
          destinations: const [
            NavigationDestination(
              icon: Icon(Icons.wifi_off_outlined),
              selectedIcon: Icon(Icons.wifi_off),
              label: 'Sin conexión',
            ),
            NavigationDestination(
              icon: Icon(Symbols.swords),
              selectedIcon: Icon(Symbols.swords, fill: 1),
              label: 'Duelo',
            ),
            NavigationDestination(
              icon: Icon(Icons.emoji_events_outlined),
              selectedIcon: Icon(Icons.emoji_events),
              label: 'Torneo',
            ),
          ],
        ),
      ),
    );
  }
}
