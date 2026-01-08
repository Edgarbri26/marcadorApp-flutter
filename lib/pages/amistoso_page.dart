import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:marcador/config/app_routes.dart';
import 'package:marcador/design/my_colors.dart';
import 'package:marcador/design/spacing.dart';
import 'package:marcador/design/type_button.dart';
import 'package:marcador/models/match_repository.dart';
import 'package:marcador/widget/button_app.dart';
import 'package:marcador/widget/jugador_dropdown.dart';
import 'package:marcador/models/jugador.dart';
import 'package:marcador/models/match.dart';
import 'package:marcador/widget/set_and_points_selet.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';

class AmistosoPage extends StatefulWidget {
  const AmistosoPage({super.key});

  @override
  State<AmistosoPage> createState() => _AmistosoPageState();
}

class _AmistosoPageState extends State<AmistosoPage> {
  // Controladores para nombres
  final TextEditingController _player1Controller = TextEditingController();
  final TextEditingController _player2Controller = TextEditingController();
  final MatchRepository _repo = MatchRepository();

  int targetPoints = 11;
  int targetSets = 1;

  // Future<void> _loadSettings() async {
  //   final prefs = await SharedPreferences.getInstance();
  //   targetPoints = prefs.getInt('points') ?? 11;
  //   targetSets = prefs.getInt('sets') ?? 1;

  //   setState(() {
  //     targetPoints = prefs.getInt('points') ?? 11;
  //     targetSets = prefs.getInt('sets') ?? 1;
  //   });
  // }

  Jugador? _player1Seleccionado;
  Jugador? _player2Seleccionado;

  bool ifRanked = true;

  int tournament = 1; // ID fijo para torneo amistoso

  String nameMode = "Amistoso";

  @override
  void initState() {
    super.initState();
    Connectivity().onConnectivityChanged.listen((status) {
      print('🔄 Cambio en el estado de conectividad: $status');
      if (status != ConnectivityResult.none) {
        // _syncAllMatches(); // sube automáticamente al tener conexión
        print('📶 Conexión disponible, intentando sincronizar partidos...');
      }
    });
  }

