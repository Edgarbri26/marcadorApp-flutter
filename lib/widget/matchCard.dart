import 'package:flutter/material.dart';
import 'package:marcador/design/my_colors.dart';
import 'package:marcador/design/spacing.dart';
import 'package:marcador/design/tyoe_sync_state.dart';
import 'package:marcador/models/match_repository.dart';
import 'package:marcador/models/match_save.dart';
import 'package:marcador/widget/sync_state.dart';

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
  Color get _syncColor => match.isSynced ? MyColors.success : MyColors.error;
  IconData get _syncIcon => match.isSynced ? Icons.cloud_done : Icons.cloud_off;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 10, vertical: Spacing.xs),
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
            Text('ID: ${match.matchId}'),
            Text('Ganador: $winnerName'),
            Text('Resultados: ${_formatSets(match)}'),
            const SizedBox(height: 4),
            Text('Round: ${match.round}'),
            SyncState(
              typeSyncState:
                  match.isSynced
                      ? TypeSyncState.sincronizado
                      : TypeSyncState.pendiente,
            ),
          ],
        ),
        trailing:
            match.isSynced
                ? null // No mostrar botón si ya está sincronizado
                : IconButton(
                  icon: const Icon(Icons.sync, color: MyColors.primary),
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
              SyncState(
                typeSyncState:
                    match.isSynced
                        ? TypeSyncState.sincronizado
                        : TypeSyncState.pendiente,
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
                'Eliminar',
                style: TextStyle(color: MyColors.primary),
              ),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text(
                'Cerrar',
                style: TextStyle(color: MyColors.lightGray),
              ),
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
