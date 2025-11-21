// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'skin_item.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class SkinItemAdapter extends TypeAdapter<SkinItem> {
  @override
  final int typeId = 4;

  @override
  SkinItem read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return SkinItem(
      id: fields[0] as String,
      name: fields[1] as String,
      price: fields[2] as int,
      previewAsset: fields[3] as String,
      rarity: fields[4] as String,
    );
  }

  @override
  void write(BinaryWriter writer, SkinItem obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.price)
      ..writeByte(3)
      ..write(obj.previewAsset)
      ..writeByte(4)
      ..write(obj.rarity);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SkinItemAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
