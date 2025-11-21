import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/spacing.dart';
import '../providers/shop_provider.dart';
import '../providers/game_state_provider.dart';
import '../providers/economy_provider.dart';

class ShopSkinsScreen extends ConsumerWidget {
  const ShopSkinsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final skins = ref.watch(availableSkinsProvider);
    final statsAsync = ref.watch(gameStateProvider);
    final activeSkin = ref.watch(activeSkinProvider);

    return statsAsync.when(
      data: (stats) {
        return ListView.builder(
          padding: AppSpacing.screenPadding,
          itemCount: skins.length,
          itemBuilder: (context, index) {
            final skin = skins[index];
            final isOwned = skin.price == 0 || stats.ownsItem(skin.id);
            final canAfford = stats.coin >= skin.price;
            final isActive = activeSkin == skin.id;

            return Card(
              margin: EdgeInsets.only(bottom: AppSpacing.md),
              shape: RoundedRectangleBorder(
                borderRadius: AppSpacing.borderRadiusXL,
                side: isActive
                    ? BorderSide(
                        color: Theme.of(context).colorScheme.primary,
                        width: 2,
                      )
                    : BorderSide.none,
              ),
              child: ListTile(
                contentPadding: const EdgeInsets.all(AppSpacing.md),
                leading: Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    borderRadius: AppSpacing.borderRadiusMD,
                    image: DecorationImage(
                      image: AssetImage(skin.previewAsset),
                      fit: BoxFit.cover,
                      onError: (exception, stackTrace) {
                        // Error builder kullanılamadığı için burada kontrol
                      },
                    ),
                    color: Theme.of(context).colorScheme.surface,
                    border: Border.all(
                      color: Theme.of(context).colorScheme.onSurface.withOpacity(0.2),
                    ),
                  ),
                  child: Image.asset(
                    skin.previewAsset,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        color: Theme.of(context).colorScheme.surface,
                        child: Icon(
                          Icons.palette,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      );
                    },
                  ),
                ),
                title: Text(
                  skin.name,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
                      ),
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      skin.price == 0 ? 'Ücretsiz' : '${skin.price} Coin',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    if (skin.rarity != 'common')
                      Container(
                        margin: const EdgeInsets.only(top: AppSpacing.xs),
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.sm,
                          vertical: AppSpacing.xs / 2,
                        ),
                        decoration: BoxDecoration(
                          color: _getRarityColor(skin.rarity).withOpacity(0.2),
                          borderRadius: AppSpacing.borderRadiusSM,
                        ),
                        child: Text(
                          _getRarityText(skin.rarity),
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: _getRarityColor(skin.rarity),
                                fontWeight: FontWeight.bold,
                                fontSize: 10,
                              ),
                        ),
                      ),
                  ],
                ),
                trailing: isActive
                    ? Icon(
                        Icons.check_circle,
                        color: Theme.of(context).colorScheme.primary,
                      )
                    : isOwned
                        ? ElevatedButton(
                            onPressed: () {
                              // Skin uygula
                              ref.read(activeSkinProvider.notifier).setActiveSkin(skin.id);
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('${skin.name} kaplaması uygulandı!'),
                                  backgroundColor: Theme.of(context).colorScheme.primary,
                                ),
                              );
                            },
                            child: const Text('Uygula'),
                          )
                        : canAfford
                            ? ElevatedButton(
                                onPressed: () {
                                  _showPurchaseDialog(
                                    context,
                                    ref,
                                    skin.id,
                                    skin.name,
                                    skin.price,
                                  );
                                },
                                child: const Text('Satın Al'),
                              )
                            : Text(
                                'Yetersiz Coin',
                                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                      color: Theme.of(context).colorScheme.error,
                                    ),
                              ),
              ),
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

  Color _getRarityColor(String rarity) {
    switch (rarity) {
      case 'rare':
        return Colors.blue;
      case 'epic':
        return Colors.purple;
      case 'legendary':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  String _getRarityText(String rarity) {
    switch (rarity) {
      case 'rare':
        return 'Nadir';
      case 'epic':
        return 'Efsanevi';
      case 'legendary':
        return 'Efsane';
      default:
        return 'Yaygın';
    }
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
        title: const Text('Kaplama Satın Al'),
        content: Text('Bu kaplama $price coin. Satın almak ister misin?'),
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
}

