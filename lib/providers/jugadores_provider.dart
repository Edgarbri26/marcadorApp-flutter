import 'package:flutter/material.dart';
import 'package:marcador/models/jugador.dart';
import 'package:marcador/services/api_services.dart';

class JugadoresProvider extends ChangeNotifier {
  final ApiService _apiService = ApiService();

  List<Jugador> _jugadores = [];
  bool _isLoading = false;
  String? _error;

  List<Jugador> get jugadores => _jugadores;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> fetchJugadores() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      print('JugadoresProvider: Starting fetch...');
      final todos = await _apiService.fetchJugadores();
      // Filtrar solo los activos
      _jugadores = todos.where((j) => j.status).toList();
      print(
        'JugadoresProvider: Fetch success. Total: ${todos.length}, Activos: ${_jugadores.length}',
      );
    } catch (e) {
      print('JugadoresProvider: Error: $e');
      _error = e.toString();
      _jugadores = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
