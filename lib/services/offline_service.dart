import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:marcador/models/match.dart';
import 'package:marcador/models/match_repository.dart';
import 'package:marcador/models/match_save.dart';
import 'package:marcador/services/api_services.dart';

class OfflineService {
  static final OfflineService _instance = OfflineService._internal();
  factory OfflineService() => _instance;
  OfflineService._internal();

  final Connectivity _connectivity = Connectivity();
  StreamSubscription<List<ConnectivityResult>>? _connectivitySubscription;
  bool _isSyncing = false;
  final MatchRepository _repo = MatchRepository();
  final ApiService _api = ApiService();

  /// Inicializa el listener de conectividad
  void init() {
    _connectivitySubscription = _connectivity.onConnectivityChanged.listen((
      results,
    ) {
      if (!results.contains(ConnectivityResult.none)) {
        print("🔌 Conexión restaurada. Intentando sincronizar...");
        syncPendingMatches();
      }
    });

    // Intenta sincronizar al inicio si hay red
    syncPendingMatches();
  }

  /// Intenta guardar y subir inmediatamente si hay red.
  Future<void> tryUploadMatch(MatchSave matchSave) async {
    final results = await _connectivity.checkConnectivity();
    if (results.contains(ConnectivityResult.none)) {
      print("📴 Sin conexión. Partido ${matchSave.matchId} permanecerá local.");
      return;
    }

    await _uploadMatch(matchSave);
  }

  /// Sube los partidos pendientes del repositorio
  Future<void> syncPendingMatches() async {
    if (_isSyncing) return;

    final results = await _connectivity.checkConnectivity();
    if (results.contains(ConnectivityResult.none)) return;

    _isSyncing = true;

    // Obtener partidos no sincronizados desde Hive
    final pending = _repo.getUnsyncedMatches();

    if (pending.isEmpty) {
      _isSyncing = false;
      return;
    }

    print("🔄 Sincronizando ${pending.length} partidos pendientes...");

    for (var matchSave in pending) {
      await _uploadMatch(matchSave);
    }

    _isSyncing = false;
  }

  Future<void> _uploadMatch(MatchSave matchSave) async {
    try {
      // Convertir MatchSave a Match para API
      Match tempMatch = Match(
        matchId: matchSave.matchId,
        tournamentId: matchSave.tournamentId,
        inscription1Id: matchSave.inscription1Id,
        inscription2Id: matchSave.inscription2Id,
        winnerInscriptionId: matchSave.winnerInscriptionId,
        status: 'finished',
        round: matchSave.round,
        date: DateTime.now().toIso8601String(),
        ciWiner: matchSave.ciWiner,
        ci1: matchSave.ci1,
        ci2: matchSave.ci2,
      );

      bool success = await _api.putMatch(tempMatch);

      if (success) {
        // Subir sets si existen
        if (matchSave.setsResults.isNotEmpty) {
          for (var setResult in matchSave.setsResults) {
            setResult.matchId = matchSave.matchId;
            await _api.postSet(setResult);
          }
        }

        await _repo.markMatchAsSynced(matchSave);
        print("✅ Partido ${matchSave.matchId} sincronizado correctamente.");
      } else {
        print("❌ Falló sincronización de partido ${matchSave.matchId}.");
      }
    } catch (e) {
      print("🔥 Error subiendo match ${matchSave.matchId}: $e");
    }
  }

  void dispose() {
    _connectivitySubscription?.cancel();
  }
}
