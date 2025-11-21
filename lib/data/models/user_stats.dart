import 'package:hive/hive.dart';

part 'user_stats.g.dart';

@HiveType(typeId: 3)
class UserStats extends HiveObject {
  @HiveField(0)
  int totalAdded;

  @HiveField(1)
  int totalConsumed;

  @HiveField(2)
  int totalTrashed;

  @HiveField(3)
  int totalPoints;

  @HiveField(4)
  int currentLevel;

  @HiveField(5, defaultValue: 0)
  int xp; // Yeni: Experience points

  @HiveField(6, defaultValue: 0)
  int coin; // Yeni: Coin

  @HiveField(7, defaultValue: <String>[])
  List<String> ownedItems; // Yeni: Satın alınan item ID'leri

  @HiveField(8, defaultValue: 'default')
  String activeSkin; // Yeni: Aktif skin ID

  UserStats({
    this.totalAdded = 0,
    this.totalConsumed = 0,
    this.totalTrashed = 0,
    this.totalPoints = 0,
    this.currentLevel = 1,
    int? xp,
    int? coin,
    List<String>? ownedItems,
    String? activeSkin,
  }) : xp = xp ?? 0,
       coin = coin ?? 0,
       ownedItems = ownedItems ?? [],
       activeSkin = activeSkin ?? 'default';

  // Level hesaplama: Her level 1000 XP
  void updateLevel() {
    currentLevel = (xp / 1000).floor() + 1;
    // Eski sistem ile uyumluluk için totalPoints'i de güncelle
    totalPoints = xp;
  }

  // XP ekleme ve level kontrolü
  void addXP(int amount) {
    // Negatif XP de eklenebilir (ceza sistemi için)
    // XP 0'ın altına düşmemeli
    xp += amount;
    if (xp < 0) {
      xp = 0;
    }
    updateLevel();
    // Level up olup olmadığını kontrol et (provider'da kullanılacak)
  }

  // Coin ekleme
  void addCoin(int amount) {
    coin += amount;
  }

  // Coin harcama
  bool spendCoin(int amount) {
    if (coin >= amount) {
      coin -= amount;
      return true;
    }
    return false;
  }

  // Item satın alma kontrolü
  bool ownsItem(String itemId) {
    return ownedItems.contains(itemId);
  }

  // Item ekleme
  void addOwnedItem(String itemId) {
    if (!ownedItems.contains(itemId)) {
      ownedItems = [...ownedItems, itemId];
    }
  }

  UserStats copyWith({
    int? totalAdded,
    int? totalConsumed,
    int? totalTrashed,
    int? totalPoints,
    int? currentLevel,
    int? xp,
    int? coin,
    List<String>? ownedItems,
    String? activeSkin,
  }) {
    return UserStats(
      totalAdded: totalAdded ?? this.totalAdded,
      totalConsumed: totalConsumed ?? this.totalConsumed,
      totalTrashed: totalTrashed ?? this.totalTrashed,
      totalPoints: totalPoints ?? this.totalPoints,
      currentLevel: currentLevel ?? this.currentLevel,
      xp: xp ?? this.xp,
      coin: coin ?? this.coin,
      ownedItems: ownedItems ?? this.ownedItems,
      activeSkin: activeSkin ?? this.activeSkin,
    );
  }
}

