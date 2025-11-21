import '../../data/models/product.dart';
import '../../data/models/product_status.dart';
import '../../data/repositories/user_stats_repository.dart';
import '../../core/constants/app_constants.dart';

class GamificationService {
  final UserStatsRepository _userStatsRepository;

  GamificationService(this._userStatsRepository);

  Future<void> handleProductStatusChange(
    Product product,
    ProductStatus oldStatus,
    ProductStatus newStatus,
  ) async {
    if (oldStatus == newStatus) return;

    // Handle consumed - Ürün tüketildiğinde +20 XP
    if (newStatus == ProductStatus.consumed &&
        oldStatus == ProductStatus.added) {
      // Her zaman XP ver (tüketilmesi iyi bir şey)
      await _userStatsRepository.addXP(AppConstants.xpProductConsumed);
      await _userStatsRepository.incrementConsumed();
      
      // Eski sistem ile uyumluluk için totalPoints'i de güncelle
      final stats = await _userStatsRepository.getUserStats();
      stats.totalPoints = stats.xp;
      await _userStatsRepository.updateUserStats(stats);
    }

    // Handle trashed - Ürün çöpe atıldığında -10 XP
    if (newStatus == ProductStatus.trashed &&
        oldStatus == ProductStatus.added) {
      // Her zaman XP kaybet (çöpe atılması kötü bir şey)
      await _userStatsRepository.addXP(AppConstants.xpProductTrashed);
      await _userStatsRepository.incrementTrashed();
      
      // Eski sistem ile uyumluluk için totalPoints'i de güncelle
      final stats = await _userStatsRepository.getUserStats();
      stats.totalPoints = stats.xp;
      await _userStatsRepository.updateUserStats(stats);
    }

    // Handle added
    if (newStatus == ProductStatus.added &&
        oldStatus != ProductStatus.added) {
      await _userStatsRepository.incrementAdded();
    }
  }

  Future<void> handleProductAdded(Product product) async {
    await _userStatsRepository.incrementAdded();
  }
}

