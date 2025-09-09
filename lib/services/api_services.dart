import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:marcador/models/jugador.dart';
import 'package:marcador/models/match.dart';
/*import '../utils/constants.dart';*/

class ApiService {
  String baseUrl = 'https://lpp-backend.onrender.com/api';
  String localUrl = 'http://localhost:3000/api';

  Future<List<Jugador>> fetchJugadores() async {
  //final response = await http.get(Uri.parse('$baseUrl/player'));
  final response = await http.get(Uri.parse('$localUrl/player'));

  if (response.statusCode == 200) {
    final Map<String, dynamic> jsonBody = json.decode(response.body);
    final List<dynamic> jugadoresJson = jsonBody['data'];
    return jugadoresJson.map((json) => Jugador.fromJson(json)).toList();
  } else {
    throw Exception('Error al cargar Playeres');
  }
}

  /*Future<List<Match>> fetchMatch() async {
  //final response = await http.get(Uri.parse('$baseUrl/match'));
  final response = await http.get(Uri.parse('$localUrl/match'));

  if (response.statusCode == 200) {
    final Map<String, dynamic> jsonBody = json.decode(response.body);
    final List<dynamic> matchesJson = jsonBody['data'];
    return matchesJson.map((json) => Match.toJson(json)).toList();
  } else {
    throw Exception('Error al cargar matches');
  }
}*/

Future<int?> createMatch(Match match) async {
  final url = Uri.parse('$localUrl/match');

  final response = await http.post(
    url,
    headers: {'Content-Type': 'application/json'},
    body: json.encode(match.toJson()),
  );

  if (response.statusCode == 201 || response.statusCode == 200) {
    final jsonBody = json.decode(response.body);
    return jsonBody['data']['match_id']; // Devuelve el ID del partido creado
  } else {
    print('Error al crear el partido: ${response.body}');
    return null;
  }
}

}
