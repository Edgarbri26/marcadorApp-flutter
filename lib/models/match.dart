class Match {
  final int matchId;
  final int inscription1Id;
  final int inscription2Id;
  final int? winnerInscriptionId;
  final String status;
  String? nombre1;
  String? nombre2;

  Match({
    required this.matchId,
    required this.inscription1Id,
    required this.inscription2Id,
    this.winnerInscriptionId,
    required this.status,
    this.nombre1,
    this.nombre2,
  });

  Map<String, dynamic> toJson() => {
    'match_id': matchId,
    'winner_inscription_id': winnerInscriptionId,
    'status': status
    };

  factory Match.fromJson(Map<String, dynamic> json) {
    return Match(
      matchId: json['match_id'],
      inscription1Id: json['inscription1_id'],
      inscription2Id: json['inscription2_id'],
      status: json['status'],
    );
  }
}
