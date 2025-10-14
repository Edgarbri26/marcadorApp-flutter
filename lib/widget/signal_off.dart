import 'package:flutter/material.dart';
import 'package:marcador/config/app_routes.dart';
import 'package:marcador/design/my_colors.dart';
import 'package:marcador/design/type_button.dart';
import 'package:marcador/widget/button_app.dart';
import 'package:marcador/widget/set_and_points_selet.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SignalOff extends StatefulWidget {
  const SignalOff({super.key});

  @override
  State<SignalOff> createState() => _SignalOffState();
}

class _SignalOffState extends State<SignalOff> {
  // Controladores para nombres
  final TextEditingController _player1Controller = TextEditingController();
  final TextEditingController _player2Controller = TextEditingController();
  int targetPoints = 11;
  int targetSets = 3;

  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadSettings(); // Cargar datos guardados
  }

  /// Cargar ajustes desde SharedPreferences
  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();

    setState(() {
      _player1Controller.text = prefs.getString('player1') ?? '';
      _player2Controller.text = prefs.getString('player2') ?? '';
      _isLoading = false;
    });
  }

  /// Guardar ajustes en SharedPreferences
  Future<void> _saveSettings() async {
    if (_player1Controller.text.isEmpty || _player2Controller.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Por favor ingresa el nombre de ambos jugadores'),
          backgroundColor: MyColors.secundary,
        ),
      );
      // Navigator.pushNamed(context, AppRoutes.marcadorVertical);
      return;
    }

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('player1', _player1Controller.text);
    await prefs.setString('player2', _player2Controller.text);
    // await prefs.setInt('points', widget.marker.targetPoints);
    // await prefs.setInt('sets', widget.marker.targetSets);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Guardado: ${_player1Controller.text} vs ${_player2Controller.text} | '
          'Puntos: $targetPoints | Sets: $targetSets',
        ),
      ),
    );
    Navigator.pushNamed(context, AppRoutes.markerOffLine);
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Nombres de jugadores
          const Text(
            "Nombres de los jugadores",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: MyColors.light,
            ),
          ),
          const SizedBox(height: 10),
          TextField(
            controller: _player1Controller,
            cursorColor: MyColors.secundary,
            style: TextStyle(color: MyColors.light),
            decoration: const InputDecoration(
              labelText: "Jugador 1",
              labelStyle: TextStyle(color: MyColors.lightGray),
              prefixIcon: Icon(Icons.person, color: MyColors.lightGray),
              focusedBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: MyColors.secundary),
              ),
            ),
          ),
          const SizedBox(height: 15),
          TextField(
            controller: _player2Controller,
            cursorColor: MyColors.secundary,
            style: TextStyle(color: MyColors.light),
            decoration: const InputDecoration(
              labelText: "Jugador 2",
              labelStyle: TextStyle(color: MyColors.lightGray),
              prefixIcon: Icon(Icons.person_outline, color: MyColors.lightGray),
              focusedBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: MyColors.secundary),
              ),
            ),
          ),
          const SizedBox(height: 30),

          SetAndPointsSelet(targetPoints: targetPoints, targetSets: targetSets),

          // Botón de JUgar
          Center(
            child: ButtonApp(
              onPressed: _saveSettings,
              title: 'Comenzar juego',
              icon: Icon(Icons.play_arrow_rounded, color: MyColors.light),
              typeButton: TypeButton.secundary,
            ),
          ),
        ],
      ),
    );
  }
}
