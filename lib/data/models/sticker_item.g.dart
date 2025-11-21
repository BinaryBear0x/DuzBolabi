// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sticker_item.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class StickerItemAdapter extends TypeAdapter<StickerItem> {
  @override
  final int typeId = 5;

  @override
  StickerItem read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return StickerItem(
      id: fields[0] as String,
      name: fields[1] as String,
      price: fields[2] as int,
      assetPath: fields[3] as String,
      positionX: fields[4] as double?,
      positionY: fields[5] as double?,
      scale: fields[6] as double,
      rotation: fields[7] as double,
    );
  }

  @override
  void write(BinaryWriter writer, StickerItem obj) {
    writer
      ..writeByte(8)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.price)
      ..writeByte(3)
      ..write(obj.assetPath)
      ..writeByte(4)
      ..write(obj.positionX)
      ..writeByte(5)
      ..write(obj.positionY)
      ..writeByte(6)
      ..write(obj.scale)
      ..writeByte(7)
      ..write(obj.rotation);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is StickerItemAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
