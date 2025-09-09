import 'package:flutter/material.dart';
import 'package:marcador/design/my_colors.dart';
import 'package:marcador/design/type_button.dart';

class ButtonApp extends StatelessWidget {
  final void Function() onPressed;
  final String title;
  final Icon icon;
  final TypeButton typeButton;
  const ButtonApp({
    super.key,
    required this.onPressed,
    required this.title,
    required this.icon,
    required this.typeButton,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      style: ElevatedButton.styleFrom(
        backgroundColor:
            typeButton == TypeButton.primary ? MyColors.primary : MyColors.dark,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      icon: const Icon(Icons.play_arrow_rounded, color: Colors.white, size: 28),
      label: Text(
        "Jugar",
        style: TextStyle(fontSize: 16, color: MyColors.light),
      ),
      onPressed: onPressed,
    );
  }
}
