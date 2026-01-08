import 'package:flutter/material.dart';
import 'package:marcador/design/my_colors.dart';
import 'package:marcador/design/spacing.dart';

class PlayerGameArea extends StatefulWidget {
  final int playerScore;
  final int playerNumber;
  final Color backgroundColor;
  final Function onIncrement;
  final VoidCallback? onEdit;
  final bool isTournament;

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
    this.onEdit,
    required this.isTournament,
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
                !widget.isTournament
                    ? IconButton(
                      onPressed: widget.onEdit,
                      icon: Icon(
                        Icons.edit,
                        size: 30,
                        color: MyColors.lightGray,
                      ),
                    )
                    : SizedBox(),
                // IconButton(onPressed: widget.onEdit, icon: Icons.edit),
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

                // widget.takeOut
                //     ? Icon(
                //       Icons.sports_tennis,
                //       color: MyColors.lightGray,
                //       size: 30,
                //     )
                //     : SizedBox(),
              ],
            ),
            Container(
              alignment: Alignment.center,
              width: 180, // Fixed width for circle shape stability
              height: 180, // Fixed height for circle shape stability
              decoration:
                  widget.takeOut
                      ? BoxDecoration(
                        color: Colors.white.withOpacity(0.9),
                        shape: BoxShape.circle,
                      )
                      : null,
              child: Text(
                widget.playerScore.toString(),
                style: TextStyle(
                  fontFamily: 'Inter',
                  height: 1.0, // Fix line height to center text vertically
                  fontSize: 150,
                  color:
                      widget.takeOut ? MyColors.darkUltra : MyColors.lightGray,
                  fontWeight:
                      widget.takeOut ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
