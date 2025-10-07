class Tournament {
  final int tournamentId;
  final String name;


  Tournament({
    required this.tournamentId,
    required this.name, 
  });

  factory Tournament.fromJson(Map<String, dynamic> json) {
    return Tournament(
      tournamentId: json['tournament_id'],
      name: json['name'],
    );
  }
}
