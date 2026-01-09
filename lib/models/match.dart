class Match {
  int? matchId;
  final int tournamentId;
  int? inscription1Id;
  int? inscription2Id;
  String? ci1;
  String? ci2;
  String? ciWiner;
  final String round;
  String date;
  int? winnerInscriptionId;
  String status;
  String? nombre1;
  String? nombre2;
  int? pointsSelected;
  int? setsSelected;

  Match({
    this.matchId,
    required this.tournamentId,
    this.inscription1Id,
    this.inscription2Id,
    this.winnerInscriptionId,
    required this.status,
    required this.round,
    required this.date,
    this.nombre1,
    this.nombre2,
    this.pointsSelected,
    this.setsSelected,
    this.ci1,
    this.ci2,
    this.ciWiner,
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

  Map<String, dynamic> toJsonPost() => {
    'tournament_id': tournamentId,
    'inscription1_id': inscription1Id,
    'inscription2_id': inscription2Id,
    'winner_inscription_id': winnerInscriptionId,
    'match_datetime': date,
    'round': round,
    'status': status,
  };

  Map<String, dynamic> toJsonResult() => {
    'winner_inscription_id': winnerInscriptionId,
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
      ci1: '',
      ci2: '',
    );
  }
  factory Match.fromJsonResult(Map<String, dynamic> json) {
    return Match(
      winnerInscriptionId: json['winner_inscription_id'],
      // Dummy data required by constructor
      tournamentId: 0,
      status: '',
      round: '',
      date: '',
    );
  }
}
