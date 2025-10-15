import 'package:flutter/material.dart';
import 'package:marcador/design/my_colors.dart';
import 'package:marcador/design/spacing.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';

class CenterButtons extends StatelessWidget {
  final VoidCallback? onResetScores;
  final VoidCallback? onResetAll;
  final VoidCallback? onUndo;
  final VoidCallback? onSwap;
  final VoidCallback? onRorate;
  final VoidCallback? onEvent;
  final bool rotate;
  const CenterButtons({
    super.key,
    this.onResetScores,
    this.onResetAll,
    this.onUndo,
    this.onSwap,
    this.onEvent,
    this.onRorate,
    required this.rotate,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(Spacing.sm),
      decoration: BoxDecoration(
        color: MyColors.dark,
        borderRadius: BorderRadius.circular(Spacing.sm),
      ),
      // Usamos un Column para apilar las dos filas.
      child: Column(
        mainAxisSize:
            MainAxisSize.min, // La columna ocupa el espacio mínimo necesario
        // spacing: Spacing.xs,
        children: [
          // --- Primera Fila (4 Columnas) ---
          Row(
            mainAxisSize: MainAxisSize.min,
            spacing: Spacing.xs,
            children: [
              // reiniciar set (Icono 1)
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
                icon: Icon(Icons.replay, color: MyColors.lightGray),
              ),
              // reiniciar partido (Icono 2)
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
              // deshacer (undo) (Icono 3)
              IconButton(
                onPressed: onUndo,
                icon: Icon(Symbols.undo, color: MyColors.lightGray),
              ),
            ],
          ),

          const SizedBox(height: 8),

          Row(
            mainAxisSize: MainAxisSize.min,

            children: [
              // rotate (Icono 4)
              IconButton(
                onPressed: onRorate,
                icon: Icon(Symbols.mobile_rotate, color: MyColors.lightGray),
              ),
              // flip/swap (Icono 5)
              IconButton(
                onPressed: onSwap,
                icon: Icon(
                  rotate ? Icons.swap_horiz_outlined : Icons.swap_vert_outlined,
                  color: MyColors.lightGray,
                ),
              ),
              // salir (logout) (Icono 6)
              IconButton(
                onPressed:
                    () => showDialog(
                      context: context,
                      builder: (context) {
                        return AlertDialog(
                          title: Text('Confirmación'),
                          content: Text('¿Estás seguro de salir del partido?'),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.of(context).pop(),
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
                icon: Icon(Icons.logout_sharp, color: MyColors.lightGray),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
