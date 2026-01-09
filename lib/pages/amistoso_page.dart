import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:marcador/config/app_routes.dart';
import 'package:marcador/design/my_colors.dart';

import 'package:marcador/design/type_button.dart';
import 'package:marcador/models/match_repository.dart';
import 'package:marcador/widget/button_app.dart';
import 'package:marcador/widget/jugador_dropdown.dart';
import 'package:marcador/models/jugador.dart';
import 'package:marcador/models/match.dart';
import 'package:marcador/services/api_services.dart';
import 'package:marcador/widget/double_auth_dialog.dart';
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

  // }
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

    // AUTHENTICATION CHECK
    if (_player1Seleccionado != null || _player2Seleccionado != null) {
      final prefs = await SharedPreferences.getInstance();
      final rawCurrentCI = prefs.getString('ci');
      final rawSessionCI = prefs.getString('session_ci');

      // Use ci (auto-login) or session_ci (current active session)
      final currentCI = (rawCurrentCI ?? rawSessionCI)?.trim();

      final admins = await ApiService().loadAuthorizedCI();
      // Check if current user is admin (trimming both sides for safety)
      final isAdmin =
          currentCI != null &&
          admins.any((adminCi) => adminCi.trim() == currentCI);

      print('=== DEBUG AUTH START ===');
      print('Current User CI: "$currentCI"');
      print('Is Admin Result: $isAdmin');

      if (!isAdmin) {
        // Determine which players need authentication (skip if it's the current user)
        // We trim the player CI as well just in case
        final p1ToAuth =
            (_player1Seleccionado != null &&
                    _player1Seleccionado!.ci.trim() != currentCI)
                ? _player1Seleccionado
                : null;
        final p2ToAuth =
            (_player2Seleccionado != null &&
                    _player2Seleccionado!.ci.trim() != currentCI)
                ? _player2Seleccionado
                : null;

        // Only show dialog if at least one player needs auth
        if (p1ToAuth != null || p2ToAuth != null) {
          final bool? authorized = await showDialog<bool>(
            context: context,
            barrierDismissible: false,
            builder:
                (context) =>
                    DoubleAuthDialog(player1: p1ToAuth, player2: p2ToAuth),
          );

          if (authorized != true) {
            return; // User cancelled or failed auth
          }
        }
      }
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
      ci1: _player1Seleccionado?.ci,
      ci2: _player2Seleccionado?.ci,
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
    print("DEBUG: points=${match.pointsSelected}, sets=${match.setsSelected}");

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
                      size: 28, // Increased icon size
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Amistoso',
                      style: TextStyle(
                        color: ifRanked ? Colors.grey : MyColors.secundary,
                        fontWeight: FontWeight.bold,
                        fontSize: 20, // 16 -> 20
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
                      if (ifRanked) {
                        targetPoints = 11;
                        targetSets = 3;
                      }
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
                        fontSize: 20, // 16 -> 20
                      ),
                    ),
                    const SizedBox(width: 8),
                    Icon(
                      Symbols.swords,
                      color: !ifRanked ? Colors.grey : MyColors.primary,
                      size: 28, // Increased icon size
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 25),

          // Seleccion Jugadores (Responsive)
          LayoutBuilder(
            builder: (context, constraints) {
              if (constraints.maxWidth > 650) {
                // Wide screen: 2 Columns
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: _buildPlayerSection(
                        label: "Jugador 1",
                        color: MyColors.secundary,
                        selectedPlayer: _player1Seleccionado,
                        onChanged: (jugador) {
                          setState(() {
                            _player1Seleccionado = jugador;
                            _player1Controller.text =
                                jugador?.nombreCompleto ?? '';
                          });
                        },
                      ),
                    ),
                    const SizedBox(width: 20),
                    Expanded(
                      child: _buildPlayerSection(
                        label: "Jugador 2",
                        color: MyColors.primary,
                        selectedPlayer: _player2Seleccionado,
                        onChanged: (jugador) {
                          setState(() {
                            _player2Seleccionado = jugador;
                            _player2Controller.text =
                                jugador?.nombreCompleto ?? '';
                          });
                        },
                      ),
                    ),
                  ],
                );
              } else {
                // Narrow screen: 1 Column
                return Column(
                  children: [
                    _buildPlayerSection(
                      label: "Jugador 1",
                      color: MyColors.secundary,
                      selectedPlayer: _player1Seleccionado,
                      onChanged: (jugador) {
                        setState(() {
                          _player1Seleccionado = jugador;
                          _player1Controller.text =
                              jugador?.nombreCompleto ?? '';
                        });
                      },
                    ),
                    const SizedBox(height: 20),
                    _buildPlayerSection(
                      label: "Jugador 2",
                      color: MyColors.primary,
                      selectedPlayer: _player2Seleccionado,
                      onChanged: (jugador) {
                        setState(() {
                          _player2Seleccionado = jugador;
                          _player2Controller.text =
                              jugador?.nombreCompleto ?? '';
                        });
                      },
                    ),
                  ],
                );
              }
            },
          ),
          const SizedBox(height: 25),

          // Configuración Puntos/Sets
          Opacity(
            opacity: ifRanked ? 0.5 : 1.0,
            child: AbsorbPointer(
              absorbing: ifRanked,
              child: Container(
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
            ),
          ),

          const SizedBox(height: 30),

          Center(
            child: ButtonApp(
              onPressed: _saveSettings,
              title: const Text(
                "Comenzar juego",
                style: TextStyle(
                  color: MyColors.lightGray,
                  fontSize: 22,
                ), // 18 -> 22
              ),
              icon: const Icon(
                Icons.play_arrow_rounded,
                color: MyColors.light,
                size: 35, // 30 -> 35
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
              Icon(Icons.person, color: color, size: 28), // Added size
              const SizedBox(width: 10),
              Text(
                label,
                style: TextStyle(
                  fontSize: 22, // 18 -> 22
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
