// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'shop_package.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ShopPackageAdapter extends TypeAdapter<ShopPackage> {
  @override
  final int typeId = 6;

  @override
  ShopPackage read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ShopPackage(
      id: fields[0] as String,
      name: fields[1] as String,
      description: fields[2] as String,
      items: (fields[3] as List).cast<String>(),
      price: fields[4] as int,
      previewAsset: fields[5] as String,
    );
  }

  @override
  void write(BinaryWriter writer, ShopPackage obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.description)
      ..writeByte(3)
      ..write(obj.items)
      ..writeByte(4)
      ..write(obj.price)
      ..writeByte(5)
      ..write(obj.previewAsset);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ShopPackageAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
