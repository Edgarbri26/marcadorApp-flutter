import 'package:flutter/material.dart';
import 'package:marcador/config/app_routes.dart';
import 'package:marcador/widget/jugador_dropdown.dart';
import 'package:shared_preferences/shared_preferences.dart';

class GameSettingsPage extends StatefulWidget {
  const GameSettingsPage({super.key});

  @override
  _GameSettingsPageState createState() => _GameSettingsPageState();
}

class _GameSettingsPageState extends State<GameSettingsPage> {
  // Controladores para nombres
  final TextEditingController _player1Controller = TextEditingController();
  final TextEditingController _player2Controller = TextEditingController();

  // Valores iniciales para puntos y sets
  int _selectedPoints = 11;
  int _selectedSets = 3;

  // Opciones disponibles
  final List<int> pointsOptions = [7, 11, 15, 21];
  final List<int> setsOptions = [1, 3, 5, 7];

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
      _selectedPoints = prefs.getInt('points') ?? 11;
      _selectedSets = prefs.getInt('sets') ?? 3;
      _isLoading = false;
    });
  }

  /// Guardar ajustes en SharedPreferences
  Future<void> _saveSettings() async {
    if (_player1Controller.text.isEmpty || _player2Controller.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Por favor ingresa el nombre de ambos jugadores'),
          backgroundColor: Colors.redAccent,
        ),
      );
      // Navigator.pushNamed(context, AppRoutes.marcadorVertical);
      return;
    }

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('player1', _player1Controller.text);
    await prefs.setString('player2', _player2Controller.text);
    await prefs.setInt('points', _selectedPoints);
    await prefs.setInt('sets', _selectedSets);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Guardado: ${_player1Controller.text} vs ${_player2Controller.text} | '
          'Puntos: $_selectedPoints | Sets: $_selectedSets',
        ),
      ),
    );

    // Navigator.pop(context, {
    //   'player1': _player1Controller.text,
    //   'player2': _player2Controller.text,
    //   'points': _selectedPoints,
    //   'sets': _selectedSets,
    // });
    Navigator.pushNamed(context, AppRoutes.marcadorVertical);
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text("Ajustes del Juego"),
        centerTitle: true,
        backgroundColor: Colors.deepPurple,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Nombres de jugadores
            const Text(
              "Nombres de los jugadores",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _player1Controller,
              decoration: const InputDecoration(
                labelText: "Jugador 1",
                prefixIcon: Icon(Icons.person),
              ),
            ),
            const SizedBox(height: 15),
            TextField(
              controller: _player2Controller,
              decoration: const InputDecoration(
                labelText: "Jugador 2",
                prefixIcon: Icon(Icons.person_outline),
              ),
            ),
            const SizedBox(height: 30),

            // Selección de puntos
            const Text(
              "Cantidad de puntos por set",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            DropdownButtonFormField<int>(
              value: _selectedPoints,
              items:
                  pointsOptions.map((int value) {
                    return DropdownMenuItem<int>(
                      value: value,
                      child: Text("$value puntos"),
                    );
                  }).toList(),
              decoration: const InputDecoration(prefixIcon: Icon(Icons.sports)),
              onChanged: (newValue) {
                setState(() {
                  _selectedPoints = newValue!;
                });
              },
            ),
            const SizedBox(height: 30),

            const Text(
              "Selecciona el jugador",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            JugadorDropdown(),
            const SizedBox(height: 30),

            // Selección de sets
            const Text(
              "Cantidad de sets",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            DropdownButtonFormField<int>(
              value: _selectedSets,
              items:
                  setsOptions.map((int value) {
                    return DropdownMenuItem<int>(
                      value: value,
                      child: Text("$value sets"),
                    );
                  }).toList(),
              decoration: const InputDecoration(
                prefixIcon: Icon(Icons.format_list_numbered),
              ),
              onChanged: (newValue) {
                setState(() {
                  _selectedSets = newValue!;
                });
              },
            ),
            const SizedBox(height: 40),

            // Botón de guardar
            Center(
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepPurple,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 30,
                    vertical: 14,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                icon: const Icon(Icons.save, color: Colors.white),
                label: const Text(
                  "Guardar ajustes",
                  style: TextStyle(fontSize: 16, color: Colors.white),
                ),
                onPressed: _saveSettings,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
