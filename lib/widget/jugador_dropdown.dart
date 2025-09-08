import 'package:flutter/material.dart';
import 'package:marcador/models/jugadores.dart';
import 'package:marcador/services/api_services.dart';

class JugadorDropdown extends StatefulWidget {
  const JugadorDropdown({super.key});

  @override
  State<JugadorDropdown> createState() => _JugadorDropdownState();
}

class _JugadorDropdownState extends State<JugadorDropdown> {
  late Future<List<Jugador>> _jugadores;
  Jugador? _jugadorSeleccionado;

  @override
  void initState() {
    super.initState();
    _jugadores = ApiService().fetchJugadores();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Jugador>>(
      future: _jugadores,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        } else {
          final jugadores = snapshot.data!;
          return DropdownButtonFormField<Jugador>(
            decoration: const InputDecoration(
              labelText: 'Jugador',
              prefixIcon: Icon(Icons.person),
            ),
            value: _jugadorSeleccionado,
            items: jugadores.map((jugador) {
              return DropdownMenuItem(
                value: jugador,
                child: Text(jugador.nombreCompleto),
              );
            }).toList(),
            onChanged: (Jugador? nuevo) {
              setState(() {
                _jugadorSeleccionado = nuevo;
              });
            },
          );
        }
      },
    );
  }
}
