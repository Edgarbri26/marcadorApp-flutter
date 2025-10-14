import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:marcador/models/inscription.dart';
import 'package:marcador/models/jugador.dart';
import 'package:marcador/models/match.dart';
import 'package:marcador/models/match_save.dart';
import 'package:marcador/models/set_result.dart';
import 'package:marcador/models/tournament.dart';

class ApiService {
  //String baseUrl = 'https://lpp-backend.onrender.com/api';
  // String localUrl = 'http://localhost:3000/api'; 192.168.1.125
  String localUrl = 'http://192.168.1.125:3000/api';
  // String localUrl = 'https://lpp-backend.onrender.com/api';

  Future<List<Jugador>> fetchJugadores() async {
    final response = await http.get(Uri.parse('$localUrl/player'));
    if (response.statusCode != 200) {
      throw Exception('Error al cargar jugadores');
    }

    final decoded = json.decode(response.body);
    // Si la API devuelve { data: [...] }
    final list =
        (decoded is Map)
            ? decoded['data'] as List<dynamic>? ?? []
            : decoded as List<dynamic>;

    return list
        .map((jsonMap) => Jugador.fromJson(jsonMap as Map<String, dynamic>))
        .toList();
  }

  Future<List<Jugador>> loadPlayerLocal() async {
    final response = await rootBundle.loadString('assets/config/player.json');
    final decoded = json.decode(response);
    // Si la API devuelve { data: [...] }
    final list =
        (decoded is Map)
            ? decoded['data'] as List<dynamic>? ?? []
            : decoded as List<dynamic>;

    return list
        .map((jsonMap) => Jugador.fromJson(jsonMap as Map<String, dynamic>))
        .toList();
  }

  Future<List<Tournament>> fetchTournaments() async {
    final response = await http.get(Uri.parse('$localUrl/tournament'));

    if (response.statusCode == 200) {
      final Map<String, dynamic> jsonBody = json.decode(response.body);
      // print(jsonBody);
      final tournamentsJson = jsonBody['data'];
      if (tournamentsJson is List) {
        return tournamentsJson
            .map((json) => Tournament.fromJson(json))
            .toList();
      } else {
        throw Exception('Formato inesperado en la respuesta de /tournament');
      }
    } else {
      throw Exception('Error al cargar torneos');
    }
  }

  Future<List<Match>> fetchMatches() async {
    final response = await http.get(Uri.parse('$localUrl/match'));

    if (response.statusCode == 200) {
      final Map<String, dynamic> jsonBody = json.decode(response.body);
      // print(jsonBody);
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
      // print(jsonBody);
      final inscriptionJson = jsonBody['data'];
      if (inscriptionJson is List) {
        return inscriptionJson
            .map((json) => Inscription.fromJson(json))
            .toList();
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
      // print('Error al crear el partido: ${response.body}');
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

    if (response.statusCode == 200 || response.statusCode == 201) {
      print('Set creado exitosamente: ${response.body}');
      final jsonBody = json.decode(response.body);

      // Intenta acceder a 'set', si no existe, usa 'data'
      final setData = jsonBody['set'] ?? jsonBody['data'];

      if (setData != null && setData['set_id'] != null) {
        return setData['set_id'] as int?;
      } else {
        print('Formato inesperado en la respuesta: ${response.body}');
        return null;
      }
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
      body: json.encode(match.toJsonPost()),
    );

    if (response.statusCode == 201 || response.statusCode == 200) {
      final jsonBody = json.decode(response.body);
      print("ide desde la respuesta  ${jsonBody['data']['match_id']}");
      return jsonBody['data']['match_id']; // Devuelve el ID del partido creado
    } else {
      print('Error al crear el partido: ${response.body}');
      return null;
    }
  }

  Future<bool> putMatch(Match matchSave) async {
    final url = Uri.parse('$localUrl/match/${matchSave.matchId}/result');

    final response = await http.put(
      url,
      headers: {'Content-Type': 'application/json'},
      body: json.encode(matchSave.toJsonResult()),
    );

    if (response.statusCode == 200) {
      print('Partido actualizado exitosamente: ${response.body}');
      return true; // Actualización exitosa
    } else {
      print('Error al actualizar el partido: ${response.body}');
      return false;
    }
  }


Future<int?> obtenerInscriptionIdPorCI(String ci, int idTournament) async {
  // Se asume el endpoint: '$localUrl/inscription/player/$ci'
  final response = await http.get(
    Uri.parse('$localUrl/inscription/player/$ci'),
    headers: {'Content-Type': 'application/json'},
  );

  if (response.statusCode == 200) {
    try {
      final data = jsonDecode(response.body);

      // Accedemos a la clave "data" que contiene la lista de inscripciones
      if (data['data'] != null && data['data'] is List) {
        final inscriptions = data['data'] as List;

        if (inscriptions.isNotEmpty) {
          // Buscamos la inscripción que coincida con el ID del torneo
          for (var insc in inscriptions) {
            
            // Filtramos por el ID del torneo para asegurarnos de tomar la correcta
            if (insc["tournament_id"] == idTournament) {
              
              // Retornamos "inscription_id", asegurando que sea un entero (int)
              if (insc["inscription_id"] is int) {
                return insc["inscription_id"] as int;
              }
              // Manejo si viniera como String
              if (insc["inscription_id"] is String) {
                return int.tryParse(insc["inscription_id"]);
              }
            }
          }
        }
      }
    } catch (e) {
      print("Error decodificando la respuesta JSON: $e");
    }
  } else {
    print("Error en la API. Status Code: ${response.statusCode}");
  }

  // Retorna null si no se encuentra la inscripción o si hubo un error en la API
  return null;
}

  Future<void> crearInscripcion({
    required int tournamentId,
    required String playerCi,
    int? teamId,
    int? seed,
  }) async {
    final url = Uri.parse('https://lpp-backend.onrender.com/api/inscription');

    final payload = {
      'tournament_id': tournamentId,
      'player_ci': playerCi,
      'team_id': teamId,
      'seed': seed,
    };

    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode(payload),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 201 && data['ok'] == true) {
        print('✅ Inscripción creada: ${data['inscription']}');
      } else {
        print('❌ Error en la inscripción: ${data['error']}');
      }
    } catch (e) {
      print('🔥 Error de red o servidor: $e');
    }
  }

  Future<List<String>> loadAuthorizedCI() async {
    final content = await rootBundle.loadString('assets/config/admin.json');
    final data = jsonDecode(content);
    return List<String>.from(data["ci"]);
  }

  Future<bool> authenticateAndVereficateAdmin(
    String ci,
    String password,
  ) async {
    final ciAutorized = await loadAuthorizedCI();

    if (!ciAutorized.contains(ci)) {
      throw Exception('Cédula no autorizada');
    }

    final response = await http.post(
      Uri.parse("$localUrl/credential/authenticate"),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
      body: jsonEncode({'player_ci': ci, 'password': password}),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['message'] == 'Autenticación exitosa';
    }
    return false;
  }
}
