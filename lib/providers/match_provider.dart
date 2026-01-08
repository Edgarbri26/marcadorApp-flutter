import 'package:flutter/material.dart';
import 'package:marcador/models/match.dart';
import 'package:marcador/services/api_services.dart';

class MatchProvider extends ChangeNotifier {
  final ApiService _apiService = ApiService();

  List<Match> _matches = [];
  bool _isLoading = false;
  String? _error;

  List<Match> get matches => _matches;

  // Getter for pending matches - assuming 'En Juego' or null means pending/active
  // If we need a specific filter, we can adjust here.
  // For now, returning all fetched matches as the user might filter in UI or the API returns pending ones
  List<Match> get pendingMatches => _matches;

  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> fetchPendingMatches() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // Assuming fetchMatches returns the list of matches (pending and others)
      // If there is a specific endpoint for pending, it should be used here.
      // Based on context, we reuse fetchMatches for now.
      _matches = await _apiService.fetchMatches();
    } catch (e) {
      _error = e.toString();
      _matches = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
