// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'set_result.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class SetResultAdapter extends TypeAdapter<SetResult> {
  @override
  final int typeId = 2;

  @override
  SetResult read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return SetResult(
      matchId: fields[0] as int,
      setNumber: fields[1] as int,
      scoreParticipant1: fields[2] as int,
      scoreParticipant2: fields[3] as int,
    );
  }

  @override
  void write(BinaryWriter writer, SetResult obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.matchId)
      ..writeByte(1)
      ..write(obj.setNumber)
      ..writeByte(2)
      ..write(obj.scoreParticipant1)
      ..writeByte(3)
      ..write(obj.scoreParticipant2);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SetResultAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
