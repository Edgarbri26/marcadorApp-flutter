import 'package:flutter/material.dart';
import 'package:marcador/config/app_routes.dart';
import 'package:marcador/design/my_colors.dart';

import 'package:marcador/design/type_button.dart';
import 'package:marcador/models/tournament.dart';
import 'package:marcador/services/api_services.dart';
import 'package:marcador/widget/match_dropdown.dart';
import 'package:marcador/widget/button_app.dart';
import 'package:marcador/models/match.dart';
import 'package:marcador/models/jugador.dart';
import 'package:marcador/widget/double_auth_dialog.dart';
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
  Match? _matchSelect;
  bool _isLoading = true;
  List<Tournament> _tournaments = [];
  int? selectedTournament;
  Key _matchDropdownKey = UniqueKey();

  @override
  void initState() {
    super.initState();
    _loadSettings(); // Cargar datos guardados
  }

  /// Cargar ajustes desde SharedPreferences
  Future<void> _loadSettings() async {
    List<Tournament> tournaments = await ApiService().fetchTournaments();
    print('Torneos cargados: ${tournaments.length}');
    setState(() {
      _tournaments = tournaments;
      _isLoading = false;
    });
  }

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

    // AUTH CHECK
    if (_matchSelect != null) {
      final prefs = await SharedPreferences.getInstance();
      final rawCurrentCI = prefs.getString('ci');
      final rawSessionCI = prefs.getString('session_ci');

      // Use ci (auto-login) or session_ci (current active session)
      final currentCI = (rawCurrentCI ?? rawSessionCI)?.trim();

      final admins = await ApiService().loadAuthorizedCI();
      final isAdmin =
          currentCI != null &&
          admins.any((adminCi) => adminCi.trim() == currentCI);

      if (!isAdmin) {
        final p1 = Jugador(
          ci: _matchSelect!.ci1!,
          nombreCompleto: _matchSelect!.nombre1 ?? 'Jugador 1',
          status: true,
        );
        final p2 = Jugador(
          ci: _matchSelect!.ci2!,
          nombreCompleto: _matchSelect!.nombre2 ?? 'Jugador 2',
          status: true,
        );

        // Determine which players need authentication (skip if it's the current user)
        // Trim CIs to ensure no whitespace issues
        final p1ToAuth = (p1.ci.trim() != currentCI) ? p1 : null;
        final p2ToAuth = (p2.ci.trim() != currentCI) ? p2 : null;

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
            return; // Failed auth
          }
        }
      }
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Cargado: ${_player1Controller.text} vs ${_player2Controller.text} | '
          'Puntos: ${_matchSelect!.setsSelected} | Sets: ${_matchSelect!.pointsSelected}',
        ),
      ),
    );
    // Navegar y esperar resultado de la pantalla de marcador
    final resultado = await Navigator.of(
      context,
    ).pushNamed(AppRoutes.markerTournament, arguments: _matchSelect);

    // Si la pantalla hija no devolvió un valor booleano true para "mantener",
    // limpiamos la selección y los controles (convención: null o false => limpiar)
    if (resultado != true) {
      setState(() {
        _matchSelect = null;
        _player1Controller.clear();
        _player2Controller.clear();
        _matchDropdownKey = UniqueKey();
      });
    }
  }

  void _calculatePoints() {
    if (_matchSelect != null) {
      String round = _matchSelect!.round.toLowerCase();
      if (round == 'semifinal' || round == 'final') {
        _matchSelect!.setsSelected = 5;
        _matchSelect!.pointsSelected = 11;
      } else if (round == 'ronda 3' ||
          round == 'ronda 2' ||
          round == 'octavos de Final' ||
          round == 'cuartos de Final') {
        _matchSelect!.setsSelected = 3;
        _matchSelect!.pointsSelected = 11;
      } else if (round == 'competitivo') {
        _matchSelect!.setsSelected = 1;
        _matchSelect!.pointsSelected = 11;
      } else {
        _matchSelect!.setsSelected = 3;
        _matchSelect!.pointsSelected = 7;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Título header
          const Text(
            "Selección de Partido",
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: MyColors.light,
            ),
          ),
          const SizedBox(height: 20),

          // Sección de Selección de Torneo
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: MyColors.dark,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: MyColors.secundary.withOpacity(0.5)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.emoji_events, color: MyColors.secundary),
                    const SizedBox(width: 10),
                    const Text(
                      "Torneo",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: MyColors.secundary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 15),
                DropdownButtonFormField<int>(
                  isExpanded: true,
                  value: selectedTournament,
                  items:
                      _tournaments.map((Tournament t) {
                        return DropdownMenuItem<int>(
                          value: t.tournamentId,
                          child: Text(
                            t.name,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(color: MyColors.light),
                          ),
                        );
                      }).toList(),
                  style: const TextStyle(color: MyColors.light),
                  dropdownColor: MyColors.dark,
                  decoration: InputDecoration(
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 15,
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: MyColors.lightGray),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: MyColors.secundary),
                    ),
                    filled: true,
                    fillColor: Colors.black12,
                  ),
                  hint: const Text(
                    "Selecciona un torneo",
                    style: TextStyle(color: MyColors.lightGray),
                  ),
                  onChanged: (newValue) {
                    setState(() {
                      selectedTournament = newValue!;
                    });
                  },
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // Sección de Selección de Partido
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: MyColors.dark,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: MyColors.primary.withOpacity(0.5)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.sports_tennis, color: MyColors.primary),
                    const SizedBox(width: 10),
                    const Text(
                      "Partido",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: MyColors.primary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 15),
                MatchDropdown(
                  key: _matchDropdownKey,
                  selectedItem: _matchSelect,
                  filtroTournament:
                      selectedTournament, //INGRESA EL ID DEL TORNEO PARA FILTRAR
                  onChanged: (match) {
                    if (match == null) return;

                    setState(() {
                      _matchSelect = match;
                      _player1Controller.text = match.nombre1 ?? '';
                      _player2Controller.text = match.nombre2 ?? '';
                      _calculatePoints();
                    });
                  },
                ),
              ],
            ),
          ),

          const SizedBox(height: 40),

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
              typeButton: TypeButton.secundary,
            ),
          ),
        ],
      ),
    );
  }
}
