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
    return Container(
      decoration: BoxDecoration(
        gradient:
            typeButton == TypeButton.primary
                ? LinearGradient(
                  colors: [MyColors.primary, MyColors.error],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                )
                : LinearGradient(
                  colors: [MyColors.darkContraste, MyColors.dark],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: ElevatedButton.icon(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        icon: icon,
        label: Text(
          title,
          style: TextStyle(fontSize: 16, color: MyColors.light),
        ),
        onPressed: onPressed,
      ),
    );
  }
}
