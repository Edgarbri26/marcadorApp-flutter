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
import 'package:marcador/widget/set_and_points_selet.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';
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

  int targetPoints = 11;
  int targetSets = 3;

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    targetPoints = prefs.getInt('points') ?? 11;
    targetSets = prefs.getInt('sets') ?? 1;

    setState(() {
      targetPoints = prefs.getInt('points') ?? 11;
      targetSets = prefs.getInt('sets') ?? 1;
    });
  }

  Jugador? _player1Seleccionado;
  Jugador? _player2Seleccionado;

  bool ifRanked = false;

  int tournament = 1; // ID fijo para torneo amistoso

  String nameMode = "Amistoso";

  @override
  void initState() {
    super.initState();
    _loadSettings(); // Cargar datos guardados
  }

  Future<void> _saveSetAndPointsSelec() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('points', targetPoints);
    await prefs.setInt('sets', targetSets);
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

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Guardado: ${_player1Controller.text} vs ${_player2Controller.text} | '
          'Puntos: ${targetPoints} | Sets: ${targetSets}',
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

    if (!ifRanked) {
      tournament = 1; // ID fijo para torneo amistoso
    } else {
      tournament = 2; // ID fijo para torneo competitivo
    }

    Match match = Match(
      matchId: null,
      tournamentId: tournament, // ID fijo para amistoso
      inscription1Id: inscrip1,
      inscription2Id: inscrip2,
      round: nameMode,
      status: 'En Juego',
      date: DateTime.now().toIso8601String(),
      nombre1: _player1Controller.text,
      nombre2: _player2Controller.text,
      pointsSelected: targetPoints,
      setsSelected: targetSets,
    );

    print("torneo asignado: ${match.tournamentId}");

    final nuevoMatchId = await ApiService().createMatch(match);
    if (nuevoMatchId != null) {
      match.matchId = nuevoMatchId;
    }

    Navigator.of(
      context,
    ).pushNamed(AppRoutes.markerTournament, arguments: match);
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Icon(
                  Symbols.handshake,
                  color: ifRanked ? Colors.grey : MyColors.secundary,
                ),
                Text(
                  'Amistoso',
                  style: TextStyle(
                    color: ifRanked ? Colors.grey : MyColors.secundary,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                Switch(
                  activeThumbColor: MyColors.primary,
                  inactiveThumbColor: MyColors.secundaryContraste,
                  inactiveTrackColor: MyColors.secundary,
                  value: ifRanked,
                  onChanged: (bool value) {
                    setState(() {
                      ifRanked = value;
                      // Aquí puedes activar lógica según el modo
                      if (ifRanked) {
                        nameMode = "Competitivo";
                      } else {
                        nameMode = "Amistoso";
                      }
                    });
                  },
                ),
                Text(
                  'Ranked',
                  style: TextStyle(
                    color: !ifRanked ? Colors.grey : MyColors.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                Icon(
                  Symbols.swords,
                  color: !ifRanked ? Colors.grey : MyColors.primary,
                ),
              ],
            ),
          ),

          const SizedBox(height: Spacing.xl),

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

          SetAndPointsSelet(
            targetPoints: targetPoints,
            targetSets: targetSets,
            onSelectedSave: _saveSetAndPointsSelec,
          ),

          Center(
            child: ButtonApp(
              onPressed: _saveSettings,
              title: 'Comenzar juego',
              icon: const Icon(Icons.play_arrow_rounded, color: MyColors.light),
              typeButton: !ifRanked ? TypeButton.secundary : TypeButton.primary,
            ),
          ),
        ],
      ),
    );
  }
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text('Pantalla de Inicio', style: TextStyle(fontSize: 30)),
    );
  }
}
