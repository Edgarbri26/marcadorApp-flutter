import 'package:marcador/models/setresult.dart';

class Match {
  final int matchId;
  final int inscription1Id;
  final int inscription2Id;
  final String status;
  final List<SetResult> sets;

  Match({
    required this.matchId,
    required this.inscription1Id,
    required this.inscription2Id,
    required this.status,
    required this.sets,
  });

 Map<String, dynamic> toJson() => {
    'inscription1_id': inscription1Id,
    'inscription2_id': inscription2Id,
    'status': status,
    'sets': sets.map((set) => set.toJson()).toList(),
  };

  factory Match.fromJson(Map<String, dynamic> json) {
    return Match(
      matchId: json['match_id'],
      inscription1Id: json['inscription1_id'],
      inscription2Id: json['inscription2_id'],
      status: json['status'],
      sets: (json['sets'] as List<dynamic>)
          .map((setJson) => SetResult.fromJson(setJson))
          .toList(),
    );
  }
}


 
