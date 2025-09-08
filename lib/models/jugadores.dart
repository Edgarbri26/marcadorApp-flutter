class Jugador {
  final String ci;
  final String nombreCompleto;

  Jugador({required this.ci, required this.nombreCompleto});

  factory Jugador.fromJson(Map<String, dynamic> json) {
    return Jugador(
      ci: json['ci'],
      nombreCompleto: '${json['first_name']} ${json['last_name']}',
    );
  }
}
