import 'package:flutter/material.dart';
import 'package:marcador/design/my_colors.dart';
import 'package:marcador/models/marker.dart';

class SetAndPointsSelet extends StatefulWidget {
  final Marker marker;
  const SetAndPointsSelet({super.key, required this.marker});

  @override
  State<SetAndPointsSelet> createState() => _SetAndPointsSeletState();
}

class _SetAndPointsSeletState extends State<SetAndPointsSelet> {
  // Opciones disponibles
  final List<int> pointsOptions = [5, 7, 11, 15, 21];
  final List<int> setsOptions = [1, 3, 5, 7];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        // Selección de puntos
        const Text(
          "Cantidad de puntos por set",
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: MyColors.light,
          ),
        ),
        const SizedBox(height: 10),
        DropdownButtonFormField<int>(
          initialValue: widget.marker.targetPoints,
          items:
              pointsOptions.map((int value) {
                return DropdownMenuItem<int>(
                  value: value,
                  child: Text("$value puntos"),
                );
              }).toList(),
          style: TextStyle(color: MyColors.light),
          dropdownColor: MyColors.dark,
          decoration: const InputDecoration(
            prefixIcon: Icon(Icons.sports, color: MyColors.light),
            focusedBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: MyColors.secundary),
            ),
          ),
          onChanged: (newValue) {
            setState(() {
              widget.marker.targetPoints = newValue!;
            });
          },
        ),
        const SizedBox(height: 30),

        // Selección de sets
        const Text(
          "Cantidad de sets",
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: MyColors.light,
          ),
        ),
        const SizedBox(height: 10),
        DropdownButtonFormField<int>(
          initialValue: widget.marker.targetSets,
          items:
              setsOptions.map((int value) {
                return DropdownMenuItem<int>(
                  value: value,
                  child: Text("$value sets"),
                );
              }).toList(),
          style: TextStyle(color: MyColors.lightGray),
          dropdownColor: MyColors.dark,
          decoration: InputDecoration(
            focusedBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: MyColors.secundary),
            ),
            prefixIcon: Icon(
              Icons.format_list_numbered,
              color: MyColors.lightGray,
            ),

            // enabledBorder: OutlineInputBorder(
            //   borderSide: BorderSide(color: MyColors.primary),
          ),
          onChanged: (newValue) {
            setState(() {
              widget.marker.targetSets = newValue!;
            });
          },
        ),
        const SizedBox(height: 40),
      ],
    );
  }
}
