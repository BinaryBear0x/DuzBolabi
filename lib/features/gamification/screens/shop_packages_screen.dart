import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/spacing.dart';
import '../providers/shop_provider.dart';
import '../providers/game_state_provider.dart';
import '../providers/economy_provider.dart';

class ShopPackagesScreen extends ConsumerWidget {
  const ShopPackagesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final packages = ref.watch(availablePackagesProvider);
    final statsAsync = ref.watch(gameStateProvider);

    return statsAsync.when(
      data: (stats) {
        return ListView.builder(
          padding: AppSpacing.screenPadding,
          itemCount: packages.length,
          itemBuilder: (context, index) {
            final package = packages[index];
            final ownedItems = package.items.where((id) => stats.ownsItem(id)).length;
            final allOwned = ownedItems == package.items.length;
            final canAfford = stats.coin >= package.price;

            return Card(
              margin: EdgeInsets.only(bottom: AppSpacing.md),
              shape: RoundedRectangleBorder(
                borderRadius: AppSpacing.borderRadiusXL,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Package preview image
                  ClipRRect(
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(24.0),
                    ),
                    child: AspectRatio(
                      aspectRatio: 16 / 9,
                      child: Image.asset(
                        package.previewAsset,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            color: Theme.of(context).colorScheme.surface,
                            child: Icon(
                              Icons.inventory_2,
                              size: 64,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                          );
                        },
                      ),
                    ),
                  ),

                  Padding(
                    padding: const EdgeInsets.all(AppSpacing.md),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          package.name,
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                        const SizedBox(height: AppSpacing.xs),
                        Text(
                          package.description,
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: Theme.of(context)
                                    .colorScheme
                                    .onSurface
                                    .withOpacity(0.7),
                              ),
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        Text(
                          'İçerik: ${package.items.length} öğe',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                        if (ownedItems > 0)
                          Text(
                            '$ownedItems / ${package.items.length} öğe sahip olunuyor',
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: Theme.of(context).colorScheme.primary,
                                ),
                          ),
                        const SizedBox(height: AppSpacing.md),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              '${package.price} Coin',
                              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: Theme.of(context).colorScheme.primary,
                                  ),
                            ),
                            allOwned
                                ? TextButton.icon(
                                    icon: const Icon(Icons.check),
                                    label: const Text('Tümü Sahip'),
                                    onPressed: null,
                                  )
                                : canAfford
                                    ? ElevatedButton(
                                        onPressed: () {
                                          _showPurchaseDialog(
                                            context,
                                            ref,
                                            package.id,
                                            package.name,
                                            package.price,
                                          );
                                        },
                                        child: const Text('Satın Al'),
                                      )
                                    : TextButton(
                                        onPressed: null,
                                        child: Text(
                                          'Yetersiz Coin',
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodyMedium
                                              ?.copyWith(
                                                color: Theme.of(context).colorScheme.error,
                                              ),
                                        ),
                                      ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
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

  void _showPurchaseDialog(
    BuildContext context,
    WidgetRef ref,
    String packageId,
    String packageName,
    int price,
  ) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: AppSpacing.borderRadiusXXL,
        ),
        title: const Text('Paket Satın Al'),
        content: Text('Bu paket $price coin. Satın almak ister misin?'),
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
                    itemId: packageId,
                    itemName: packageName,
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

