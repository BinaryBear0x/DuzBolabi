import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../data/models/product.dart';
import '../../data/models/product_status.dart';
import '../../features/gamification/gamification_service.dart';
import '../../core/services/notification_service.dart';
import '../../core/utils/product_icon_helper.dart';
import '../../core/widgets/lottie_animations.dart';
import '../../core/constants/spacing.dart';
import '../../app/theme/component_styles/buttons.dart';
import 'providers/product_provider.dart';
import 'providers/user_stats_provider.dart';

class ProductDetailScreen extends ConsumerWidget {
  final String productId;

  const ProductDetailScreen({super.key, required this.productId});

  Future<void> _markAsConsumed(
    BuildContext context,
    WidgetRef ref,
    Product product,
  ) async {
    if (!context.mounted) return;
    
    final oldStatus = product.status;
    product.status = ProductStatus.consumed;
    product.consumedAt = DateTime.now();

    final repository = ref.read(productRepositoryProvider);
    await repository.updateProduct(product);

    final statsRepository = ref.read(userStatsRepositoryProvider);
    final gamificationService = GamificationService(statsRepository);
    
    // Background'da çalıştır
    gamificationService.handleProductStatusChange(
      product,
      oldStatus,
      ProductStatus.consumed,
    ).catchError((e) {
      // Hata olsa bile devam et
    });

    // Notification iptal et
    NotificationService.cancelProductNotifications(product.id).catchError((e) {
      // Hata olsa bile devam et
    });

    if (context.mounted) {
      // Provider'ları async olarak invalidate et - UI thread'i bloklamasın
      Future.microtask(() {
        if (ref.exists(productProvider(productId))) {
          ref.invalidate(productProvider(productId));
        }
        if (ref.exists(productsProvider)) {
          ref.invalidate(productsProvider);
        }
        if (ref.exists(allProductsProvider)) {
          ref.invalidate(allProductsProvider);
        }
        if (ref.exists(userStatsProvider)) {
          ref.invalidate(userStatsProvider);
        }
      });
      
      // Lottie success animasyonu göster
      if (context.mounted) {
        showDialog(
          context: context,
          barrierColor: Colors.transparent,
          barrierDismissible: true,
          builder: (dialogContext) => LottieSuccess(
            message: 'Ürün tüketildi! 🎉',
            onAnimationComplete: () {
              if (dialogContext.mounted && Navigator.canPop(dialogContext)) {
                Navigator.of(dialogContext).pop();
              }
            },
          ),
        );
      }
      context.pop();
    }
  }

