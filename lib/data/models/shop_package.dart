import 'package:hive/hive.dart';

part 'shop_package.g.dart';

@HiveType(typeId: 6)
class ShopPackage extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String name;

  @HiveField(2)
  String description;

  @HiveField(3)
  List<String> items; // Skin ve sticker ID'leri

  @HiveField(4)
  int price; // Coin cinsinden

  @HiveField(5)
  String previewAsset; // Package preview asset path

  ShopPackage({
    required this.id,
    required this.name,
    required this.description,
    required this.items,
    required this.price,
    required this.previewAsset,
  });

  ShopPackage copyWith({
    String? id,
    String? name,
    String? description,
    List<String>? items,
    int? price,
    String? previewAsset,
  }) {
    return ShopPackage(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      items: items ?? this.items,
      price: price ?? this.price,
      previewAsset: previewAsset ?? this.previewAsset,
    );
  }
}

