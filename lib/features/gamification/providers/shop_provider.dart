import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/models/skin_item.dart';
import '../../../data/models/sticker_item.dart';
import '../../../data/models/shop_package.dart';

// Mock shop data - Daha sonra repository'den gelecek
final availableSkinsProvider = Provider<List<SkinItem>>((ref) {
  return [
    SkinItem(
      id: 'default',
      name: 'Varsayılan Beyaz',
      price: 0,
      previewAsset: 'assets/skins/skin_default.png',
      rarity: 'common',
    ),
    SkinItem(
      id: 'blue',
      name: 'Mavi Taze',
      price: 100,
      previewAsset: 'assets/skins/skin_blue.png',
      rarity: 'rare',
    ),
    SkinItem(
      id: 'retro',
      name: 'Retro Sarı',
      price: 200,
      previewAsset: 'assets/skins/skin_retro.png',
      rarity: 'epic',
    ),
    SkinItem(
      id: 'gray',
      name: 'Metalik Gri',
      price: 300,
      previewAsset: 'assets/skins/skin_gray.png',
      rarity: 'legendary',
    ),
    SkinItem(
      id: 'pink',
      name: 'Pastel Pembe',
      price: 150,
      previewAsset: 'assets/skins/skin_pink.png',
      rarity: 'rare',
    ),
  ];
});

final availableStickersProvider = Provider<List<StickerItem>>((ref) {
  return [
    StickerItem(
      id: 'star',
      name: 'Altın Yıldız',
      price: 10,
      assetPath: 'assets/stickers/sticker_star.png',
    ),
    StickerItem(
      id: 'heart',
      name: 'Kırmızı Kalp',
      price: 15,
      assetPath: 'assets/stickers/sticker_heart.png',
    ),
    StickerItem(
      id: 'leaf',
      name: 'Yeşil Yaprak',
      price: 20,
      assetPath: 'assets/stickers/sticker_leaf.png',
    ),
    StickerItem(
      id: 'smile',
      name: 'Mutlu Yüz',
      price: 25,
      assetPath: 'assets/stickers/sticker_smile.png',
    ),
    StickerItem(
      id: 'fire',
      name: 'Ateş',
      price: 30,
      assetPath: 'assets/stickers/sticker_fire.png',
    ),
    StickerItem(
      id: 'trophy',
      name: 'Kupa',
      price: 50,
      assetPath: 'assets/stickers/sticker_trophy.png',
    ),
  ];
});

final availablePackagesProvider = Provider<List<ShopPackage>>((ref) {
  return [
    ShopPackage(
      id: 'starter',
      name: 'Başlangıç Paketi',
      description: 'İlk adımlar için mükemmel!',
      items: ['blue', 'star', 'heart'],
      price: 200,
      previewAsset: 'assets/packages/package_starter.png',
    ),
    ShopPackage(
      id: 'premium',
      name: 'Premium Paket',
      description: 'Tüm özel öğeler!',
      items: ['retro', 'gray', 'star', 'heart', 'leaf', 'smile', 'fire', 'trophy'],
      price: 600,
      previewAsset: 'assets/packages/package_premium.png',
    ),
    ShopPackage(
      id: 'minimalist',
      name: 'Minimalist Paket',
      description: 'Sade ve şık',
      items: ['pink', 'leaf', 'smile'],
      price: 350,
      previewAsset: 'assets/packages/package_minimalist.png',
    ),
  ];
});

// Aktif skin provider
final activeSkinProvider = NotifierProvider<ActiveSkinNotifier, String>(() {
  return ActiveSkinNotifier();
});

class ActiveSkinNotifier extends Notifier<String> {
  @override
  String build() {
    return 'default';
  }

  void setActiveSkin(String skinId) {
    state = skinId;
  }
}

// Sticker Position model
class StickerPosition {
  final double positionX;
  final double positionY;
  final double scale;
  final double rotation;

  StickerPosition({
    required this.positionX,
    required this.positionY,
    this.scale = 1.0,
    this.rotation = 0.0,
  });

  StickerPosition copyWith({
    double? positionX,
    double? positionY,
    double? scale,
    double? rotation,
  }) {
    return StickerPosition(
      positionX: positionX ?? this.positionX,
      positionY: positionY ?? this.positionY,
      scale: scale ?? this.scale,
      rotation: rotation ?? this.rotation,
    );
  }
}

// Satın alınan sticker'ların pozisyonları provider
final stickerPositionsProvider = NotifierProvider<StickerPositionsNotifier, Map<String, StickerPosition>>(() {
  return StickerPositionsNotifier();
});

class StickerPositionsNotifier extends Notifier<Map<String, StickerPosition>> {
  @override
  Map<String, StickerPosition> build() {
    return {};
  }

  void updatePosition(String stickerId, StickerPosition position) {
    state = {...state, stickerId: position};
  }

  void removePosition(String stickerId) {
    final newState = <String, StickerPosition>{...state};
    newState.remove(stickerId);
    state = newState;
  }
}

