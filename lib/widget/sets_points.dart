import 'package:flutter/material.dart';
import 'package:marcador/design/my_colors.dart';
import 'package:marcador/design/spacing.dart';

class SetsPoints extends StatelessWidget {
  final int player1Sets;
  final int player2Sets;
  final bool swap;
  final bool rotate;

  const SetsPoints({
    super.key,
    required this.player1Sets,
    required this.player2Sets,
    required this.swap,
    required this.rotate,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        //horizontal
        horizontal: Spacing.lg,
        vertical: Spacing.xs,
      ),
      // margin: const EdgeInsets.only(right: 8.0),
      decoration: BoxDecoration(
        color: MyColors.dark,
        borderRadius:
            rotate
                ? BorderRadius.only(
                  bottomLeft: Radius.circular(Spacing.lg),
                  bottomRight: Radius.circular(Spacing.lg),
                )
                : BorderRadius.only(
                  topRight: Radius.circular(Spacing.lg),
                  bottomRight: Radius.circular(Spacing.lg),
                ),
      ),
      child: Flex(
        direction: rotate ? Axis.horizontal : Axis.vertical,
        textDirection: swap ? TextDirection.ltr : TextDirection.rtl,
        verticalDirection: swap ? VerticalDirection.up : VerticalDirection.down,
        mainAxisSize: MainAxisSize.min,
        spacing: rotate ? 15 : 4,
        children: [
          Text(
            '$player1Sets',
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 40,
              color: MyColors.secundary,
              fontWeight: FontWeight.bold,
            ),
          ),

          Text(
            '$player2Sets',
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 40,
              color: MyColors.primary,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
