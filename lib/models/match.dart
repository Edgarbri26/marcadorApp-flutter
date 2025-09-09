class Match {
  final int matchId;
  final int tournamentId;
  final int inscription1Id;
  final int inscription2Id;
  final int winnerIncriptionId;
  final String matchDatetime;
  final String round;
  final String status;
  final List<SetResult> sets;

  Match({
    required this.matchId,
    required this.tournamentId,
    required this.inscription1Id,
    required this.inscription2Id,
    required this.winnerIncriptionId,
    required this.matchDatetime,
    required this.round,
    required this.status,
    required this.sets,
  });

  Map<String, dynamic> toJson() => {
    'tournament_id': tournamentId,
    'inscription1_id': inscription1Id,
    'inscription2_id': inscription2Id,
    'match_datetime': matchDatetime,
    'round': round,
    'status': status,
  };

  factory Match.fromJson(Map<String, dynamic> json) {
    return Match(
      matchId: json['match_id'],
      tournamentId: json['tournament_id'],
      inscription1Id: json['inscription1_id'],
      inscription2Id: json['inscription2_id'],
      winnerIncriptionId: json['winner_incription_id'],
      matchDatetime: json['match_datetime'],
      round: json['round'],
      status: json['status'],
      sets: (json['sets'] as List<dynamic>)
          .map((setJson) => SetResult.fromJson(setJson))
          .toList(),
    );
  }
}

class SetResult {
  final int setId;
  final int matchId;
  final int setNumber;
  final int scoreParticipant1;
  final int scoreParticipant2;

  SetResult({
    required this.setId,
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
      setId: json['set_id'],
      matchId: json['match_id'],
      setNumber: json['match_id'],
      scoreParticipant1: json['score_participant1'],
      scoreParticipant2: json['score_participant2'],
    );
  }
  
}
