import 'package:flutter/material.dart';
import 'package:marcador/design/my_colors.dart';

class CenterButtons extends StatelessWidget {
  final VoidCallback? onResetScores;
  final VoidCallback? onResetAll;
  final VoidCallback? onUndo;
  const CenterButtons({
    super.key,
    this.onResetScores,
    this.onResetAll,
    this.onUndo,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(8.0),
      decoration: BoxDecoration(
        color: MyColors.darkGray,
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
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
                          onPressed: () => Navigator.pop(context),
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
          IconButton(
            onPressed: onUndo,
            icon: Icon(Icons.undo, color: MyColors.lightGray),
          ),
        ],
      ),
    );
  }
}
