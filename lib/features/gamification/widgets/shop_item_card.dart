import 'package:flutter/material.dart';
import '../../../core/constants/spacing.dart';

class ShopItemCard extends StatelessWidget {
  final String id;
  final String name;
  final int price;
  final String assetPath;
  final bool isOwned;
  final bool canAfford;
  final int currentCoin;
  final VoidCallback onPurchase;

  const ShopItemCard({
    super.key,
    required this.id,
    required this.name,
    required this.price,
    required this.assetPath,
    required this.isOwned,
    required this.canAfford,
    required this.currentCoin,
    required this.onPurchase,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: AppSpacing.borderRadiusXL,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Item image
          Expanded(
            child: ClipRRect(
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(24.0),
              ),
              child: Container(
                color: Theme.of(context).colorScheme.surface,
                child: Image.asset(
                  assetPath,
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      color: Theme.of(context).colorScheme.surface,
                      child: Icon(
                        Icons.image,
                        size: 48,
                        color: Theme.of(context).colorScheme.primary.withOpacity(0.5),
                      ),
                    );
                  },
                ),
              ),
            ),
          ),

          // Item info
          Padding(
            padding: const EdgeInsets.all(AppSpacing.sm),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: AppSpacing.xs),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      price == 0 ? 'Ücretsiz' : '$price Coin',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Theme.of(context).colorScheme.primary,
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    if (isOwned)
                      Icon(
                        Icons.check_circle,
                        size: 16,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                  ],
                ),
                const SizedBox(height: AppSpacing.xs),
                SizedBox(
                  width: double.infinity,
                  child: isOwned
                      ? ElevatedButton.icon(
                          onPressed: onPurchase,
                          icon: const Icon(Icons.check, size: 16),
                          label: const Text('Uygula'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Theme.of(context).colorScheme.primary,
                            foregroundColor: Theme.of(context).colorScheme.onPrimary,
                            padding: const EdgeInsets.symmetric(
                              vertical: AppSpacing.xs,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: AppSpacing.borderRadiusMD,
                            ),
                          ),
                        )
                      : canAfford
                          ? ElevatedButton(
                              onPressed: onPurchase,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Theme.of(context).colorScheme.primary,
                                foregroundColor: Theme.of(context).colorScheme.onPrimary,
                                padding: const EdgeInsets.symmetric(
                                  vertical: AppSpacing.xs,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: AppSpacing.borderRadiusMD,
                                ),
                              ),
                              child: const Text('Satın Al'),
                            )
                          : OutlinedButton(
                              onPressed: null,
                              style: OutlinedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(
                                  vertical: AppSpacing.xs,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: AppSpacing.borderRadiusMD,
                                ),
                              ),
                              child: Text(
                                'Yetersiz',
                                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                      color: Theme.of(context).colorScheme.error,
                                    ),
                              ),
                            ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

