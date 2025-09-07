class Jugador {
  final int id;
  final String nombre;

  Jugador({required this.id, required this.nombre, });

  factory Jugador.fromJson(Map<String, dynamic> json) {
    return Jugador(
      id: json['id'],
      nombre: json['nombre'],
    );
  }
}
