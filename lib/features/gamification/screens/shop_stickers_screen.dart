import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/spacing.dart';
import '../providers/shop_provider.dart';
import '../providers/game_state_provider.dart';
import '../providers/economy_provider.dart';
import '../widgets/shop_item_card.dart';

class ShopStickersScreen extends ConsumerWidget {
  const ShopStickersScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final stickers = ref.watch(availableStickersProvider);
    final statsAsync = ref.watch(gameStateProvider);

    return statsAsync.when(
      data: (stats) {
        return GridView.builder(
          padding: AppSpacing.screenPadding,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: AppSpacing.md,
            mainAxisSpacing: AppSpacing.md,
            childAspectRatio: 0.75,
          ),
          itemCount: stickers.length,
          itemBuilder: (context, index) {
            final sticker = stickers[index];
            final isOwned = stats.ownsItem(sticker.id);
            final canAfford = stats.coin >= sticker.price;

            return ShopItemCard(
              id: sticker.id,
              name: sticker.name,
              price: sticker.price,
              assetPath: sticker.assetPath,
              isOwned: isOwned,
              canAfford: canAfford,
              currentCoin: stats.coin,
              onPurchase: () async {
                if (isOwned) {
                  _showApplyStickerDialog(context, ref, sticker.id);
                } else {
                  _showPurchaseDialog(
                    context,
                    ref,
                    sticker.id,
                    sticker.name,
                    sticker.price,
                  );
                }
              },
            );
          },
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

  void _showPurchaseDialog(
    BuildContext context,
    WidgetRef ref,
    String itemId,
    String itemName,
    int price,
  ) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: AppSpacing.borderRadiusXXL,
        ),
        title: const Text('Sticker Satın Al'),
        content: Text('Bu sticker $price coin. Satın almak ister misin?'),
        actions: [
          TextButton(
            onPressed: () {
              if (dialogContext.mounted) {
                Navigator.pop(dialogContext);
              }
            },
            child: const Text('İptal'),
          ),
          ElevatedButton(
            onPressed: () async {
              final result = await ref.read(
                purchaseItemProvider(
                  PurchaseRequest(
                    itemId: itemId,
                    itemName: itemName,
                    price: price,
                  ),
                ).future,
              );

              if (dialogContext.mounted) {
                Navigator.pop(dialogContext);
              }

              if (context.mounted) {
                if (result.success) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(result.message),
                      backgroundColor: Theme.of(context).colorScheme.primary,
                    ),
                  );
                  ref.invalidate(gameStateProvider);
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(result.message),
                      backgroundColor: Theme.of(context).colorScheme.error,
                    ),
                  );
                }
              }
            },
            child: const Text('Satın Al'),
          ),
        ],
      ),
    );
  }

  void _showApplyStickerDialog(
    BuildContext context,
    WidgetRef ref,
    String stickerId,
  ) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: AppSpacing.borderRadiusXXL,
        ),
        title: const Text('Sticker Uygula'),
        content: const Text('Bu sticker buzdolabına uygulanacak. Devam etmek ister misin?'),
        actions: [
          TextButton(
            onPressed: () {
              if (dialogContext.mounted) {
                Navigator.pop(dialogContext);
              }
            },
            child: const Text('İptal'),
          ),
          ElevatedButton(
            onPressed: () {
              if (dialogContext.mounted) {
                Navigator.pop(dialogContext);
              }
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Sticker uygulandı! Buzdolabına bakabilirsiniz.'),
                ),
              );
            },
            child: const Text('Uygula'),
          ),
        ],
      ),
    );
  }
}
