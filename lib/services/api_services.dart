import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:marcador/models/inscription.dart';
import 'package:marcador/models/jugador.dart';
import 'package:marcador/models/match.dart';
import 'package:marcador/models/setResult.dart';
/*import '../utils/constants.dart';*/

class ApiService {
  String baseUrl = 'https://lpp-backend.onrender.com/api';
  String localUrl = 'http://localhost:3000/api';


  Future<List<Jugador>> fetchJugadores() async {
    final response = await http.get(Uri.parse('$localUrl/player'));
    if (response.statusCode != 200) {
      throw Exception('Error al cargar jugadores');
    }

    final decoded = json.decode(response.body);
    // Si la API devuelve { data: [...] }
    final list = (decoded is Map)
      ? decoded['data'] as List<dynamic>? ?? []
      : decoded as List<dynamic>;

    return list
      .map((jsonMap) =>
        Jugador.fromJson(jsonMap as Map<String, dynamic>))
      .toList();
  }

   Future<List<Match>> fetchMatches() async {
    final response = await http.get(Uri.parse('$localUrl/match'));

    if (response.statusCode == 200) {
      final Map<String, dynamic> jsonBody = json.decode(response.body);
      print(jsonBody);
      final matchesJson = jsonBody['data'];
      if (matchesJson is List) {
        return matchesJson.map((json) => Match.fromJson(json)).toList();
      } else {
        throw Exception('Formato inesperado en la respuesta de /match');
      }
    } else {
      throw Exception('Error al cargar matches');
    }
  }

Future<List<Inscription>> fetchInscriptions() async {
    final response = await http.get(Uri.parse('$localUrl/inscription'));

    if (response.statusCode == 200) {
      final Map<String, dynamic> jsonBody = json.decode(response.body);
      print(jsonBody);
      final inscriptionJson = jsonBody['data'];
      if (inscriptionJson is List) {
        return inscriptionJson.map((json) => Inscription.fromJson(json)).toList();
      } else {
        throw Exception('Formato inesperado en la respuesta de /inscription');
      }
    } else {
      throw Exception('Error al cargar inscripciones');
    }
  }

Future<int?> postMatch(Match match) async {
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

  Future<int?> postSet(SetResult setResult) async {
    final url = Uri.parse('$localUrl/set');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: json.encode(setResult.toJson()),
    );

    if (response.statusCode == 201) {
      final jsonBody = json.decode(response.body);
      // Según Swagger, POST /set devuelve el set creado bajo la clave "set"
      return jsonBody['set']['set_id'] as int?;
    } else {
      print('Error al crear el set: ${response.body}');
      return null;
    }
  }

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
