// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'product_status.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ProductStatusAdapter extends TypeAdapter<ProductStatus> {
  @override
  final int typeId = 2;

  @override
  ProductStatus read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return ProductStatus.added;
      case 1:
        return ProductStatus.consumed;
      case 2:
        return ProductStatus.trashed;
      default:
        return ProductStatus.added;
    }
  }

  @override
  void write(BinaryWriter writer, ProductStatus obj) {
    switch (obj) {
      case ProductStatus.added:
        writer.writeByte(0);
        break;
      case ProductStatus.consumed:
        writer.writeByte(1);
        break;
      case ProductStatus.trashed:
        writer.writeByte(2);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ProductStatusAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
