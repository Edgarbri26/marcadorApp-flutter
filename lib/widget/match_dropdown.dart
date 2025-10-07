import 'package:flutter/material.dart';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:marcador/design/my_colors.dart';
import 'package:marcador/services/api_services.dart';
import 'package:marcador/models/match.dart';

class MatchDropdown extends StatefulWidget {
  final Match? selectedItem;
  final ValueChanged<Match?> onChanged;
  final int filtroTournament;

  const MatchDropdown({super.key, this.selectedItem, required this.onChanged, required this.filtroTournament});

  @override
  State<MatchDropdown> createState() => _MatchDropdownState();
}

class _MatchDropdownState extends State<MatchDropdown> {
  Match? _matchSeleccionado;
  Map<int, String> _nombresPorInscriptionId = {};

  Future<void> _cargarNombresDeJugadores() async {
    final inscriptions = await ApiService().fetchInscriptions();
    _nombresPorInscriptionId = {
      for (var ins in inscriptions)
        ins.inscriptionId: ins.jugador.nombreCompleto,
    };
  }

  Future<List<Match>> _loadMatches(String? filtro, _) async {
    await _cargarNombresDeJugadores();
    final matches = await ApiService().fetchMatches();

    return matches.where((match) {
      
      if (match.status == 'Finalizado') return false;

      if(match.tournamentId != widget.filtroTournament) return false;

      final nombre1 = _nombresPorInscriptionId[match.inscription1Id] ?? '';
      final nombre2 = _nombresPorInscriptionId[match.inscription2Id] ?? '';
      final texto = '$nombre1 vs $nombre2'.toLowerCase();
      return texto.contains(filtro?.toLowerCase() ?? '');
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return DropdownSearch<Match>(
      items: _loadMatches,
      itemAsString: (Match match) {
        final nombre1 =
            _nombresPorInscriptionId[match.inscription1Id] ?? 'Jugador 1';
        final nombre2 =
            _nombresPorInscriptionId[match.inscription2Id] ?? 'Jugador 2';
        return '$nombre1 vs $nombre2';
      },
      selectedItem: _matchSeleccionado,
      compareFn: (a, b) => a.matchId == b.matchId,
      onChanged: (Match? nuevo) async {
        if (nuevo == null) return;
        setState(() => _matchSeleccionado = nuevo);
        final name1 =
            _nombresPorInscriptionId[nuevo.inscription1Id] ?? 'Jugador 1';
        final nombre2 =
            _nombresPorInscriptionId[nuevo.inscription2Id] ?? 'Jugador 2';
        nuevo.nombre1 = name1;
        nuevo.nombre2 = nombre2;
        widget.onChanged(nuevo);
      },
      popupProps: PopupProps.menu(
        showSearchBox: true,
        fit: FlexFit.loose,
        constraints: const BoxConstraints(maxHeight: 300),
        searchFieldProps: const TextFieldProps(
          cursorColor: MyColors.secundary,
          decoration: InputDecoration(
            hintText: 'Buscar partido...',
            border: UnderlineInputBorder(),
            focusedBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: MyColors.secundary),
            ),
          ),
        ),
        menuProps: MenuProps(backgroundColor: MyColors.dark),
        itemBuilder: (context, match, isSelected, isDisabled) {
          final nombre1 =
              _nombresPorInscriptionId[match.inscription1Id] ?? 'Jugador 1';
          final nombre2 =
              _nombresPorInscriptionId[match.inscription2Id] ?? 'Jugador 2';
          return ListTile(
            title: Text(
              '$nombre1 vs $nombre2',
              style: TextStyle(color: MyColors.lightGray),
            ),
            leading: const Icon(Icons.sports_tennis, color: MyColors.darkGray),
            enabled: !isDisabled,
          );
        },
      ),
      decoratorProps: const DropDownDecoratorProps(
        decoration: InputDecoration(
          labelText: 'Buscar partido',
          labelStyle: TextStyle(color: MyColors.lightGray),
          prefixIcon: Icon(Icons.search),
          border: OutlineInputBorder(),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: MyColors.secundary),
          ),
        ),
      ),
    );
  }
}
