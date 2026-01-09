import 'package:flutter/material.dart';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:marcador/design/my_colors.dart';
import 'package:marcador/services/api_services.dart';
import 'package:marcador/models/match.dart';
import 'package:provider/provider.dart';
import 'package:marcador/providers/match_provider.dart';

class MatchDropdown extends StatefulWidget {
  final Match? selectedItem;
  final ValueChanged<Match?> onChanged;
  final int? filtroTournament;

  const MatchDropdown({
    super.key,
    this.selectedItem,
    required this.onChanged,
    required this.filtroTournament,
  });

  @override
  State<MatchDropdown> createState() => _MatchDropdownState();
}

class _MatchDropdownState extends State<MatchDropdown> {
  Match? _matchSeleccionado;
  Map<int, String> _nombresPorInscriptionId = {};

  bool _isLoadingData = false;

  @override
  void initState() {
    super.initState();
    _initData();
  }

  Future<void> _initData() async {
    setState(() => _isLoadingData = true);
    await _cargarNombresDeJugadores();
    if (mounted) {
      final provider = context.read<MatchProvider>();
      if (provider.matches.isEmpty) {
        await provider.fetchPendingMatches();
      }
    }
    if (mounted) {
      setState(() => _isLoadingData = false);
    }
  }

  Future<void> _cargarNombresDeJugadores() async {
    if (_nombresPorInscriptionId.isNotEmpty) return; // Avoid re-fetch
    try {
      final inscriptions = await ApiService().fetchInscriptions();
      _nombresPorInscriptionId = {
        for (var ins in inscriptions)
          ins.inscriptionId: ins.jugador.nombreCompleto,
      };
    } catch (e) {
      print("Error loading inscriptions: $e");
    }
  }

  Future<List<Match>> _loadMatches(String? filtro, _) async {
    // Return empty or loading if not ready?
    // DropdownSearch expects a Future, so we can just return the filtered list from provider directly.
    // We assume _initData has finished or is running. If it hasn't finished, provider.matches might be empty or partial.
    // But since we trigger _initData in initState, by the time user types, it should be likely ready.

    // Actually, DropdownSearch calls this when opening.
    // We can await a future if we want to ensure it waits for init.
    // But better: just use current provider state.

    final provider = context.read<MatchProvider>();
    // If empty and not loading, maybe try fetch? But we did in init.

    final matches = provider.matches;

    return matches.where((match) {
      if (match.status == 'Finalizado') return false;

      if (match.tournamentId != widget.filtroTournament) return false;

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
        return '$nombre1 vs $nombre2 ';
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
          autofocus: true,
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
      enabled: !_isLoadingData,
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
