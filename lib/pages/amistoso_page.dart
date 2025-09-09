import 'package:flutter/material.dart';
import 'package:marcador/config/app_routes.dart';
import 'package:marcador/widget/jugador_dropdown.dart';
import 'package:marcador/models/jugadores.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AmistosoPage extends StatefulWidget {
  const AmistosoPage({super.key});

  @override
  State<AmistosoPage> createState() => _AmistosoPageState();
}

class _AmistosoPageState extends State<AmistosoPage> {
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
    Navigator.pushNamed(context, AppRoutes.marcadorVertical);
  }

  Jugador? _player1Seleccionado;
  Jugador? _player2Seleccionado;

  @override
   Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return Container(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Nombres de jugadores
          const Text(
            "Selecciona Jugador 1",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          JugadorDropdown(
            selectedItem: _player1Seleccionado,
            onChanged: (jugador) {
              setState(() {
                _player1Seleccionado = jugador;
                _player1Controller.text = jugador?.nombreCompleto ?? '';
              });
            },
          ),
          const SizedBox(height: 15),
          const Text(
            "Selecciona Jugador 2",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          JugadorDropdown(
            selectedItem: _player2Seleccionado,
            onChanged: (jugador) {
              setState(() {
                _player2Seleccionado = jugador;
                _player2Controller.text = jugador?.nombreCompleto ?? '';
              });
            },
          ),

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
    );
  }
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text('Pantalla de Inicio', style: TextStyle(fontSize: 30)),
    );
  }
}

// Pantalla de ejemplo para la navegación
class SettingsScreen extends StatelessWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text('Pantalla de Configuración', style: TextStyle(fontSize: 30)),
    );
  }
}
