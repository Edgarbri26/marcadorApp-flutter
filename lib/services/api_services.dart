import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:marcador/models/jugadores.dart';
/*import '../utils/constants.dart';*/

class ApiService {
  Future<List<Jugador>> fetchJugadores() async {
  final response = await http.get(Uri.parse('https://lpp-backend.onrender.com/api/player'));

  if (response.statusCode == 200) {
    final Map<String, dynamic> jsonBody = json.decode(response.body);
    final List<dynamic> jugadoresJson = jsonBody['data'];
    return jugadoresJson.map((json) => Jugador.fromJson(json)).toList();
  } else {
    throw Exception('Error al cargar jugadores');
  }
}
}
