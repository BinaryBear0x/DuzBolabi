// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'product_category.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ProductCategoryAdapter extends TypeAdapter<ProductCategory> {
  @override
  final int typeId = 1;

  @override
  ProductCategory read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return ProductCategory.dairy;
      case 1:
        return ProductCategory.meat;
      case 2:
        return ProductCategory.fruitVeg;
      case 3:
        return ProductCategory.packaged;
      case 4:
        return ProductCategory.frozen;
      case 5:
        return ProductCategory.other;
      default:
        return ProductCategory.dairy;
    }
  }

  @override
  void write(BinaryWriter writer, ProductCategory obj) {
    switch (obj) {
      case ProductCategory.dairy:
        writer.writeByte(0);
        break;
      case ProductCategory.meat:
        writer.writeByte(1);
        break;
      case ProductCategory.fruitVeg:
        writer.writeByte(2);
        break;
      case ProductCategory.packaged:
        writer.writeByte(3);
        break;
      case ProductCategory.frozen:
        writer.writeByte(4);
        break;
      case ProductCategory.other:
        writer.writeByte(5);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ProductCategoryAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
