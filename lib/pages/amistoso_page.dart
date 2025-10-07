import 'package:flutter/material.dart';
import 'package:marcador/config/app_routes.dart';
import 'package:marcador/design/my_colors.dart';
import 'package:marcador/design/spacing.dart';
import 'package:marcador/design/type_button.dart';
import 'package:marcador/services/api_services.dart';
import 'package:marcador/services/marker.dart';
import 'package:marcador/widget/button_app.dart';
import 'package:marcador/widget/jugador_dropdown.dart';
import 'package:marcador/models/jugador.dart';
import 'package:marcador/models/match.dart';
import 'package:marcador/widget/set_and_points_selet.dart';

class AmistosoPage extends StatefulWidget {
  final Marker marker;
  const AmistosoPage({super.key, required this.marker});

  @override
  State<AmistosoPage> createState() => _AmistosoPageState();
}

class _AmistosoPageState extends State<AmistosoPage> {
  // Controladores para nombres
  final TextEditingController _player1Controller = TextEditingController();
  final TextEditingController _player2Controller = TextEditingController();

  int pointsSelect = 11;
  int setsSelect = 3;

  Jugador? _player1Seleccionado;
  Jugador? _player2Seleccionado;

  bool ifRanked = false;

  int tournament = 2; // ID fijo para torneo amistoso

  String nameMode = "Amistoso";

  @override
  void initState() {
    super.initState();
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
          'Puntos: ${widget.marker.targetPoints} | Sets: ${widget.marker.targetSets}',
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

    if(ifRanked) {
      tournament = 1; // ID fijo para torneo competitivo
    } else {
      tournament = 2; // ID fijo para torneo amistoso
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
      pointsSelected: widget.marker.targetPoints,
      setsSelected: widget.marker.targetSets,
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

          SetAndPointsSelet(marker: widget.marker),

          SwitchListTile(
              title: Text("Modo $nameMode"),
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
              secondary: Icon(Icons.sports_esports),
            ),
          const SizedBox(height: Spacing.xl),
          Center(
            child:   ButtonApp(
              onPressed: _saveSettings,
              title:  'Comenzar juego',
              icon: const Icon(Icons.play_arrow_rounded, color: MyColors.light),
              typeButton:  TypeButton.secundary,
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
