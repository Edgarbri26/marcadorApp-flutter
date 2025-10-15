// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'match_save.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class MatchSaveAdapter extends TypeAdapter<MatchSave> {
  @override
  final int typeId = 1;

  @override
  MatchSave read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return MatchSave(
      winnerInscriptionId: fields[0] as int?,
      matchId: fields[1] as int?,
      setsResults: (fields[2] as List).cast<SetResult>(),
      isSynced: fields[3] as bool,
      player1Name: fields[4] as String,
      player2Name: fields[5] as String,
      winnerName: fields[6] as String,
      round: fields[7] as String,
      ci1: fields[9] as String,
      ci2: fields[10] as String,
      tournamentId: fields[11] as int,
      ciWiner: fields[12] as String?,
    )
      ..id = fields[8] as int?
      ..inscription1Id = fields[13] as int?
      ..inscription2Id = fields[14] as int?;
  }

  @override
  void write(BinaryWriter writer, MatchSave obj) {
    writer
      ..writeByte(15)
      ..writeByte(0)
      ..write(obj.winnerInscriptionId)
      ..writeByte(1)
      ..write(obj.matchId)
      ..writeByte(2)
      ..write(obj.setsResults)
      ..writeByte(3)
      ..write(obj.isSynced)
      ..writeByte(4)
      ..write(obj.player1Name)
      ..writeByte(5)
      ..write(obj.player2Name)
      ..writeByte(6)
      ..write(obj.winnerName)
      ..writeByte(7)
      ..write(obj.round)
      ..writeByte(8)
      ..write(obj.id)
      ..writeByte(9)
      ..write(obj.ci1)
      ..writeByte(10)
      ..write(obj.ci2)
      ..writeByte(11)
      ..write(obj.tournamentId)
      ..writeByte(12)
      ..write(obj.ciWiner)
      ..writeByte(13)
      ..write(obj.inscription1Id)
      ..writeByte(14)
      ..write(obj.inscription2Id);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MatchSaveAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
