
class Match {
  final int matchId;
  final int inscription1Id;
  final int inscription2Id;
  final String status;

  Match({
    required this.matchId,
    required this.inscription1Id,
    required this.inscription2Id,
    required this.status,
  });

 Map<String, dynamic> toJson() => {
    'inscription1_id': inscription1Id,
    'inscription2_id': inscription2Id,
    'status': status,
  };

  factory Match.fromJson(Map<String, dynamic> json) {
    return Match(
      matchId: json['match_id'],
      inscription1Id: json['inscription1_id'],
      inscription2Id: json['inscription2_id'],
      status: json['status']
    );
  }
}
 
