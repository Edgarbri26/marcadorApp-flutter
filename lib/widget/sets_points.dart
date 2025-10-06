import 'package:flutter/material.dart';
import 'package:marcador/design/my_colors.dart';
import 'package:marcador/design/spacing.dart';

class SetsPoints extends StatelessWidget {
  final int player1Sets;
  final int player2Sets;
  final bool swap;
  const SetsPoints({
    super.key,
    required this.player1Sets,
    required this.player2Sets,
    required this.swap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: Align(
        alignment: Alignment.topCenter,
        child: Container(
          padding: const EdgeInsets.symmetric(
            //horizontal
            horizontal: Spacing.lg,
            vertical: Spacing.xs,
          ),
          // margin: const EdgeInsets.only(right: 8.0),
          decoration: BoxDecoration(
            color: MyColors.dark,
            borderRadius: BorderRadius.circular(Spacing.lg),
          ),
          child: Flex(
            direction: Axis.horizontal,
            textDirection: swap ? TextDirection.ltr : TextDirection.rtl,
            mainAxisSize: MainAxisSize.min,
            spacing: 10,
            children: [
              Text(
                '$player1Sets',
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 32,
                  color: MyColors.secundary,
                  fontWeight: FontWeight.bold,
                ),
              ),

              Text(
                '$player2Sets',
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 32,
                  color: MyColors.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
