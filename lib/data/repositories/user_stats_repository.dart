import 'package:hive_flutter/hive_flutter.dart';
import '../models/user_stats.dart';

class UserStatsRepository {
  static const String _boxName = 'user_stats';
  static const String _statsKey = 'user_stats';

  Box get _box => Hive.box(_boxName);

  Future<UserStats> getUserStats() async {
    try {
      final stats = _box.get(_statsKey);
      if (stats == null) {
        final newStats = UserStats();
        await _box.put(_statsKey, newStats);
        return newStats;
      }
      
      // UserStats olarak cast et
      final oldStats = stats as UserStats;
      
      // Migration: Eski verilerde xp 0 ise ve totalPoints 0'dan büyükse migration yap
      // Bu, eski verilerin yeni formata geçişi için
      if (oldStats.xp == 0 && oldStats.totalPoints > 0) {
        final migratedStats = UserStats(
          totalAdded: oldStats.totalAdded,
          totalConsumed: oldStats.totalConsumed,
          totalTrashed: oldStats.totalTrashed,
          totalPoints: oldStats.totalPoints,
          currentLevel: oldStats.currentLevel,
          xp: oldStats.totalPoints, // Eski totalPoints'i xp olarak kullan
          coin: oldStats.coin,
          ownedItems: oldStats.ownedItems,
          activeSkin: oldStats.activeSkin,
        );
        migratedStats.updateLevel(); // Level'i yeniden hesapla
        await _box.put(_statsKey, migratedStats);
        return migratedStats;
      }
      
      return oldStats;
    } catch (e) {
      // Cast hatası - muhtemelen eski format veya eksik field'lar
      // Eski veriyi sil ve yeni oluştur
      try {
        // Eğer key varsa sil
        if (_box.containsKey(_statsKey)) {
          await _box.delete(_statsKey);
        }
      } catch (_) {
        // Silme hatası - devam et
      }
      
      // Yeni stats oluştur
      final newStats = UserStats();
      await _box.put(_statsKey, newStats);
      return newStats;
    }
  }

  Future<void> updateUserStats(UserStats stats) async {
    stats.updateLevel();
    await _box.put(_statsKey, stats);
  }

  Future<void> incrementAdded() async {
    final stats = await getUserStats();
    stats.totalAdded++;
    await updateUserStats(stats);
  }

  Future<void> incrementConsumed() async {
    final stats = await getUserStats();
    stats.totalConsumed++;
    await updateUserStats(stats);
  }

  Future<void> incrementTrashed() async {
    final stats = await getUserStats();
    stats.totalTrashed++;
    await updateUserStats(stats);
  }

  // XP ekleme metodu
  Future<void> addXP(int xpAmount) async {
    final stats = await getUserStats();
    final oldLevel = stats.currentLevel;
    stats.addXP(xpAmount); // XP ekle ve level'i güncelle
    
    // Eski sistem ile uyumluluk için totalPoints'i de güncelle
    stats.totalPoints = stats.xp;
    
    await updateUserStats(stats);
    
    // Level up kontrolü (provider'da gösterilebilir)
    if (stats.currentLevel > oldLevel) {
      // Level up oldu!
    }
  }

  Future<void> addPoints(int points) async {
    final stats = await getUserStats();
    // Negatif puanlar eklenebilir (ceza sistemi için)
    // Ancak toplam puan 0'ın altına düşmemeli
    final newTotal = stats.totalPoints + points;
    stats.totalPoints = newTotal < 0 ? 0 : newTotal;
    await updateUserStats(stats);
  }

  // Coin ekleme metodu
  Future<void> addCoin(int coinAmount) async {
    final stats = await getUserStats();
    stats.addCoin(coinAmount);
    await updateUserStats(stats);
  }
}

