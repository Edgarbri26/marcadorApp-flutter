import 'package:flutter/material.dart';
import 'package:marcador/config/app_routes.dart';
import 'package:marcador/design/my_colors.dart';
import 'package:marcador/design/type_button.dart';
import 'package:marcador/models/jugador.dart';
import 'package:marcador/widget/button_app.dart';
import 'package:marcador/widget/jugador_dropdown.dart';
import 'package:marcador/widget/set_and_points_selet.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SignalOff extends StatefulWidget {
  final bool isOfflineMode;
  const SignalOff({super.key, this.isOfflineMode = false});

  @override
  State<SignalOff> createState() => _SignalOffState();
}

class _SignalOffState extends State<SignalOff> {
  // Controladores para nombres
  final TextEditingController _player1Controller = TextEditingController();
  final TextEditingController _player2Controller = TextEditingController();
  Jugador? _player1Seleccionado;
  Jugador? _player2Seleccionado;
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
      _player1Controller.text = prefs.getString('player1') ?? 'player1';
      _player2Controller.text = prefs.getString('player2') ?? 'player2';
      targetPoints = prefs.getInt('points') ?? 11;
      targetSets = prefs.getInt('sets') ?? 3;
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
    await prefs.setInt('points', targetPoints);
    await prefs.setInt('sets', targetSets);
    print('DEBUG: Saving settings - Points: $targetPoints, Sets: $targetSets');

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
          // Título Principal
          const Text(
            "Configuración del Partido",
            style: TextStyle(
              fontSize: 28, // 24 -> 28
              fontWeight: FontWeight.bold,
              color: MyColors.light,
            ),
          ),
          const SizedBox(height: 20),

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
                        controller: _player1Controller,
                        selectedPlayer: _player1Seleccionado,
                        onPlayerChanged: (jugador) {
                          setState(() {
                            _player1Seleccionado = jugador;
                            if (jugador != null) {
                              _player1Controller.text = jugador.nombreCompleto;
                            }
                          });
                        },
                      ),
                    ),
                    const SizedBox(width: 20),
                    Expanded(
                      child: _buildPlayerSection(
                        label: "Jugador 2",
                        color: MyColors.primary,
                        controller: _player2Controller,
                        selectedPlayer: _player2Seleccionado,
                        onPlayerChanged: (jugador) {
                          setState(() {
                            _player2Seleccionado = jugador;
                            if (jugador != null) {
                              _player2Controller.text = jugador.nombreCompleto;
                            }
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
                      controller: _player1Controller,
                      selectedPlayer: _player1Seleccionado,
                      onPlayerChanged: (jugador) {
                        setState(() {
                          _player1Seleccionado = jugador;
                          if (jugador != null) {
                            _player1Controller.text = jugador.nombreCompleto;
                          }
                        });
                      },
                    ),
                    const SizedBox(height: 20),
                    _buildPlayerSection(
                      label: "Jugador 2",
                      color: MyColors.primary,
                      controller: _player2Controller,
                      selectedPlayer: _player2Seleccionado,
                      onPlayerChanged: (jugador) {
                        setState(() {
                          _player2Seleccionado = jugador;
                          if (jugador != null) {
                            _player2Controller.text = jugador.nombreCompleto;
                          }
                        });
                      },
                    ),
                  ],
                );
              }
            },
          ),
          const SizedBox(height: 30),

          // Configuración de Puntos y Sets
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

          const SizedBox(height: 40),

          // Botón de Jugar
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
              typeButton: TypeButton.secundary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlayerSection({
    required String label,
    required Color color,
    required TextEditingController controller,
    required Jugador? selectedPlayer,
    required ValueChanged<Jugador?> onPlayerChanged,
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
              const SizedBox(width: 8),
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
          const SizedBox(height: 16),
          if (!widget.isOfflineMode) ...[
            JugadorDropdown(
              selectedItem: selectedPlayer,
              onChanged: onPlayerChanged,
            ),
            const SizedBox(height: 12),
          ],
          TextField(
            controller: controller,
            cursorColor: color,
            style: const TextStyle(color: MyColors.light),
            decoration: InputDecoration(
              labelText: "Nombre personalizado / Alias",
              labelStyle: const TextStyle(color: MyColors.lightGray),
              prefixIcon: Icon(Icons.edit, color: MyColors.lightGray),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: MyColors.lightGray),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: color),
              ),
              filled: true,
              fillColor: Colors.black12,
            ),
          ),
        ],
      ),
    );
  }
}
