import 'package:flutter/material.dart';
import 'package:marcador/design/my_colors.dart';

class SetAndPointsSelet extends StatefulWidget {
  const SetAndPointsSelet({super.key});

  @override
  State<SetAndPointsSelet> createState() => _SetAndPointsSeletState();
}

class _SetAndPointsSeletState extends State<SetAndPointsSelet> {
  int selectedPoints = 7;
  int selectedSets = 3;
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
          initialValue: selectedPoints,
          items:
              pointsOptions.map((int value) {
                return DropdownMenuItem<int>(
                  value: value,
                  child: Text("$value puntos"),
                );
              }).toList(),
          decoration: const InputDecoration(
            prefixIcon: Icon(Icons.sports),
            // fillColor: MyColors.light,
            focusColor: MyColors.primary,
            fillColor: MyColors.light,
            iconColor: MyColors.primary,
            hoverColor: MyColors.strongPrimary,

            // enabledBorder: OutlineInputBorder(
            //   borderSide: BorderSide(color: MyColors.primary),
          ),
          onChanged: (newValue) {
            setState(() {
              selectedPoints = newValue!;
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
          initialValue: selectedSets,
          items:
              setsOptions.map((int value) {
                return DropdownMenuItem<int>(
                  value: value,
                  child: Text("$value sets"),
                );
              }).toList(),
          decoration: InputDecoration(
            prefixIcon: Icon(Icons.format_list_numbered),
            // fillColor: MyColors.light,
            focusColor: MyColors.primary,
            fillColor: MyColors.light,
            iconColor: MyColors.primary,
            hoverColor: MyColors.primary.withOpacity(0.1),

            // enabledBorder: OutlineInputBorder(
            //   borderSide: BorderSide(color: MyColors.primary),
          ),
          onChanged: (newValue) {
            setState(() {
              selectedSets = newValue!;
            });
          },
        ),
        const SizedBox(height: 40),
      ],
    );
  }
}
