import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/widgets/main_scaffold.dart';
import '../../../core/constants/spacing.dart';
import '../providers/game_state_provider.dart';
import '../providers/shop_provider.dart';
import '../widgets/level_xp_bar.dart';
import '../widgets/fridge_view.dart';
import '../widgets/level_up_modal.dart';

class GameScreen extends ConsumerStatefulWidget {
  const GameScreen({super.key});

  @override
  ConsumerState<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends ConsumerState<GameScreen> {
  int? _lastLevel;

  @override
  Widget build(BuildContext context) {
    final statsAsync = ref.watch(gameStateProvider);
    final activeSkin = ref.watch(activeSkinProvider);

    return MainScaffold(
      currentRoute: '/game',
      child: statsAsync.when(
        data: (stats) {
          // Level up kontrolü
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (_lastLevel != null && stats.currentLevel > _lastLevel!) {
              // Level up oldu!
              _showLevelUpModal(context, stats.currentLevel);
            }
            _lastLevel = stats.currentLevel;
          });

          return Stack(
            children: [
              // Buzdolabı görünümü - Full screen
              FridgeView(
                activeSkin: activeSkin,
              ),

              // Üstte Level + XP Bar
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: SafeArea(
                  bottom: false,
                  child: Padding(
                    padding: AppSpacing.screenPadding,
                    child: LevelXPBar(
                      xp: stats.xp,
                      coin: stats.coin,
                    ),
                  ),
                ),
              ),

              // Altta "Mağaza / Özelleştir" butonu
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: SafeArea(
                  top: false,
                  child: Padding(
                    padding: EdgeInsets.only(
                      bottom: MediaQuery.of(context).padding.bottom + 16,
                      left: AppSpacing.md,
                      right: AppSpacing.md,
                    ),
                    child: ElevatedButton.icon(
                      onPressed: () {
                        context.push('/game/shop');
                      },
                      icon: const Icon(Icons.store),
                      label: const Text('Mağaza / Özelleştir'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context).colorScheme.primary,
                        foregroundColor: Theme.of(context).colorScheme.onPrimary,
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.xl,
                          vertical: AppSpacing.md,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: AppSpacing.borderRadiusLG,
                        ),
                        elevation: 4,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          );
        },
        loading: () => const Center(
          child: CircularProgressIndicator(),
        ),
        error: (error, stack) => Center(
          child: Text('Hata: $error'),
        ),
      ),
    );
  }

  void _showLevelUpModal(BuildContext context, int newLevel) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) => LevelUpModal(level: newLevel),
    );
  }
}

