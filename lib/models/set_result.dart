import 'package:hive/hive.dart';

part 'set_result.g.dart';

@HiveType(typeId: 2)
class SetResult {
  @HiveField(0)
  final int matchId;
  @HiveField(1)
  final int setNumber;
  @HiveField(2)
  final int scoreParticipant1;
  @HiveField(3)
  final int scoreParticipant2;

  SetResult({
    required this.matchId,
    required this.setNumber,
    required this.scoreParticipant1,
    required this.scoreParticipant2,
  });

  Map<String, dynamic> toJson() => {
    'match_id': matchId,
    'set_number': setNumber,
    'score_participant1': scoreParticipant1,
    'score_participant2': scoreParticipant2,
  };

  factory SetResult.fromJson(Map<String, dynamic> json) {
    return SetResult(
      matchId: json['match_id'] as int,
      setNumber: json['set_number'] as int,
      scoreParticipant1: json['score_participant1'],
      scoreParticipant2: json['score_participant2'],
    );
  }
}
