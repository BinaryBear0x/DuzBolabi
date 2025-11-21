import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/repositories/user_stats_repository.dart';
import '../../../data/models/user_stats.dart';

final userStatsRepositoryProvider = Provider<UserStatsRepository>((ref) {
  return UserStatsRepository();
});

final userStatsProvider = FutureProvider<UserStats>((ref) async {
  final repository = ref.watch(userStatsRepositoryProvider);
  return await repository.getUserStats();
});

