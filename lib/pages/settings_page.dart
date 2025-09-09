import 'package:flutter/material.dart';
import 'package:marcador/design/my_colors.dart';
import 'package:marcador/design/spacing.dart';
import 'package:marcador/pages/amistoso_page.dart';
import 'package:marcador/services/marker.dart';
import 'package:marcador/widget/signal_off.dart';

class SettingsPage extends StatefulWidget {
  final Marker marker;
  const SettingsPage({super.key, required this.marker});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  int _selectedIndex = 0;
  String title = 'Configuracion de partido';
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

  /// Cargar ajustes desde SharedPreferences

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: MyColors.darkContraste,

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
                onPressed: () {},
                icon: Icon(
                  Icons.account_circle,
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
              colors: [MyColors.primary, MyColors.error],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
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
              const SignalOff(),
              AmistosoPage(),
              const SettingsScreen(),
            ],
          ),
        ),
      ),

      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: MyColors.dark,
        unselectedItemColor: Colors.white70,
        selectedItemColor: MyColors.primary,
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
