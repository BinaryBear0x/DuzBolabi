// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_stats.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class UserStatsAdapter extends TypeAdapter<UserStats> {
  @override
  final int typeId = 3;

  @override
  UserStats read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return UserStats(
      totalAdded: fields[0] as int,
      totalConsumed: fields[1] as int,
      totalTrashed: fields[2] as int,
      totalPoints: fields[3] as int,
      currentLevel: fields[4] as int,
      xp: fields[5] == null ? 0 : fields[5] as int?,
      coin: fields[6] == null ? 0 : fields[6] as int?,
      ownedItems: fields[7] == null ? [] : (fields[7] as List?)?.cast<String>(),
      activeSkin: fields[8] == null ? 'default' : fields[8] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, UserStats obj) {
    writer
      ..writeByte(9)
      ..writeByte(0)
      ..write(obj.totalAdded)
      ..writeByte(1)
      ..write(obj.totalConsumed)
      ..writeByte(2)
      ..write(obj.totalTrashed)
      ..writeByte(3)
      ..write(obj.totalPoints)
      ..writeByte(4)
      ..write(obj.currentLevel)
      ..writeByte(5)
      ..write(obj.xp)
      ..writeByte(6)
      ..write(obj.coin)
      ..writeByte(7)
      ..write(obj.ownedItems)
      ..writeByte(8)
      ..write(obj.activeSkin);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UserStatsAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
