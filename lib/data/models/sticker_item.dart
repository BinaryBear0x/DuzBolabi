import 'package:hive/hive.dart';

part 'sticker_item.g.dart';

@HiveType(typeId: 5)
class StickerItem extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String name;

  @HiveField(2)
  int price; // Coin cinsinden

  @HiveField(3)
  String assetPath; // Asset path

  @HiveField(4)
  double? positionX; // Buzdolabı üzerindeki pozisyon

  @HiveField(5)
  double? positionY;

  @HiveField(6)
  double scale; // Scale değeri (1.0 = normal)

  @HiveField(7)
  double rotation; // Rotation değeri (radian)

  StickerItem({
    required this.id,
    required this.name,
    required this.price,
    required this.assetPath,
    this.positionX,
    this.positionY,
    this.scale = 1.0,
    this.rotation = 0.0,
  });

  StickerItem copyWith({
    String? id,
    String? name,
    int? price,
    String? assetPath,
    double? positionX,
    double? positionY,
    double? scale,
    double? rotation,
  }) {
    return StickerItem(
      id: id ?? this.id,
      name: name ?? this.name,
      price: price ?? this.price,
      assetPath: assetPath ?? this.assetPath,
      positionX: positionX ?? this.positionX,
      positionY: positionY ?? this.positionY,
      scale: scale ?? this.scale,
      rotation: rotation ?? this.rotation,
    );
  }
}

