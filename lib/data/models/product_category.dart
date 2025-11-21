import 'package:hive/hive.dart';

part 'product_category.g.dart';

@HiveType(typeId: 1)
enum ProductCategory {
  @HiveField(0)
  dairy,
  @HiveField(1)
  meat,
  @HiveField(2)
  fruitVeg,
  @HiveField(3)
  packaged,
  @HiveField(4)
  frozen,
  @HiveField(5)
  other;

  String get displayName {
    switch (this) {
      case ProductCategory.dairy:
        return 'Süt Ürünleri';
      case ProductCategory.meat:
        return 'Et & Tavuk';
      case ProductCategory.fruitVeg:
        return 'Meyve & Sebze';
      case ProductCategory.packaged:
        return 'Paketli Gıda';
      case ProductCategory.frozen:
        return 'Dondurulmuş';
      case ProductCategory.other:
        return 'Diğer';
    }
  }
}

