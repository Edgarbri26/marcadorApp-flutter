import 'package:flutter/material.dart';
import 'package:marcador/config/app_routes.dart';
import 'package:marcador/design/my_colors.dart';
import 'package:marcador/design/spacing.dart';
import 'package:marcador/design/type_button.dart';
import 'package:marcador/models/tournament.dart';
import 'package:marcador/services/api_services.dart';
import 'package:marcador/widget/match_dropdown.dart';
import 'package:marcador/widget/button_app.dart';
import 'package:marcador/models/match.dart';

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

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Cargado: ${_player1Controller.text} vs ${_player2Controller.text} | '
          'Puntos: ${_matchSelect!.setsSelected} | Sets: ${_matchSelect!.pointsSelected}',
        ),
      ),
    );
    // Navegar y esperar resultado de la pantalla de marcador
    final resultado = await Navigator.of(context).pushNamed(
      AppRoutes.markerTournament,
      arguments: _matchSelect,
    );

    // Si la pantalla hija no devolvió un valor booleano true para "mantener",
    // limpiamos la selección y los controles (convención: null o false => limpiar)
    if (resultado != true) {
      setState(() {
        _matchSelect = null;
        _player1Controller.clear();
        _player2Controller.clear();
      });
    }

  }

  void _calculatePoints() {
    if (_matchSelect != null) {
      if (_matchSelect!.round == 'Semifinal' ||
          _matchSelect!.round == 'Final') {
        _matchSelect!.setsSelected = 5;
        _matchSelect!.pointsSelected = 11;
      } else if (_matchSelect!.round == 'Ronda 3' ||
          _matchSelect!.round == 'Ronda 2' ||
          _matchSelect!.round == 'Octavos de Final' ||
          _matchSelect!.round == 'Cuartos de Final') {
        _matchSelect!.setsSelected = 3;
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
          const Text(
            "Seleccione el torneo",
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: MyColors.lightGray,
            ),
          ),
          DropdownButtonFormField<int>(
            initialValue: selectedTournament,
            items:
                _tournaments.map((Tournament t) {
                  return DropdownMenuItem<int>(
                    value: t.tournamentId,
                    child: Text(t.name),
                  );
                }).toList(),
            style: TextStyle(color: MyColors.light),
            dropdownColor: MyColors.dark,
            decoration: const InputDecoration(
              prefixIcon: Icon(Icons.sports, color: MyColors.light),
              focusedBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: MyColors.secundary),
              ),
            ),
            onChanged: (newValue) {
              setState(() {
                selectedTournament = newValue!;
              });
            },
          ),

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
            filtroTournament: selectedTournament, //INGRESA EL ID DEL TORNEO PARA FILTRAR
            onChanged: (match) {

              if(match == null) return;
              
              setState(() {
                _matchSelect = match;
                _player1Controller.text = match.nombre1 ?? '';
                _player2Controller.text = match.nombre2 ?? '';
                _calculatePoints();
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
