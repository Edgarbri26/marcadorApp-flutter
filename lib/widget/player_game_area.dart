import 'package:flutter/material.dart';
import 'package:marcador/design/my_colors.dart';
import 'package:marcador/design/spacing.dart';
import 'package:marcador/services/take_out.dart';

class PlayerGameArea extends StatefulWidget {
  final int playerScore;
  final int playerNumber;
  final Color backgroundColor;
  final Function onIncrement;

  final String playerName;
  final bool takeOut;
  const PlayerGameArea({
    super.key,
    required this.playerScore,
    required this.backgroundColor,
    required this.onIncrement,

    required this.playerNumber,
    required this.playerName,
    required this.takeOut,
  });

  @override
  State<PlayerGameArea> createState() => _PlayerGameAreaState();
}

class _PlayerGameAreaState extends State<PlayerGameArea> {
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => widget.onIncrement(),
      // onDoubleTap: () => widget.onDecrement(),
      // onLongPress: () => widget.onDecrement(),
      child: Container(
        width: double.infinity,
        color: widget.backgroundColor,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Padding(
                  padding: const EdgeInsets.only(right: Spacing.sm),
                  child: Text(
                    widget.playerName,
                    style: TextStyle(
                      fontFamily: 'Libertinus Keyboard',
                      color: MyColors.lightGray,
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                widget.takeOut
                    ? Icon(
                      Icons.sports_tennis,
                      color: MyColors.lightGray,
                      size: 30,
                    )
                    : SizedBox(),
              ],
            ),
            Text(
              widget.playerScore.toString(),
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 150,
                color: MyColors.lightGray,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