  void _syncAllMatches() async {
    final unsyncedMatches = _repo.getUnsyncedMatches();
    // if (unsyncedMatches.isEmpty) {
    //   ScaffoldMessenger.of(context).showSnackBar(
    //     const SnackBar(
    //       content: Text('No hay partidos pendientes de sincronización.'),
    //     ),
    //   );
    //   return;
    // }

    for (final match in unsyncedMatches) {
      // _attemptSync(match);
    }
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Sincronizando todos los partidos.')),
    );
  }

  // void _attemptSync(MatchSave match) async {
  //   try {
  //     for (final set in match.setsResults) {
  //       await ApiService().postSet(set);
  //     }
  //     final Response = await ApiService().putMatch(match);

  //     // Si todo va bien, marcar como sincronizado
  //     if (Response) {
  //       await _repo.markMatchAsSynced(match);
  //       setState(() {}); // Refrescar la UI
  //       ScaffoldMessenger.of(context).showSnackBar(
  //         SnackBar(
  //           content: Text(
  //             'Partido ID ${match.matchId} sincronizado con éxito!',
  //           ),
  //         ),
  //       );
  //     } else {
  //       throw Exception('Error en la respuesta del servidor');
  //     }

  //     // ignore: use_build_context_synchronously
  //   } catch (e) {
  //     // Simulación de error (por ejemplo, si no hay conexión real)
  //     // ignore: use_build_context_synchronously
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       SnackBar(
  //         content: Text(
  //           'Error al sincronizar partido ID ${match.matchId}. Inténtalo de nuevo.',
  //         ),
  //       ),
  //     );
  //   }
  // }

  /// Guardar ajustes en SharedPreferences
  Future<void> _saveSettings() async {
    //para sincronizar los partidos pendientes
    // _syncAllMatches();
    if (_player1Controller.text.isEmpty || _player2Controller.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Por favor ingresa el nombre de ambos jugadores'),
          backgroundColor: MyColors.secundary,
        ),
      );

      return;
    }

    if (_player1Controller.text == _player2Controller.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Elige dos jugadores distintos'),
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

    if (!ifRanked) {
      tournament = 1; // ID fijo para torneo amistoso
      nameMode = "Amistoso";
    } else {
      tournament = 2; // ID fijo para torneo competitivo
      nameMode = "Competitivo";
    }

    Match match = Match(
      ci1: _player1Seleccionado!.ci,
      ci2: _player2Seleccionado!.ci,
      matchId: null,
      tournamentId: tournament, // ID fijo para amistoso
      inscription1Id: null,
      inscription2Id: null,
      round: nameMode,
      status: 'En Juego',
      date: DateTime.now().toIso8601String(),
      nombre1: _player1Controller.text,
      nombre2: _player2Controller.text,
      pointsSelected: targetPoints,
      setsSelected: targetSets,
    );

    print("torneo asignado: ${match.tournamentId}");

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
          // Switch de Ranked/Amistoso
          Container(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            decoration: BoxDecoration(
              color: MyColors.dark,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: ifRanked ? MyColors.primary : MyColors.secundary,
                width: 1,
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(
                      Symbols.handshake,
                      color: ifRanked ? Colors.grey : MyColors.secundary,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Amistoso',
                      style: TextStyle(
                        color: ifRanked ? Colors.grey : MyColors.secundary,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
                Switch(
                  activeColor: MyColors.primary,
                  activeTrackColor: MyColors.primary.withOpacity(0.5),
                  inactiveThumbColor: MyColors.secundary,
                  inactiveTrackColor: MyColors.secundary.withOpacity(0.5),
                  value: ifRanked,
                  onChanged: (bool value) {
                    setState(() {
                      ifRanked = value;
                    });
                  },
                ),
                Row(
                  children: [
                    Text(
                      'Ranked',
                      style: TextStyle(
                        color: !ifRanked ? Colors.grey : MyColors.primary,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Icon(
                      Symbols.swords,
                      color: !ifRanked ? Colors.grey : MyColors.primary,
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 25),

          // Seleccion Jugador 1
          _buildPlayerSection(
            label: "Jugador 1",
            color: MyColors.secundary,
            selectedPlayer: _player1Seleccionado,
            onChanged: (jugador) {
              setState(() {
                _player1Seleccionado = jugador;
                _player1Controller.text = jugador?.nombreCompleto ?? '';
              });
            },
          ),

          const SizedBox(height: 20),

          // Seleccion Jugador 2
          _buildPlayerSection(
            label: "Jugador 2",
            color: MyColors.primary,
            selectedPlayer: _player2Seleccionado,
            onChanged: (jugador) {
              setState(() {
                _player2Seleccionado = jugador;
                _player2Controller.text = jugador?.nombreCompleto ?? '';
              });
            },
          ),
          const SizedBox(height: 25),

          // Configuración Puntos/Sets
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: MyColors.dark,
              borderRadius: BorderRadius.circular(16),
            ),
            child: SetAndPointsSelet(
              targetPoints: targetPoints,
              targetSets: targetSets,
              onPointsChanged: (val) => setState(() => targetPoints = val),
              onSetsChanged: (val) => setState(() => targetSets = val),
            ),
          ),

          const SizedBox(height: 30),

          Center(
            child: ButtonApp(
              onPressed: _saveSettings,
              title: const Text(
                "Comenzar juego",
                style: TextStyle(color: MyColors.lightGray, fontSize: 18),
              ),
              icon: const Icon(
                Icons.play_arrow_rounded,
                color: MyColors.light,
                size: 30,
              ),
              typeButton: !ifRanked ? TypeButton.secundary : TypeButton.primary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlayerSection({
    required String label,
    required Color color,
    required Jugador? selectedPlayer,
    required ValueChanged<Jugador?> onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: MyColors.dark,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.5), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.person, color: color),
              const SizedBox(width: 10),
              Text(
                label,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ],
          ),
          const SizedBox(height: 15),
          JugadorDropdown(selectedItem: selectedPlayer, onChanged: onChanged),
        ],
      ),
    );
  }
}
