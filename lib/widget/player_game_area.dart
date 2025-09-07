import 'package:flutter/material.dart';
import 'package:marcador/design/my_colors.dart';

class PlayerGameArea extends StatefulWidget {
  final int playerScore;
  final int playerNumber;
  final Color backgroundColor;
  final Function onIncrement;
  final Function onDecrement;
  const PlayerGameArea({
    super.key,
    required this.playerScore,
    required this.backgroundColor,
    required this.onIncrement,
    required this.onDecrement,
    required this.playerNumber,
  });

  @override
  State<PlayerGameArea> createState() => _PlayerGameAreaState();
}

class _PlayerGameAreaState extends State<PlayerGameArea> {
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => widget.onIncrement(widget.playerNumber),
      onDoubleTap: () => widget.onDecrement(widget.playerNumber),
      child: Container(
        width: double.infinity,
        color: widget.backgroundColor,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Equipo B',
              style: TextStyle(
                fontFamily: 'Libertinus Keyboard',
                color: MyColors.lightGray,
                fontSize: 32,
                fontWeight: FontWeight.bold,
              ),
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
