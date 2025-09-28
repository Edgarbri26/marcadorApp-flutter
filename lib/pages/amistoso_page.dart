import 'package:flutter/material.dart';
import 'package:marcador/config/app_routes.dart';
import 'package:marcador/design/my_colors.dart';
import 'package:marcador/design/spacing.dart';
import 'package:marcador/design/type_button.dart';
import 'package:marcador/services/api_services.dart';
import 'package:marcador/widget/button_app.dart';
import 'package:marcador/widget/jugador_dropdown.dart';
import 'package:marcador/models/jugador.dart';
import 'package:marcador/models/match.dart';
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

  Jugador? _player1Seleccionado;
  Jugador? _player2Seleccionado;

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

    final inscrip1 = await ApiService().obtenerInscriptionIdPorCI(
      _player1Seleccionado!,
    );
    final inscrip2 = await ApiService().obtenerInscriptionIdPorCI(
      _player2Seleccionado!,
    );

    if (inscrip1 == null || inscrip2 == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'No se pudo obtener la inscripción de uno o ambos jugadores',
          ),
          backgroundColor: MyColors.secundary,
        ),
      );
      return;
    }
    Match match = Match(
      matchId: null,
      tournamentId: 1, // ID fijo para amistoso
      inscription1Id: inscrip1,
      inscription2Id: inscrip2,
      round: 'Amistoso',
      status: 'En Juego',
      date: DateTime.now().toIso8601String(),
      nombre1: _player1Controller.text,
      nombre2: _player2Controller.text,
    );

    final nuevoMatchId = await ApiService().createMatch(match);
    if (nuevoMatchId != null) {
      match.matchId = nuevoMatchId;
    }

    Navigator.of(
      context,
    ).pushNamed(AppRoutes.markerTournament, arguments: match);
  }

  // Jugador? _player1Seleccionado;
  // Jugador? _player2Seleccionado;

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
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: MyColors.lightGray,
            ),
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
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: MyColors.lightGray,
            ),
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

class HomeScreen extends StatelessWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text('Pantalla de Inicio', style: TextStyle(fontSize: 30)),
    );
  }
}
