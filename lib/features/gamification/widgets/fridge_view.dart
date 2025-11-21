import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/shop_provider.dart';
import '../providers/game_state_provider.dart';
import 'positioned_sticker.dart';

class FridgeView extends ConsumerWidget {
  final String activeSkin;

  const FridgeView({
    super.key,
    required this.activeSkin,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ownedItemsAsync = ref.watch(gameStateProvider);
    final stickerPositions = ref.watch(stickerPositionsProvider);
    final availableStickers = ref.watch(availableStickersProvider);

    return ownedItemsAsync.when(
      data: (stats) {
        // Satın alınan sticker'ları filtrele
        final ownedStickerIds = stats.ownedItems
            .where((id) => availableStickers.any((s) => s.id == id))
            .toList();

        return Stack(
          children: [
            // Buzdolabı arka plan görseli
            Positioned.fill(
              child: RepaintBoundary(
                child: Image.asset(
                  'assets/fridge/fridge_cartoon.png',
                  fit: BoxFit.cover,
                  cacheWidth: 600,
                  cacheHeight: 900,
                  gaplessPlayback: true,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      color: _getSkinColor(context, activeSkin),
                      child: Center(
                        child: Icon(
                          Icons.kitchen,
                          size: 200,
                          color: Theme.of(context)
                              .textTheme
                              .bodySmall
                              ?.color
                              ?.withOpacity(0.5) ??
                              Theme.of(context).colorScheme.onSurface,
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),

            // Skin overlay - Arka plana uygulanır
            if (activeSkin != 'default')
              Positioned.fill(
                child: RepaintBoundary(
                  child: Image.asset(
                    'assets/skins/skin_$activeSkin.png',
                    fit: BoxFit.cover,
                    cacheWidth: 600,
                    cacheHeight: 900,
                    gaplessPlayback: true,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        color: _getSkinColor(context, activeSkin).withOpacity(0.3),
                      );
                    },
                  ),
                ),
              ),

            // Sticker'lar - Buzdolabı üzerinde konumlandırılmış
            ...ownedStickerIds.map((stickerId) {
              final sticker = availableStickers.firstWhere(
                (s) => s.id == stickerId,
                orElse: () => availableStickers.first,
              );
              final position = stickerPositions[stickerId];

              return PositionedSticker(
                sticker: sticker,
                position: position,
              );
            }),
          ],
        );
      },
      loading: () => const Center(
        child: CircularProgressIndicator(),
      ),
      error: (error, stack) => Center(
        child: Text('Hata: $error'),
      ),
    );
  }

  Color _getSkinColor(BuildContext context, String skin) {
    // Tüm skin'ler için surface rengi
    return Theme.of(context).colorScheme.surface;
  }
}

