import 'package:flutter/material.dart';
import 'package:marcador/design/my_colors.dart';
import 'package:marcador/design/tyoe_sync_state.dart';

class SyncState extends StatelessWidget {
  final TypeSyncState typeSyncState;

  const SyncState({super.key, required this.typeSyncState});

  bool get _state => typeSyncState == TypeSyncState.sincronizado ? true : false;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: (_state ? MyColors.success : MyColors.error).withOpacity(0.15),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        ' ${_state ? 'Sincronizado' : 'Pendiente'}',
        style: TextStyle(
          color: _state ? MyColors.success : MyColors.error,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
