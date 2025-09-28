class Jugador {
  final String ci;
  final String nombreCompleto;

  Jugador({required this.ci, required this.nombreCompleto});

  factory Jugador.fromJson(Map<String, dynamic> json) {
    // Toma CI de mayúscula o minúscula; si fuera int, conviértelo a String
    final rawCi = json['CI'] ?? json['ci'];
    final cedula = rawCi?.toString() ?? '';

    // Extrae solo el primer nombre y primer apellido
    final rawFirstName = json['first_name'] ?? json['firstName'] ?? '';
    final rawLastName = json['last_name'] ?? json['lastName'] ?? '';

    final primerNombre = rawFirstName.split(' ').first;
    final primerApellido = rawLastName.split(' ').first;

    return Jugador(
      ci: cedula,
      nombreCompleto: '$primerNombre $primerApellido',
    );
  }
}
