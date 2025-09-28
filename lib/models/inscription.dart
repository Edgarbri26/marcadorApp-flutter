import 'package:marcador/models/jugador.dart';

class Inscription {
  final int inscriptionId;
  final Jugador jugador;

  Inscription({required this.inscriptionId, required this.jugador});

  factory Inscription.fromJson(Map<String, dynamic> json) {
    return Inscription(
      inscriptionId: json['inscription_id'],
      jugador:
          json['player'] != null
              ? Jugador.fromJson(json['player'])
              : throw Exception('Jugador no encontrado en la inscripción'),
    );
  }
}
