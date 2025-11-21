import 'package:hive/hive.dart';

part 'skin_item.g.dart';

@HiveType(typeId: 4)
class SkinItem extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String name;

  @HiveField(2)
  int price; // Coin cinsinden

  @HiveField(3)
  String previewAsset; // Asset path

  @HiveField(4)
  String rarity; // common, rare, epic, legendary

  SkinItem({
    required this.id,
    required this.name,
    required this.price,
    required this.previewAsset,
    this.rarity = 'common',
  });

  SkinItem copyWith({
    String? id,
    String? name,
    int? price,
    String? previewAsset,
    String? rarity,
  }) {
    return SkinItem(
      id: id ?? this.id,
      name: name ?? this.name,
      price: price ?? this.price,
      previewAsset: previewAsset ?? this.previewAsset,
      rarity: rarity ?? this.rarity,
    );
  }
}

