import 'package:flutter/material.dart';
import 'package:marcador/config/app_routes.dart';
import 'package:marcador/design/my_colors.dart';

class CenterButtons extends StatelessWidget {
  final VoidCallback? onResetScores;
  final VoidCallback? onResetAll;
  final VoidCallback? onUndo;
  final VoidCallback? onSwap;
  final VoidCallback? onEvent;
  const CenterButtons({
    super.key,
    this.onResetScores,
    this.onResetAll,
    this.onUndo,
    this.onSwap,
    this.onEvent,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(8.0),
      decoration: BoxDecoration(
        color: MyColors.dark,
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: SizedBox(
        width: 160,
        child: Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            IconButton(
              onPressed:
                  () => showDialog(
                    context: context,
                    builder: (context) {
                      return AlertDialog(
                        title: Text('Confirmación'),
                        content: Text(
                          '¿Estás seguro de jugar una nueva partida?',
                        ),
                        actions: [
                          TextButton(
                            onPressed:
                                () => Navigator.of(
                                  context,
                                ).pushReplacementNamed(AppRoutes.settings),
                            child: Text('Cancelar'),
                          ),
                          ElevatedButton(
                            onPressed: () {
                              Navigator.pop(context);
                              Navigator.pop(context);
                            },
                            child: Text('Aceptar'),
                          ),
                        ],
                      );
                    },
                  ),
              icon: Icon(Icons.add_box_outlined, color: MyColors.lightGray),
            ),
            // reiniciar set
            IconButton(
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (context) {
                    return AlertDialog(
                      title: Text('Alerta'),
                      content: Text('¿Quieres reiniciar el set?'),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: Text('Cancelar'),
                        ),
                        ElevatedButton(
                          onPressed: () {
                            Navigator.pop(context);
                            onResetScores?.call();
                          },
                          child: Text('Aceptar'),
                        ),
                      ],
                    );
                  },
                );
              },
              icon: Icon(Icons.refresh, color: MyColors.lightGray),
            ),
            // reiniciar partido
            IconButton(
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (context) {
                    return AlertDialog(
                      title: Text('Alerta'),
                      content: Text('¿Quieres reiniciar el partido?'),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: Text('Cancelar'),
                        ),
                        ElevatedButton(
                          onPressed: () {
                            Navigator.pop(context);
                            onResetAll?.call();
                          },
                          child: Text('Aceptar'),
                        ),
                      ],
                    );
                  },
                );
              },
              icon: Icon(Icons.restart_alt, color: MyColors.lightGray),
            ),
            // deaser
            IconButton(
              onPressed: onUndo,
              icon: Icon(Icons.undo, color: MyColors.lightGray),
            ),
            // flip
            IconButton(
              onPressed: onSwap,
              icon: Icon(Icons.swap_horiz_rounded, color: MyColors.lightGray),
            ),
            // torneo
            IconButton(
              onPressed: onEvent,
              icon: Icon(Icons.emoji_events, color: MyColors.lightGray),
            ),
          ],
        ),
      ),
    );
  }
}
