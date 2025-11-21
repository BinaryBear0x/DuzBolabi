import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/widgets/main_scaffold.dart';
import '../../core/constants/spacing.dart';
import '../../core/utils/dummy_data_generator.dart';
import '../../features/products/providers/product_provider.dart';
import '../../features/products/providers/user_stats_provider.dart';
import 'providers/settings_state_provider.dart';
import 'providers/theme_provider.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Provider'dan state oku - setState yok!
    final notificationsEnabled = ref.watch(notificationsEnabledProvider);
    final themeMode = ref.watch(themeModeProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardColor = isDark ? const Color(0xFF2A2C30) : Colors.white; // Home screen ile tutarlı
    
    return MainScaffold(
      currentRoute: '/settings',
      child: Container(
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1C1E22) : const Color(0xFFF6F7FA), // Home screen ile aynı arkaplan
        ),
        child: ListView(
          padding: AppSpacing.screenPadding, // prompt.json: top 24px, horizontal 20px
          children: [
          AppSpacing.gapComponent, // prompt.json: component spacing 20px
          // Tema Seçimi
          Container(
            padding: AppSpacing.cardPadding, // prompt.json: 16-20px
            decoration: BoxDecoration(
              color: cardColor,
              borderRadius: AppSpacing.borderRadiusXL, // prompt.json: card 24px
              boxShadow: AppSpacing.softShadow,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Tema',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.onSurface, // Dark mode'da beyaz
                  ),
                ),
                AppSpacing.gapMD,
                Text(
                  'Uygulama temasını seçin',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7), // Dark mode'da açık gri
                  ),
                ),
                AppSpacing.gapLG,
                SegmentedButton<ThemeMode>(
                  segments: const [
                    ButtonSegment<ThemeMode>(
                      value: ThemeMode.light,
                      label: Text('Açık'),
                      icon: Icon(Icons.light_mode),
                    ),
                    ButtonSegment<ThemeMode>(
                      value: ThemeMode.dark,
                      label: Text('Koyu'),
                      icon: Icon(Icons.dark_mode),
                    ),
                    ButtonSegment<ThemeMode>(
                      value: ThemeMode.system,
                      label: Text('Sistem'),
                      icon: Icon(Icons.brightness_auto),
                    ),
                  ],
                  selected: {themeMode},
                  onSelectionChanged: (Set<ThemeMode> newSelection) {
                    ref.read(themeModeProvider.notifier).setThemeMode(newSelection.first);
                  },
                ),
              ],
            ),
          ),
          AppSpacing.gapComponent, // prompt.json: component spacing 20px
          // Bildirimler
          Container(
            padding: AppSpacing.cardPadding, // prompt.json: 16-20px
            decoration: BoxDecoration(
              color: cardColor,
              borderRadius: AppSpacing.borderRadiusXL, // prompt.json: card 24px
              boxShadow: AppSpacing.softShadow,
            ),
            child: SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(
                'Bildirimler',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: Theme.of(context).colorScheme.onSurface, // Dark mode'da beyaz
                ),
              ),
              subtitle: Text(
                'Ürün hatırlatıcı bildirimlerini aç/kapat',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7), // Dark mode'da açık gri
                ),
              ),
              value: notificationsEnabled,
              activeColor: Theme.of(context).colorScheme.primary,
              onChanged: (value) {
                ref.read(notificationsEnabledProvider.notifier).state = value;
              },
            ),
          ),
          AppSpacing.gapMD,
          _buildSettingsCard(
            context,
            cardColor: cardColor,
            icon: Icons.category,
            iconColor: Theme.of(context).colorScheme.primary,
            title: 'Kategorileri Düzenle',
            subtitle: 'Ürün kategorilerini özelleştir',
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Yakında eklenecek')),
              );
            },
          ),
          AppSpacing.gapComponent,
          // Çöp Kutusu - diğer kartlarla aynı yapı (ListTile)
          _buildSettingsCard(
            context,
            cardColor: cardColor,
            icon: Icons.delete_outline,
            iconColor: Theme.of(context).colorScheme.error,
            title: 'Çöp Kutusu',
            subtitle: 'Silinen ürünleri görüntüle',
            onTap: () => context.push('/trash'),
          ),
          AppSpacing.gapMD,
          _buildSettingsCard(
            context,
            cardColor: cardColor,
            icon: Icons.data_object,
            iconColor: Theme.of(context).colorScheme.secondary,
            title: 'Test Verileri Yükle',
            subtitle: '3 haftalık sahte veri oluştur',
            onTap: () => _loadDummyData(context, ref),
          ),
          AppSpacing.gapMD,
          _buildSettingsCard(
            context,
            cardColor: cardColor,
            icon: Icons.info_outline,
            iconColor: Theme.of(context).textTheme.bodyMedium?.color ?? Colors.grey,
            title: 'Hakkında',
            subtitle: 'Uygulama bilgileri',
            onTap: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  shape: RoundedRectangleBorder(
                    borderRadius: AppSpacing.borderRadiusXXL,
                  ),
                  backgroundColor: cardColor,
                  title: Text(
                    'Gıda Koruyucu',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.onSurface, // Dark mode'da beyaz
                    ),
                  ),
                  content: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Versiyon 1.0.0',
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: Theme.of(context).colorScheme.onSurface, // Dark mode'da beyaz
                        ),
                      ),
                      AppSpacing.gapMD,
                      Text(
                        'Gıda israfını önlemek için geliştirilmiştir. Ürünlerin son tüketim tarihlerini takip ederek israfı azaltın.',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(context).colorScheme.onSurface.withOpacity(0.8), // Dark mode'da açık gri
                        ),
                      ),
                    ],
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text(
                        'Tamam',
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
        ),
      ),
    );
  }

  Future<void> _loadDummyData(BuildContext context, WidgetRef ref) async {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardColor = isDark ? const Color(0xFF2A2C30) : Colors.white; // Home screen ile tutarlı
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: AppSpacing.borderRadiusXXL,
          ),
          backgroundColor: cardColor,
          title: Text(
            'Test Verileri Yükle',
            style: TextStyle(
              color: Theme.of(dialogContext).colorScheme.onSurface, // Dark mode'da beyaz
            ),
          ),
          content: Text(
            'Mevcut tüm veriler silinecek ve 3 haftalık sahte veri oluşturulacak. Devam etmek istiyor musunuz?',
            style: TextStyle(
              color: Theme.of(dialogContext).colorScheme.onSurface.withOpacity(0.8), // Dark mode'da açık gri
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: Text(
                'İptal',
                style: TextStyle(
                  color: Theme.of(dialogContext).colorScheme.onSurface.withOpacity(0.7), // Dark mode'da açık gri
                ),
              ),
            ),
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, true),
              style: TextButton.styleFrom(
                foregroundColor: Theme.of(dialogContext).colorScheme.primary,
              ),
              child: const Text('Evet, Yükle'),
            ),
          ],
        ),
    );

    if (confirmed == true && context.mounted) {
      try {
        // Loading göster
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => const Center(
            child: CircularProgressIndicator(),
          ),
        );

        final productRepository = ref.read(productRepositoryProvider);
        final statsRepository = ref.read(userStatsRepositoryProvider);

        await DummyDataGenerator.generateDummyData(
          productRepository,
          statsRepository,
        );

        // Provider'ları invalidate et
        ref.invalidate(productsProvider);
        ref.invalidate(allProductsProvider);
        ref.invalidate(userStatsProvider);

        if (context.mounted) {
          Navigator.pop(context); // Loading dialog'u kapat
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Test verileri başarıyla yüklendi!'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } catch (e) {
        if (context.mounted) {
          Navigator.pop(context); // Loading dialog'u kapat
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Hata: $e'),
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
          );
        }
      }
    }
  }

  Widget _buildSettingsCard(
    BuildContext context, {
    Color? cardColor,
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final finalCardColor = cardColor ?? (isDark ? const Color(0xFF2A2C30) : Colors.white);
    
    return Container(
      decoration: BoxDecoration(
        color: finalCardColor,
        borderRadius: AppSpacing.borderRadiusXL, // prompt.json: card 24px
        boxShadow: AppSpacing.softShadow,
      ),
      child: ListTile(
        contentPadding: EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.md),
        leading: Container(
          width: 48, // prompt.json: icon container 48px
          height: 48,
          decoration: BoxDecoration(
            color: iconColor.withOpacity(0.15),
            borderRadius: AppSpacing.borderRadiusMD,
          ),
          child: Icon(icon, color: iconColor, size: 24), // prompt.json: icon 24px
        ),
        title: Text(
          title,
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w600,
            color: Theme.of(context).colorScheme.onSurface, // Dark mode'da beyaz
          ),
        ),
        subtitle: Text(
          subtitle,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7), // Dark mode'da açık gri
          ),
        ),
        trailing: Icon(
          Icons.chevron_right,
          color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6), // Dark mode'da açık gri
        ),
        onTap: onTap,
      ),
    );
  }
}
