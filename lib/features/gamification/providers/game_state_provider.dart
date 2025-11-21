import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/repositories/user_stats_repository.dart';
import '../../../data/models/user_stats.dart';

final gameStateRepositoryProvider = Provider<UserStatsRepository>((ref) {
  return UserStatsRepository();
});

final gameStateProvider = FutureProvider<UserStats>((ref) async {
  final repository = ref.watch(gameStateRepositoryProvider);
  return await repository.getUserStats();
});

// XP ve Level hesaplama fonksiyonları
final calculateLevelProvider = Provider.family<int, int>((ref, xp) {
  // Her level 1000 XP
  return (xp / 1000).floor() + 1;
});

final currentLevelXPProvider = Provider.family<int, int>((ref, xp) {
  // Mevcut level için toplam XP (örn: Level 4 için 4000 XP)
  final level = (xp / 1000).floor() + 1;
  return (level - 1) * 1000;
});

final nextLevelXPProvider = Provider.family<int, int>((ref, xp) {
  // Sonraki level için gerekli toplam XP
  final level = (xp / 1000).floor() + 1;
  return level * 1000;
});

final progressToNextLevelProvider = Provider.family<double, int>((ref, xp) {
  // Sonraki level'e ilerleme yüzdesi (0.0 - 1.0)
  final currentLevelXP = (xp / 1000).floor() * 1000;
  final nextLevelXP = ((xp / 1000).floor() + 1) * 1000;
  final progressXP = xp - currentLevelXP;
  final neededXP = nextLevelXP - currentLevelXP;
  if (neededXP == 0) return 1.0;
  return (progressXP / neededXP).clamp(0.0, 1.0);
});

