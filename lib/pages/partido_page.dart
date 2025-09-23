import 'package:flutter/material.dart';
import 'package:marcador/config/app_routes.dart';
import 'package:marcador/design/my_colors.dart';
import 'package:marcador/design/spacing.dart';
import 'package:marcador/design/type_button.dart';
import 'package:marcador/services/marker.dart';
import 'package:marcador/widget/match_dropdown.dart';
import 'package:marcador/widget/button_app.dart';
import 'package:marcador/models/jugador.dart';
import 'package:marcador/models/match.dart';
import 'package:marcador/widget/set_and_points_selet.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PartidoPage extends StatefulWidget {
  const PartidoPage({super.key});

  @override
  State<PartidoPage> createState() => _PartidoPageState();
}

class _PartidoPageState extends State<PartidoPage> {
  // Controladores para nombres
  final TextEditingController _player1Controller = TextEditingController();
  final TextEditingController _player2Controller = TextEditingController();

  // Valores iniciales para puntos y sets
  int _selectedPoints = 5;
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
      _selectedPoints = prefs.getInt('points') ?? 5;
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
          backgroundColor: MyColors.secundary,
        ),
      );
      Navigator.pushNamed(context, AppRoutes.marcadorVertical);
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

  Match? _matchSelect;

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
            "Selecciona un partido",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: MyColors.lightGray,
            ),
          ),
          const SizedBox(height: Spacing.xl),
          MatchDropdown(
            selectedItem: _matchSelect,
            onChanged: (match) {
              setState(() {
                _matchSelect = match;
                _player1Controller.text = match?.nombre1?? '';
                _player2Controller.text = match?.nombre2?? '';
              });
            },
          ),
          const SizedBox(height: Spacing.xl),
          //SetAndPointsSelet(marker: Marker(),),
          const SizedBox(height: Spacing.xl),

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
