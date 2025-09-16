class Jugador {
  final String ci;
  final String nombreCompleto;

  Jugador({required this.ci, required this.nombreCompleto});

  /*factory Jugador.fromJson(Map<String, dynamic> json) {
    return Jugador(
      ci: json['CI'],
      nombreCompleto: '${json['first_name']} ${json['last_name']}',
    );
  }*/

  factory Jugador.fromJson(Map<String, dynamic> json) {
  // Toma CI de mayúscula o minúscula; si fuera int, conviértelo a String
  final rawCi = json['CI'] ?? json['ci'];
  final cedula = rawCi?.toString() ?? '';

  // Igual con nombres: revisa si vienen como first_name o firstName
  final fn = json['first_name'] ?? json['firstName'] ?? '';
  final ln = json['last_name']  ?? json['lastName']  ?? '';

  return Jugador(
    ci: cedula,
    nombreCompleto: '$fn $ln'.trim(),
  );
}
}
