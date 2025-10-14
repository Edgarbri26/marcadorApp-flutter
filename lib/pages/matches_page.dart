import 'package:flutter/material.dart';
import 'package:marcador/design/my_colors.dart';
import 'package:marcador/design/spacing.dart';
import 'package:marcador/models/match_repository.dart';
import 'package:marcador/models/match_save.dart';
import 'package:marcador/models/set_result.dart';
import 'package:marcador/services/api_services.dart';
import 'package:marcador/models/match.dart';

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
      const SnackBar(
        content: Text('Se ha intentado sincronizar todos los partidos.'),
      ),
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
    setState(() {
      _loadMatches(); // Recargar la lista de partidos
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Partido ID ${match.matchId} eliminado.')),
    );
  }

  // --- LÓGICA DE SINCRONIZACIÓN (Simulación de subida) ---
  void _attemptSync(MatchSave match) async {
    _sets = match.setsResults;
    try {
      if (match.tournamentId == 1 || match.tournamentId == 2) {
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

        matchSyn = Match(
          matchId: match.matchId,
          tournamentId: match.tournamentId, // ID fijo para amistoso
          inscription1Id: inscrip1,
          inscription2Id: inscrip2,
          round: match.round,
          status: 'En Juego',
          date: DateTime.now().toIso8601String(),
        );

        matchSyn.winnerInscriptionId =
            match.ci1 == match.ciWiner ? inscrip1 : inscrip2;

        final nuevoMatchId = await ApiService().createMatch(matchSyn);
        print('id del partido 💫 $nuevoMatchId');
        if (nuevoMatchId != null) {
          matchSyn.matchId = nuevoMatchId;
        }

        for (final set in _sets) {
          set.matchId = matchSyn.matchId!;
        }
      }

      for (final set in _sets) {
        await ApiService().postSet(set);
      }

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
      // ignore: use_build_context_synchronously
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
              // 🧭 Barra superior de acciones
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton.icon(
                      onPressed: _syncAllMatches, // Sincronizar todo
                      icon: const Icon(
                        Icons.cloud_upload,
                        color: MyColors.light,
                      ),
                      label: const Text(
                        "Sincronizar todo",
                        style: TextStyle(color: MyColors.lightGray),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                      ),
                    ),
                    ElevatedButton.icon(
                      onPressed: _deleteAllMatches, // Eliminar todo
                      icon: const Icon(
                        Icons.delete_forever,
                        color: MyColors.light,
                      ),
                      label: const Text(
                        "Eliminar todo",
                        style: TextStyle(color: MyColors.lightGray),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: MyColors.primary,
                      ),
                    ),
                  ],
                ),
              ),

              // 📜 Lista de partidos
              Expanded(
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
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          setState(() {
            _loadMatches(); // Recargar lista
          });
        },
        backgroundColor: MyColors.secundary,
        child: const Icon(Icons.refresh, color: Colors.white),
        tooltip: 'Refrescar lista de partidos',
      ),
    );
  }
}

// --- WIDGET AUXILIAR PARA MOSTRAR CADA PARTIDO ---

class MatchCard extends StatelessWidget {
  final MatchSave match;
  final VoidCallback onSyncPressed;
  final String winnerName;
  final VoidCallback onDeletePressed;
  final MatchRepository repo;

  const MatchCard({
    required this.match,
    required this.onSyncPressed,
    required this.winnerName,
    super.key,
    required this.onDeletePressed,
    required this.repo,
  });

  // Función auxiliar para formatear los resultados de los sets
  String _formatSets(MatchSave match) {
    return match.setsResults
        .map((s) => '${s.scoreParticipant1}-${s.scoreParticipant2}')
        .join(', ');
  }

  // Define el color y el icono basado en el estado de sincronización
  Color get _syncColor =>
      match.isSynced ? Colors.green.shade700 : Colors.red.shade700;
  IconData get _syncIcon => match.isSynced ? Icons.cloud_done : Icons.cloud_off;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      elevation: 4,
      child: ListTile(
        leading: Icon(_syncIcon, color: _syncColor, size: 30),
        title: Text(
          '${match.player1Name.split(' ').first} vs ${match.player2Name.split(' ').first}',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text('Ganador: $winnerName'),
            Text('Resultados: ${_formatSets(match)}'),
            const SizedBox(height: 4),
            Text('Round: ${match.round}'),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: _syncColor.withOpacity(0.4),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                ' ${match.isSynced ? 'Sincronizado' : 'Pendiente'}',
                style: TextStyle(
                  color: _syncColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        trailing:
            match.isSynced
                ? null // No mostrar botón si ya está sincronizado
                : IconButton(
                  icon: const Icon(Icons.sync, color: Colors.blue),
                  onPressed: onSyncPressed,
                  tooltip: 'Intentar Sincronizar',
                ),
        onTap: () {
          // Navegar a una página de detalles si fuera necesario
          _showDetailsDialog(context);
        },
      ),
    );
  }

  // Diálogo para mostrar los sets detallados
  void _showDetailsDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('${match.player1Name} vs ${match.player2Name}'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Ganador: $winnerName',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              const Text(
                'Resultados de los Sets:',
                style: TextStyle(decoration: TextDecoration.underline),
              ),
              ...match.setsResults
                  .map(
                    (s) => Text(
                      'Set ${s.setNumber}: ${match.player1Name.split(' ').first} ${s.scoreParticipant1} vs ${s.scoreParticipant2} ${match.player2Name.split(' ').first}',
                    ),
                  )
                  .toList(),
              const SizedBox(height: 10),
              Text(
                'Sincronizado: ${match.isSynced ? 'SÍ' : 'NO'}',
                style: TextStyle(
                  color: _syncColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _showDeleteDialog(context);
              },
              child: const Text(
                'Eliminar Partido',
                style: TextStyle(color: Colors.red),
              ),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cerrar'),
            ),
          ],
        );
      },
    );
  }

  void _showDeleteDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Eliminar Partido'),
          content: const Text(
            '¿Estás seguro de que deseas eliminar este partido? Esta acción no se puede deshacer.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () async {
                final hiveKey = match.matchId.toString();
                await repo.matchBox.delete(hiveKey);
                onDeletePressed();
                Navigator.of(context).pop();
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              child: const Text('Eliminar'),
            ),
          ],
        );
      },
    );
  }
}
