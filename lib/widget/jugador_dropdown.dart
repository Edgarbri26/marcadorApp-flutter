import 'package:flutter/material.dart';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:marcador/design/my_colors.dart';
import 'package:marcador/models/jugador.dart';
import 'package:marcador/services/api_services.dart';

class JugadorDropdown extends StatefulWidget {
  final Jugador? selectedItem;
  final ValueChanged<Jugador?> onChanged;

  const JugadorDropdown({
    super.key,
    this.selectedItem,
    required this.onChanged,
  });

  @override
  State<JugadorDropdown> createState() => _JugadorDropdownState();
}

class _JugadorDropdownState extends State<JugadorDropdown> {
  Jugador? _jugadorSeleccionado;

  @override
  Widget build(BuildContext context) {
    return DropdownSearch<Jugador>(
      items: (String? filtro, _) async {
        final todos = await ApiService().fetchJugadores();
        return todos
            .where(
              (j) => j.nombreCompleto.toLowerCase().contains(
                filtro?.toLowerCase() ?? '',
              ),
            )
            .toList();
      },
      itemAsString: (Jugador j) => j.nombreCompleto,
      selectedItem: _jugadorSeleccionado,
      compareFn: (a, b) => a.ci == b.ci,
      onChanged: (Jugador? nuevo) {
        setState(() {
          _jugadorSeleccionado = nuevo;
        });
        widget.onChanged(nuevo);
      },
      popupProps: PopupProps.menu(
        showSearchBox: true,
        fit: FlexFit.loose,
        constraints: const BoxConstraints(maxHeight: 300),
        searchFieldProps: const TextFieldProps(
          cursorColor: MyColors.secundary,
          decoration: InputDecoration(
            hintText: 'Escribe el nombre...',
            border: UnderlineInputBorder(),
            focusedBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: MyColors.secundary),
            ),
          ),
        ),
        menuProps: MenuProps(backgroundColor: MyColors.dark),
        itemBuilder:
            (context, jugador, isSelected, isDisabled) => ListTile(
              title: Text(
                jugador.nombreCompleto,
                style: TextStyle(color: MyColors.lightGray),
              ),
              leading: const Icon(Icons.person, color: MyColors.darkGray),
              enabled: !isDisabled,
            ),
      ),
      decoratorProps: const DropDownDecoratorProps(
        decoration: InputDecoration(
          labelText: 'Buscar jugador',
          labelStyle: TextStyle(color: MyColors.lightGray),
          prefixIcon: Icon(Icons.search),
          border: OutlineInputBorder(),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: MyColors.secundary),
          ),
        ),
      ),
    );
  }
}
