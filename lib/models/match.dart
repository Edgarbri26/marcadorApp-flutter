class Match {
  int? matchId;
  final int tournamentId;
  final int inscription1Id;
  final int inscription2Id;
  final String round;
  String date;
  int? winnerInscriptionId;
  String status;
  String? nombre1;
  String? nombre2;
  int? numSets;

  Match({
    this.matchId,
    required this.tournamentId,
    required this.inscription1Id,
    required this.inscription2Id,
    this.winnerInscriptionId,
    required this.status,
    required this.round,
    required this.date,
    this.nombre1,
    this.nombre2,
    this.numSets,
  });

  Map<String, dynamic> toJson() => {
    'match_id': matchId,
    'tournament_id': tournamentId,
    'inscription1_id': inscription1Id,
    'inscription2_id': inscription2Id,
    'winner_inscription_id': winnerInscriptionId,
    'status': status,
    'round': round,
    'match_datetime': date,
  };

  factory Match.fromJson(Map<String, dynamic> json) {
    return Match(
      matchId: json['match_id'],
      tournamentId: json['tournament_id'],
      inscription1Id: json['inscription1_id'],
      inscription2Id: json['inscription2_id'],
      status: json['status'],
      round: json['round'],
      date: json['round'],
    );
  }
}
