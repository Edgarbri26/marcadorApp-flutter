import 'package:flutter/material.dart';
import 'package:marcador/design/my_colors.dart';
import 'package:marcador/design/spacing.dart';
import 'package:marcador/design/type_button.dart';
import 'package:marcador/models/match_repository.dart';
import 'package:marcador/models/match_save.dart';
import 'package:marcador/models/set_result.dart';
import 'package:marcador/services/api_services.dart';
import 'package:marcador/models/match.dart';
import 'package:marcador/widget/button_app.dart';
import 'package:marcador/widget/matchCard.dart';

class MatchesPage extends StatefulWidget {
  const MatchesPage({super.key});

  @override
  State<MatchesPage> createState() => _MatchesPageState();
}

class _MatchesPageState extends State<MatchesPage> {
  // Instancia del repositorio
  final MatchRepository _repo = MatchRepository();
  late Match matchSyn;
  List<SetResult> _sets = [];

  // Future para almacenar la lista de partidos cargados
  late Future<List<MatchSave>> _matchesFuture;

  void _deleteAllMatches() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Eliminar Todos los Partidos'),
          content: const Text(
            '¿Estás seguro de que deseas eliminar todos los partidos guardados? Esta acción no se puede deshacer.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(true),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              child: const Text('Eliminar Todo'),
            ),
          ],
        );
      },
    );

    if (confirm == true) {
      await _repo.deleteAllMatches();
      setState(() {
        _loadMatches(); // Recargar la lista de partidos
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Todos los partidos han sido eliminados.'),
        ),
      );
    }
  }

  void _syncAllMatches() async {
    final unsyncedMatches = _repo.getUnsyncedMatches();
    if (unsyncedMatches.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No hay partidos pendientes de sincronización.'),
        ),
      );
      return;
    }

    for (final match in unsyncedMatches) {
      _attemptSync(match);
    }
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Sincronizando todos los partidos.')),
    );
    setState(() {}); // Refrescar la UI después de intentar sincronizar todos
  }

  @override
  void initState() {
    super.initState();
    _loadMatches();
  }

  // Función para cargar todos los partidos (sincronizados y no sincronizados)
  void _loadMatches() {
    _matchesFuture = Future.value(_repo.matchBox.values.toList());
  }

  void _deleteMatch(MatchSave match) async {
    bool response = await _repo.deleteMatchById(match);
    setState(() {
      _loadMatches(); // Recargar la lista de partidos
    });

    response
        ? ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Partido ID ${match.matchId} eliminado.')),
        )
        : ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Partido ID ${match.matchId} no se pudo eliminar.'),
          ),
        );
  }

  // --- LÓGICA DE SINCRONIZACIÓN (Simulación de subida) ---
  void _attemptSync(MatchSave match) async {
    _sets = match.setsResults;
    matchSyn = Match(
      winnerInscriptionId: match.winnerInscriptionId,
      matchId: match.matchId,
      tournamentId: match.tournamentId, // ID fijo para amistoso
      round: match.round,
      status: 'En Juego',
      date: DateTime.now().toIso8601String(),
    );
    try {
      if (match.matchId == null) {
        final inscrip1 = await ApiService().obtenerInscriptionIdPorCI(
          match.ci1,
          match.tournamentId,
        );
        final inscrip2 = await ApiService().obtenerInscriptionIdPorCI(
          match.ci2,
          match.tournamentId,
        );
        print('inscrp 1 : $inscrip1 y inscrp 2 : $inscrip2');

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
        matchSyn.inscription1Id = inscrip1;
        matchSyn.inscription2Id = inscrip2;

        final nuevoMatchId = await ApiService().createMatch(matchSyn);
        print('id del partido 💫 $nuevoMatchId');
        if (nuevoMatchId != null) {
          matchSyn.matchId = nuevoMatchId;
        }

        matchSyn.winnerInscriptionId =
            match.ci1 == match.ciWiner ? inscrip1 : inscrip2;

        for (final set in _sets) {
          set.matchId = matchSyn.matchId!;
        }
      }
      if (matchSyn.matchId != null) {
        for (final set in _sets) {
          await ApiService().postSet(set);
        }
      }

      print(
        "inscripncion 1: ${match.inscription1Id}, inscripncion 2: ${match.inscription2Id} inscripncion win: ${match.winnerInscriptionId}",
      );
      print('antes del put ${matchSyn.winnerInscriptionId}');
      final response = await ApiService().putMatch(matchSyn);
      if (response) {
        await _repo.markMatchAsSynced(match);
        setState(() {}); // Refrescar la UI
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Partido ID ${matchSyn.matchId} sincronizado con éxito!',
            ),
          ),
        );
      } else {
        throw Exception('Error en la respuesta del servidor');
      }
      // Si todo va bien, marcar como sincronizado

      // ignore: use_build_context_synchronously
    } catch (e) {
      // Simulación de error (por ejemplo, si no hay conexión real)
      // ignore:
      // print(e);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Error al sincronizar partido ID ${match.matchId}. Inténtalo de nuevo.',
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // toolbarHeight: 60,
        title: Text(
          'Partidos Guardados',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: MyColors.lightGray,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            borderRadius: const BorderRadius.only(
              bottomLeft: Radius.circular(Spacing.sm),
              bottomRight: Radius.circular(Spacing.sm),
            ), // PARA EL BORDE REDONDEADO DEL APPBAR
            gradient: LinearGradient(
              colors: [MyColors.secundary, MyColors.secundaryContraste],
              begin: Alignment.bottomCenter,
              end: Alignment.topCenter,
            ),
          ),
        ),
      ),
      body: FutureBuilder<List<MatchSave>>(
        future: _matchesFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(
              child: Text('Error al cargar datos: ${snapshot.error}'),
            );
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
              child: Text(
                'No hay partidos guardados en el almacenamiento local.',
                style: TextStyle(fontSize: 16, color: Colors.grey),
                textAlign: TextAlign.center,
              ),
            );
          }

          final matches = snapshot.data!;

          return Column(
            children: [
              // Lista de partidos
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: Spacing.sm),
                  child: ListView.builder(
                    itemCount: matches.length,
                    itemBuilder: (context, index) {
                      final invertedIndex = matches.length - 1 - index;
                      final match = matches[invertedIndex];
                      return MatchCard(
                        onDeletePressed: () => _deleteMatch(match),
                        match: match,
                        onSyncPressed: () => _attemptSync(match),
                        winnerName: match.winnerName,
                        repo: _repo,
                      );
                    },
                  ),
                ),
              ),
              //botones
              Padding(
                padding: const EdgeInsets.all(Spacing.sm),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ButtonApp(
                      onPressed: _deleteAllMatches,
                      title: const Text(
                        "Eliminar todo",
                        style: TextStyle(color: MyColors.lightGray),
                      ),
                      typeButton: TypeButton.primary,
                      icon: const Icon(
                        Icons.delete_forever,
                        color: MyColors.light,
                      ),
                    ),
                    ButtonApp(
                      onPressed: _syncAllMatches,
                      title: const Text(
                        "Sincronizar todo",
                        style: TextStyle(color: MyColors.lightGray),
                      ),
                      typeButton: TypeButton.secundary,
                      icon: const Icon(
                        Icons.cloud_upload,
                        color: MyColors.light,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
      // floatingActionButton: FloatingActionButton(
      //   onPressed: () {
      //     setState(() {
      //       _loadMatches(); // Recargar lista
      //     });
      //   },
      //   backgroundColor: MyColors.secundary,
      //   child: const Icon(Icons.refresh, color: Colors.white),
      //   tooltip: 'Refrescar lista de partidos',
      // ),
    );
  }
}