  Future<void> _markAsTrashed(
    BuildContext context,
    WidgetRef ref,
    Product product,
  ) async {
    if (!context.mounted) return;
    
    final oldStatus = product.status;
    product.status = ProductStatus.trashed;
    product.trashedAt = DateTime.now();

    final repository = ref.read(productRepositoryProvider);
    await repository.updateProduct(product);

    final statsRepository = ref.read(userStatsRepositoryProvider);
    final gamificationService = GamificationService(statsRepository);
    
    // Background'da çalıştır
    gamificationService.handleProductStatusChange(
      product,
      oldStatus,
      ProductStatus.trashed,
    ).catchError((e) {
      // Hata olsa bile devam et
    });

    // Notification iptal et
    NotificationService.cancelProductNotifications(product.id).catchError((e) {
      // Hata olsa bile devam et
    });

    if (context.mounted) {
      // Provider'ları async olarak invalidate et - UI thread'i bloklamasın
      Future.microtask(() {
        if (ref.exists(productProvider(productId))) {
          ref.invalidate(productProvider(productId));
        }
        if (ref.exists(productsProvider)) {
          ref.invalidate(productsProvider);
        }
        if (ref.exists(allProductsProvider)) {
          ref.invalidate(allProductsProvider);
        }
        if (ref.exists(userStatsProvider)) {
          ref.invalidate(userStatsProvider);
        }
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Ürün çöpe gitti olarak işaretlendi'),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
      context.pop();
    }
  }

  Future<void> _deleteProduct(
    BuildContext context,
    WidgetRef ref,
    Product product,
  ) async {
    if (!context.mounted) return;
    
    final confirmed = await showDialog<bool>(
      context: context,
      barrierDismissible: true,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
        title: const Text('Ürünü Sil'),
        content: const Text('Bu ürünü silmek istediğinizden emin misiniz?'),
        actions: [
          TextButton(
            onPressed: () {
              if (dialogContext.mounted) {
                Navigator.pop(dialogContext, false);
              }
            },
            child: const Text('İptal'),
          ),
          TextButton(
            onPressed: () {
              if (dialogContext.mounted) {
                Navigator.pop(dialogContext, true);
              }
            },
            style: TextButton.styleFrom(
              foregroundColor: Theme.of(context).colorScheme.error,
            ),
            child: const Text('Sil'),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      try {
        NotificationService.cancelProductNotifications(product.id).catchError((e) {
          // Hata olsa bile devam et
        });
        
        final repository = ref.read(productRepositoryProvider);
        await repository.deleteProduct(product.id);

        if (context.mounted) {
          // Provider'ları async olarak invalidate et - UI thread'i bloklamasın
          Future.microtask(() {
            if (ref.exists(productsProvider)) {
              ref.invalidate(productsProvider);
            }
            if (ref.exists(allProductsProvider)) {
              ref.invalidate(allProductsProvider);
            }
          });
          context.pop();
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Silme hatası: $e'),
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final productAsync = ref.watch(productProvider(productId));

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      appBar: AppBar(
        title: Text(
          'Ürün Detayı',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
        backgroundColor: Theme.of(context).colorScheme.surface,
        elevation: 0,
        iconTheme: IconThemeData(color: Theme.of(context).colorScheme.onSurface),
      ),
      body: SafeArea(
        top: false, // AppBar zaten SafeArea içinde
        child: productAsync.when(
        data: (product) {
          if (product == null) {
            return const Center(child: Text('Ürün bulunamadı'));
          }

          return RepaintBoundary(
            child: _ProductDetailContent(
              product: product,
              onConsumed: () => _markAsConsumed(context, ref, product),
              onTrashed: () => _markAsTrashed(context, ref, product),
              onDeleted: () => _deleteProduct(context, ref, product),
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(child: Text('Hata: $error')),
        ),
      ),
    );
  }
}

class _ProductDetailContent extends StatelessWidget {
  final Product product;
  final VoidCallback onConsumed;
  final VoidCallback onTrashed;
  final VoidCallback onDeleted;

  const _ProductDetailContent({
    required this.product,
    required this.onConsumed,
    required this.onTrashed,
    required this.onDeleted,
  });

  Color _getStatusColor(BuildContext context, String statusColor) {
    final colorScheme = Theme.of(context).colorScheme;
    switch (statusColor) {
      case 'danger':
        return colorScheme.error; // #FF6B6B
      case 'warning':
        return colorScheme.secondary; // #FFCA6C
      case 'success':
        return colorScheme.primary; // #4BCB8B
      default:
        return colorScheme.outline;
    }
  }

  /// Kalan gün sayısını hesaplar
  int _kalanGunHesapla(DateTime stt) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final expiryDate = DateTime(stt.year, stt.month, stt.day);
    
    final difference = expiryDate.difference(today).inDays;
    return difference < 0 ? 0 : difference;
  }

  /// Kalan gün sayısına göre progress bar rengini döndürür
  Color _progressRengi(int kalanGun) {
    if (kalanGun >= 45) {
      return const Color(0xFF4BCB8B); // Yeşil
    } else if (kalanGun >= 15) {
      return const Color(0xFFFFCA6C); // Sarı - 15-44 gün
    } else if (kalanGun >= 7) {
      return const Color(0xFFFFA500); // Turuncu - 7-14 gün
    } else {
      return const Color(0xFFFF6B6B); // Kırmızı - 0-6 gün
    }
  }

  /// Kalan gün sayısına göre progress bar metnini döndürür
  String _progressMetni(int kalanGun) {
    if (kalanGun >= 45) {
      return 'Güvenli';
    } else if (kalanGun >= 15) {
      return 'Dikkat';
    } else if (kalanGun >= 7) {
      return 'Yaklaşıyor';
    } else {
      return 'Acil';
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = _getStatusColor(context, product.statusColor);
    final dateFormat = DateFormat('dd MMMM yyyy', 'tr_TR');
    final iconPath = ProductIconHelper.getIconPath(product.category);
    final fallbackIcon = ProductIconHelper.getFallbackIcon(product.category);
    final kalanGun = _kalanGunHesapla(product.expiryDate);
    final progressRengi = _progressRengi(kalanGun);
    final progressMetni = _progressMetni(kalanGun);

    return SingleChildScrollView(
      padding: AppSpacing.screenPadding, // prompt.json: top 24px, horizontal 20px
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Icon container - prompt.json: 72px
          Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(vertical: AppSpacing.gapComponent.height ?? AppSpacing.lg),
            decoration: BoxDecoration(
              color: color.withOpacity(0.15),
              borderRadius: AppSpacing.borderRadiusXL, // prompt.json: card 24px
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 72, // prompt.json: 72px
                  height: 72,
                  decoration: BoxDecoration(
                    color: Theme.of(context).cardColor,
                    shape: BoxShape.circle,
                    boxShadow: AppSpacing.softShadow, // Yumuşatılmış shadow
                  ),
                  child: ClipOval(
                    child: Image.asset(
                      iconPath,
                      fit: BoxFit.cover,
                      cacheWidth: 72,
                      cacheHeight: 72,
                      errorBuilder: (context, error, stackTrace) {
                        return Icon(
                          fallbackIcon,
                          size: 36,
                          color: color,
                        );
                      },
                    ),
                  ),  
                ),
                AppSpacing.gapMD,
                Container(
                  padding: EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.sm),
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: AppSpacing.borderRadiusLG, // prompt.json: button 18px
                  ),
                  child: Text(
                    '${product.remainingDays} Gün Kaldı',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onPrimary,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
          AppSpacing.gapComponent,
          // Ürün bilgisi
          Padding(
            padding: EdgeInsets.zero,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        product.name,
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        product.category.displayName,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                        ),
                      ),
            AppSpacing.gapComponent,
            Container(
              padding: AppSpacing.cardPadding, // prompt.json: 16-20px
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: AppSpacing.borderRadiusXL, // prompt.json: card 24px
                boxShadow: AppSpacing.softShadow, // Yumuşatılmış shadow
              ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'STT\'ye Yaklaşma',
                                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                                  ),
                                ),
                                // Debug bilgisi - geçici olarak göster
                                Text(
                                  '${product.remainingDays}g kaldı',
                                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                    fontSize: 12,
                                    color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Stack(
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(12),
                                  child: LinearProgressIndicator(
                                    value: 1.0, // Statik doluluk - sadece renk önemli
                                    minHeight: 32,
                                    backgroundColor: Theme.of(context).colorScheme.surfaceVariant,
                                    valueColor: AlwaysStoppedAnimation<Color>(progressRengi),
                                  ),
                                ),
                                // Progress bar içinde metin
                                Positioned.fill(
                                  child: Center(
                                    child: Text(
                                      progressMetni,
                                      style: TextStyle(
                                        color: Theme.of(context).colorScheme.onSurface,
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                        shadows: [
                                          Shadow(
                                            color: Colors.white.withOpacity(0.8),
                                            blurRadius: 2,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            _DetailRow(
                              icon: Icons.calendar_today,
                              label: 'Son Tüketim Tarihi',
                              value: dateFormat.format(product.expiryDate),
                            ),
                            const SizedBox(height: 12),
                            _DetailRow(
                              icon: Icons.info_outline,
                              label: 'Durum',
                              value: product.status.displayName,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),
                      if (product.status == ProductStatus.added) ...[
            // Butonlar - prompt.json: Tükettim (mint-outline + mint-icon + mint-text), Çöpe Gitti (error-outline + error-icon + error-text)
            // Bozuk ürünlerden (remainingDays <= 0 veya danger durumu) tüketme seçeneğini kaldır
            if (product.remainingDays > 0 && product.statusColor != 'danger') ...[
              OutlinedButton.icon(
                onPressed: onConsumed,
                style: AppButtonStyles.consumedButtonStyle(Theme.of(context).colorScheme).copyWith(
                  minimumSize: WidgetStateProperty.all(const Size(double.infinity, 56)),
                  padding: WidgetStateProperty.all(EdgeInsets.symmetric(horizontal: AppSpacing.xl, vertical: AppSpacing.lg)),
                ),
                icon: Icon(Icons.check_circle, size: 24, color: Theme.of(context).colorScheme.primary), // prompt.json: icon 24px
                label: Text(
                  'Tükettim',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
              ),
              AppSpacing.gapMD,
            ],
            OutlinedButton.icon(
              onPressed: onTrashed,
              style: AppButtonStyles.trashedButtonStyle(Theme.of(context).colorScheme).copyWith(
                minimumSize: WidgetStateProperty.all(const Size(double.infinity, 56)),
                padding: WidgetStateProperty.all(EdgeInsets.symmetric(horizontal: AppSpacing.xl, vertical: AppSpacing.lg)),
              ),
              icon: Icon(Icons.delete_outline, size: 24, color: Theme.of(context).colorScheme.error), // prompt.json: icon 24px
              label: Text(
                'Çöpe Gitti',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.error,
                ),
              ),
            ),
                      ],
                      const SizedBox(height: 12),
                      OutlinedButton.icon(
                        onPressed: onDeleted,
                        icon: const Icon(Icons.delete_forever, size: 24),
                        label: const Text(
                          'Ürünü Sil',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        style: AppButtonStyles.trashedButtonStyle(Theme.of(context).colorScheme).copyWith(
                          minimumSize: WidgetStateProperty.all(const Size(double.infinity, 56)),
                          padding: WidgetStateProperty.all(const EdgeInsets.symmetric(vertical: 16)),
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

class _DetailRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _DetailRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 20, color: Theme.of(context).colorScheme.primary),
        const SizedBox(width: 12),
        Text(
          '$label: ',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.onSurface,
            ),
            textAlign: TextAlign.end,
          ),
        ),
      ],
    );
  }
}
