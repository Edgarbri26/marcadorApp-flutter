class SetResult {
  final int matchId;
  final int setNumber;
  final int scoreParticipant1;
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
