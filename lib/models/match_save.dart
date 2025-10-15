import 'package:marcador/models/set_result.dart';
import 'package:hive/hive.dart';

part 'match_save.g.dart'; // Corregí el nombre del archivo generado a match_save.g.dart

@HiveType(typeId: 1) // ID único para MatchSave
class MatchSave {
  @HiveField(0)
  int? winnerInscriptionId;

  @HiveField(1)
  int? matchId;

  @HiveField(2)
  final List<SetResult> setsResults;

  @HiveField(3) // <-- Asigna el siguiente índice HiveField disponible
  bool isSynced; // Nuevo campo para indicar si se ha sincronizado

  @HiveField(4)
  final String player1Name;

  @HiveField(5)
  final String player2Name;

  @HiveField(6)
  final String winnerName;

  @HiveField(7)
  final String round;

  @HiveField(8)
  int? id;

  @HiveField(9)
  final String ci1;

  @HiveField(10)
  final String ci2;

  @HiveField(11)
  final int tournamentId;

  @HiveField(12)
  String? ciWiner;

  @HiveField(13)
  int? inscription1Id;

  @HiveField(14)
  int? inscription2Id;

  MatchSave({
    this.winnerInscriptionId,
    this.matchId,
    required this.setsResults,
    this.isSynced = false,
    required this.player1Name,
    required this.player2Name,
    required this.winnerName,
    required this.round,
    required this.ci1,
    required this.ci2,
    required this.tournamentId,
    this.ciWiner,
  });

  Map<String, dynamic> toJsonResult() => {
    'winner_inscription_id': winnerInscriptionId,
  };

  Map<String, dynamic> toJsonSets() => {
    'sets': setsResults.map((set) => set.toJson()).toList(),
  };
}
