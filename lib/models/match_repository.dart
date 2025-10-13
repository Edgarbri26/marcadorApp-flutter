import 'package:hive_flutter/hive_flutter.dart';
import 'package:marcador/models/match_save.dart';
import 'package:marcador/models/set_result.dart';

class MatchRepository {
  static final MatchRepository _instance = MatchRepository._internal();
  static const String _boxName = 'pending_matches_box';
  late Box<MatchSave> _matchBox;

  factory MatchRepository() {
    return _instance;
  }

  //esto es para singleton pattern/ para que solo haya una instancia
  MatchRepository._internal();

  Box<MatchSave> get matchBox => _matchBox;

  // 1. Inicialización (sin cambios)
  Future<void> init() async {
    await Hive.initFlutter();

    // Registrar los TypeAdapters generados
    if (!Hive.isAdapterRegistered(MatchSaveAdapter().typeId)) {
      Hive.registerAdapter(MatchSaveAdapter());
    }
    if (!Hive.isAdapterRegistered(SetResultAdapter().typeId)) {
      Hive.registerAdapter(SetResultAdapter());
    }

    _matchBox = await Hive.openBox<MatchSave>(_boxName);
    print('✅ Hive MatchRepository inicializado.');
  }

  /// Guarda o actualiza un MatchSave usando su matchId como clave de Hive.
  Future<void> savePendingMatch(MatchSave match) async {
    // Convierte el ID numérico a String para usarlo como clave de Hive.
    final hiveKey = match.matchId.toString();
    await _matchBox.put(hiveKey, match);
    print('💾 Partido ID ${match.matchId} guardado/actualizado localmente.');
  }

  /// Recupera la lista de partidos que aún no se han subido al servidor.
  List<MatchSave> getUnsyncedMatches() {
    return _matchBox.values.where((match) => match.isSynced == false).toList();
  }

  /// Marca un partido como sincronizado.
  Future<void> markMatchAsSynced(MatchSave match) async {
    final hiveKey = match.matchId.toString();

    // 1. Modificar el objeto en la memoria
    match.isSynced = true;

    // 2. Guardar el objeto actualizado con la misma clave.
    await _matchBox.put(hiveKey, match);
    print(
      '🔄 Partido ID ${match.matchId} actualizado a "Sincronizado" en Hive.',
    );
  }

  /// Elimina un partido de Hive por su ID.
  Future<void> deleteMatchById(int id) async {
    await _matchBox.delete(id.toString());
    print('🗑️ Partido ID $id eliminado permanentemente.');
  }

  /// Elimina todos los partidos sincronizados (limpieza).
  Future<void> deleteAllMatches() async {
    await matchBox.clear();
  }
}
