import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/models/user_stats.dart';
import 'game_state_provider.dart';

// XP kazanma provider'ı
final addXPProvider = FutureProvider.family<UserStats, int>((ref, amount) async {
  final repository = ref.watch(gameStateRepositoryProvider);
  final stats = await repository.getUserStats();
  
  final oldLevel = stats.currentLevel;
  stats.addXP(amount);
  
  // Level up kontrolü
  if (stats.currentLevel > oldLevel) {
    // Level up oldu - UI'de modal gösterilecek
  }
  
  await repository.updateUserStats(stats);
  return stats;
});

// Coin kazanma provider'ı
final addCoinProvider = FutureProvider.family<UserStats, int>((ref, amount) async {
  final repository = ref.watch(gameStateRepositoryProvider);
  final stats = await repository.getUserStats();
  stats.addCoin(amount);
  await repository.updateUserStats(stats);
  return stats;
});

// Coin harcama provider'ı
final spendCoinProvider = FutureProvider.family<bool, int>((ref, amount) async {
  final repository = ref.watch(gameStateRepositoryProvider);
  final stats = await repository.getUserStats();
  
  if (stats.spendCoin(amount)) {
    await repository.updateUserStats(stats);
    return true;
  }
  return false;
});

// Satın alma provider'ı
final purchaseItemProvider = FutureProvider.family<PurchaseResult, PurchaseRequest>((ref, request) async {
  final repository = ref.watch(gameStateRepositoryProvider);
  final stats = await repository.getUserStats();
  
  // Zaten satın alınmış mı?
  if (stats.ownsItem(request.itemId)) {
    return PurchaseResult(
      success: false,
      message: 'Bu ürün zaten satın alınmış',
    );
  }
  
  // Yeterli coin var mı?
  if (stats.coin < request.price) {
    return PurchaseResult(
      success: false,
      message: 'Yetersiz coin. Gerekli: ${request.price}, Mevcut: ${stats.coin}',
    );
  }
  
  // Coin harca
  stats.spendCoin(request.price);
  stats.addOwnedItem(request.itemId);
  
  await repository.updateUserStats(stats);
  
  return PurchaseResult(
    success: true,
    message: '${request.itemName} satın alındı!',
  );
});

// XP kazanma örnekleri için helper functions
class EconomyHelper {
  // Ürün zamanında tüketildi → +20 XP
  static Future<void> rewardTimelyConsumption(WidgetRef ref) async {
    final repository = ref.read(gameStateRepositoryProvider);
    final stats = await repository.getUserStats();
    stats.addXP(20);
    await repository.updateUserStats(stats);
    ref.invalidate(gameStateProvider);
  }

  // Haftayı israf yapmadan bitir → +200 XP
  static Future<void> rewardNoWasteWeek(WidgetRef ref) async {
    final repository = ref.read(gameStateRepositoryProvider);
    final stats = await repository.getUserStats();
    stats.addXP(200);
    await repository.updateUserStats(stats);
    ref.invalidate(gameStateProvider);
  }

  // İlk 10 ürün ekleme → +10 coin
  static Future<void> rewardFirstTenProducts(WidgetRef ref) async {
    final repository = ref.read(gameStateRepositoryProvider);
    final stats = await repository.getUserStats();
    if (stats.totalAdded == 10 && !stats.ownsItem('achievement_first_10')) {
      stats.addCoin(10);
      stats.addOwnedItem('achievement_first_10');
      await repository.updateUserStats(stats);
      ref.invalidate(gameStateProvider);
    }
  }

  // 7 gün üst üste giriş → +50 coin
  static Future<void> rewardSevenDayStreak(WidgetRef ref) async {
    final repository = ref.read(gameStateRepositoryProvider);
    final stats = await repository.getUserStats();
    // Bu kontrol başka bir yerde yapılacak (login service vb.)
    stats.addCoin(50);
    await repository.updateUserStats(stats);
    ref.invalidate(gameStateProvider);
  }
}

class PurchaseRequest {
  final String itemId;
  final String itemName;
  final int price;

  PurchaseRequest({
    required this.itemId,
    required this.itemName,
    required this.price,
  });
}

class PurchaseResult {
  final bool success;
  final String message;

  PurchaseResult({
    required this.success,
    required this.message,
  });
}

