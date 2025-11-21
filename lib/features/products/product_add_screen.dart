import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:uuid/uuid.dart';
import 'package:intl/intl.dart';
import '../../data/models/product.dart';
import '../../data/models/product_category.dart';
import '../../features/gamification/gamification_service.dart';
import '../../core/services/notification_service.dart';
import '../../core/utils/product_icon_helper.dart';
import '../../core/widgets/animated_button.dart';
import '../../core/widgets/lottie_animations.dart';
import '../../core/constants/spacing.dart';
import '../../app/theme/component_styles/buttons.dart';
import 'providers/product_provider.dart';
import 'providers/user_stats_provider.dart';
import 'providers/product_add_state_provider.dart';

class ProductAddScreen extends ConsumerStatefulWidget {
  const ProductAddScreen({super.key});

  @override
  ConsumerState<ProductAddScreen> createState() => _ProductAddScreenState();
}

class _ProductAddScreenState extends ConsumerState<ProductAddScreen> with AutomaticKeepAliveClientMixin {
  final _nameController = TextEditingController();
  final _focusNode = FocusNode();

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    // TextField değişikliklerini dinle - buton durumunu güncellemek için
    _nameController.addListener(_onNameChanged);
  }

  void _onNameChanged() {
    // TextField değiştiğinde rebuild et - buton durumunu güncelle
    if (mounted) {
      setState(() {});
    }
  }

  @override
  void dispose() {
    _nameController.removeListener(_onNameChanged);
    _focusNode.dispose();
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final selectedDate = ref.read(productAddDateProvider);
    
    try {
      final DateTime? picked = await showDatePicker(
        context: context,
        initialDate: selectedDate ?? DateTime.now().add(const Duration(days: 7)),
        firstDate: DateTime.now(),
        lastDate: DateTime.now().add(const Duration(days: 365)),
        locale: const Locale('tr', 'TR'),
        builder: (context, child) {
          return Theme(
            data: Theme.of(context),
            child: child!,
          );
        },
      );
      
      if (picked != null) {
        // setState yerine provider kullan
        ref.read(productAddDateProvider.notifier).state = picked;
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Tarih seçilirken hata oluştu: $e'),
          ),
        );
      }
    }
  }

  Future<void> _saveProduct(BuildContext context) async {
    final isSaving = ref.read(productAddSavingProvider);
    if (isSaving) return;
    
    final productName = _nameController.text.trim();
    if (productName.isEmpty) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Lütfen ürün adını girin'),
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }
    
    final selectedDate = ref.read(productAddDateProvider);
    if (selectedDate == null) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Lütfen son tüketim tarihi seçin'),
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }

    final selectedCategory = ref.read(productAddCategoryProvider);
    
    // setState yerine provider kullan
    ref.read(productAddSavingProvider.notifier).state = true;

    try {
      final product = Product(
        id: const Uuid().v4(),
        name: productName,
        expiryDate: selectedDate,
        category: selectedCategory,
        createdAt: DateTime.now(),
      );
      
      // Database işlemini yap
      final repository = ref.read(productRepositoryProvider);
      await repository.addProduct(product);

      // UI feedback'i hemen göster - Lottie success animasyonu
      if (mounted) {
        showDialog(
          context: context,
          barrierColor: null,
          barrierDismissible: true,
          builder: (dialogContext) => LottieSuccess(
            message: 'Ürün başarıyla eklendi! 🎉',
            onAnimationComplete: () {
              if (dialogContext.mounted && Navigator.canPop(dialogContext)) {
                Navigator.of(dialogContext).pop();
              }
              if (context.mounted) {
                context.pop();
              }
            },
          ),
        );
      }

      // Background işlemleri - UI'ı bloklamadan
      final statsRepository = ref.read(userStatsRepositoryProvider);
      final gamificationService = GamificationService(statsRepository);
      
      // Gamification ve notification'ları background'da çalıştır
      Future.microtask(() async {
        try {
          await gamificationService.handleProductAdded(product);
        } catch (e) {
          debugPrint('Gamification error: $e');
        }
      });
      
      Future.microtask(() async {
        try {
          await NotificationService.scheduleProductNotifications(product);
        } catch (e) {
          debugPrint('Notification error: $e');
        }
      });

      // Provider'ları invalidate et - ama UI'ı bloklamadan
      // PostFrameCallback kullanarak bir sonraki frame'de yap
      if (mounted) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          // Provider'ları invalidate et - raporlar için allProductsProvider da güncellensin
          ref.invalidate(productsProvider);
          ref.invalidate(allProductsProvider);
          ref.invalidate(userStatsProvider);
        });
      }
      
      // Kısa bir gecikme sonra anasayfaya git - kullanıcı feedback'i görsün
      await Future.delayed(const Duration(milliseconds: 300));
      
      if (mounted) {
        // Önce dialog'u kapat
        if (Navigator.canPop(context)) {
          Navigator.of(context).pop();
        }
        // Sonra anasayfaya git
        context.go('/');
      }
    } catch (e) {
      debugPrint('Error saving product: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Icon(Icons.error, color: Theme.of(context).colorScheme.onSurface, size: 20),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Ürün eklenirken hata oluştu: ${e.toString()}',
                    style: const TextStyle(fontSize: 16),
                  ),
                ),
              ],
            ),
            behavior: SnackBarBehavior.floating,
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(16)),
            ),
            duration: const Duration(seconds: 4),
            margin: const EdgeInsets.all(16),
          ),
        );
      }
    } finally {
      // setState yerine provider kullan
      ref.read(productAddSavingProvider.notifier).state = false;
    }
  }

  String _formatDate(DateTime date) {
    try {
      return DateFormat('dd MMMM yyyy', 'tr_TR').format(date);
    } catch (e) {
      return '${date.day}/${date.month}/${date.year}';
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context); // AutomaticKeepAliveClientMixin için gerekli
    
    // Provider'dan state'leri oku - sadece gerekli olanları watch et
    final selectedDate = ref.watch(productAddDateProvider);
    final selectedCategory = ref.watch(productAddCategoryProvider);
    final isSaving = ref.watch(productAddSavingProvider);
    
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      // Klavye açılıp kapanırken rebuild'leri önle
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        title: Text(
          'Ürün Ekle',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Theme.of(context).cardColor,
        elevation: 0,
        iconTheme: IconThemeData(color: Theme.of(context).textTheme.bodyLarge?.color),
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom + AppSpacing.lg,
                left: AppSpacing.lg, // prompt.json: horizontal 20px
                right: AppSpacing.lg,
                top: AppSpacing.top, // prompt.json: top 24px
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
              // Üstte add_product illustrasyonu - prompt.json: 72px
              RepaintBoundary(
                child: Container(
                  width: double.infinity,
                  height: 72, // prompt.json: 72px
                  margin: EdgeInsets.only(bottom: AppSpacing.gapComponent.height ?? AppSpacing.lg),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                    borderRadius: AppSpacing.borderRadiusXXL,
                  ),
                  child: Image.asset(
                    'assets/illustrations/add_product.png',
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) {
                      return Center(
                        child: Icon(
                          Icons.add_shopping_cart,
                          size: 60,
                          color: Theme.of(context).colorScheme.primary.withOpacity(0.5),
                        ),
                      );
                    },
                  ),
                ),
              ),
                // Ürün Adı - Tamamen izole widget
                _ProductNameField(
                  key: const ValueKey('product_name_field'),
                  controller: _nameController,
                  focusNode: _focusNode,
                ),
              
              AppSpacing.gapMD,
              
              // Tarih Seçimi - İzole widget ile optimize
              RepaintBoundary(
                child: _DateSelector(
                  selectedDate: selectedDate,
                  onTap: () => _selectDate(context),
                  formatDate: _formatDate,
                ),
              ),
              
              AppSpacing.gapComponent,
              
              // Kategori Seç
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Kategori',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              
              AppSpacing.gapSM,
              
              // Kategori Grid - prompt.json: KAYDIRMALI OLMAYACAK, tüm kategoriler görünecek
              // 2 satırlı veya 3'lü grid (6 kategori için 3x2)
              RepaintBoundary(
                child: Container(
                  padding: AppSpacing.cardPadding,
                  decoration: BoxDecoration(
                    color: Theme.of(context).cardColor,
                    borderRadius: AppSpacing.borderRadiusXL, // prompt.json: card 24px
                    boxShadow: AppSpacing.softShadow,
                  ),
                  child: GridView.count(
                    physics: const NeverScrollableScrollPhysics(), // Scroll yok
                    shrinkWrap: true,
                    crossAxisCount: 3,
                    crossAxisSpacing: AppSpacing.sm,
                    mainAxisSpacing: AppSpacing.sm,
                    childAspectRatio: 1.0,
                    children: ProductCategory.values.map((category) {
                      return _CategoryGridItem(
                        key: ValueKey('category_$category'),
                        category: category,
                        isSelected: category == selectedCategory,
                        onTap: () {
                          ref.read(productAddCategoryProvider.notifier).state = category;
                        },
                      );
                    }).toList(),
                  ),
                ),
              ),
              
              AppSpacing.gapMD,
              
              // Kaydet Butonu - Her zaman aktif
              RepaintBoundary(
                child: _SaveButton(
                  isSaving: isSaving,
                  onPressed: () => _saveProduct(context),
                ),
              ),
                    ],
                  ),
            );
          },
        ),
      ),
    );
  }
}

// Ürün Adı TextField - Tamamen izole widget
class _ProductNameField extends StatelessWidget {
  final TextEditingController controller;
  final FocusNode focusNode;

  const _ProductNameField({
    super.key,
    required this.controller,
    required this.focusNode,
  });

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: AppSpacing.borderRadiusLG,
          boxShadow: AppSpacing.softShadow,
        ),
        child: TextField(
          controller: controller,
          focusNode: focusNode,
          style: Theme.of(context).textTheme.bodyLarge,
          decoration: InputDecoration(
            labelText: 'Ürün Adı',
            labelStyle: Theme.of(context).textTheme.bodyMedium,
            prefixIcon: Icon(
              Icons.shopping_bag,
              color: Theme.of(context).colorScheme.primary,
            ),
            border: InputBorder.none,
            contentPadding: EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.md),
          ),
          textInputAction: TextInputAction.next,
          keyboardType: TextInputType.text,
          maxLength: 100,
          buildCounter: (_, {required currentLength, required isFocused, maxLength}) => null,
        ),
      ),
    );
  }
}

// Tarih Seçici - İzole widget
class _DateSelector extends StatelessWidget {
  final DateTime? selectedDate;
  final VoidCallback onTap;
  final String Function(DateTime) formatDate;

  const _DateSelector({
    required this.selectedDate,
    required this.onTap,
    required this.formatDate,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        key: ValueKey('date_selector_${selectedDate?.millisecondsSinceEpoch ?? 0}'),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: AppSpacing.borderRadiusLG,
          boxShadow: AppSpacing.softShadow,
        ),
        padding: EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.md),
        child: Row(
          children: [
            Icon(
              Icons.calendar_today,
              color: Theme.of(context).colorScheme.primary,
              size: 20,
            ),
            AppSpacing.gapMD,
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Son Tüketim Tarihi',
                    style: Theme.of(context).textTheme.labelSmall,
                  ),
                  AppSpacing.gapXS,
                  selectedDate == null
                      ? Text(
                          'Tarih seçin',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w500,
                          ),
                        )
                      : Text(
                          formatDate(selectedDate!),
                          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right,
              color: Theme.of(context).textTheme.bodyMedium?.color,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }
}

// Kategori Grid Item - Her item için ayrı widget (sadece seçili olan rebuild olur)
class _CategoryGridItem extends StatelessWidget {
  final ProductCategory category;
  final bool isSelected;
  final VoidCallback onTap;

  const _CategoryGridItem({
    super.key,
    required this.category,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final iconPath = ProductIconHelper.getIconPath(category);
    final fallbackIcon = ProductIconHelper.getFallbackIcon(category);

    return RepaintBoundary(
      child: Material(
        child: InkWell(
          onTap: onTap,
          borderRadius: AppSpacing.borderRadiusMD,
          child: Container(
            padding: AppSpacing.paddingSM,
            decoration: BoxDecoration(
              color: isSelected
                  ? Theme.of(context).colorScheme.primary.withOpacity(0.15)
                  : Theme.of(context).cardColor.withOpacity(0.5),
              borderRadius: AppSpacing.borderRadiusMD,
              border: isSelected
                  ? Border.all(
                      color: Theme.of(context).colorScheme.primary,
                      width: 2,
                    )
                  : null,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  width: 24, // prompt.json: category icon 24px
                  height: 24,
                  child: Image.asset(
                    iconPath,
                    width: 24,
                    height: 24,
                    fit: BoxFit.contain,
                    cacheWidth: 24,
                    cacheHeight: 24,
                    errorBuilder: (context, error, stackTrace) {
                      return Icon(
                        fallbackIcon,
                        size: 24, // prompt.json: 24px
                        color: isSelected
                            ? Theme.of(context).colorScheme.primary
                            : Theme.of(context).textTheme.bodyMedium?.color,
                      );
                    },
                  ),
                ),
                AppSpacing.gapXS,
                Flexible(
                  child: Text(
                    category.displayName,
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      color: isSelected
                          ? Theme.of(context).colorScheme.primary
                          : Theme.of(context).textTheme.bodyMedium?.color,
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// Kaydet Butonu - Her zaman aktif
class _SaveButton extends StatelessWidget {
  final bool isSaving;
  final VoidCallback onPressed;

  const _SaveButton({
    required this.isSaving,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    
    return SizedBox(
      width: double.infinity,
      child: AnimatedElevatedButton(
        onPressed: isSaving ? () {} : onPressed, // Null yerine boş fonksiyon - disabled olmasın
        style: ElevatedButton.styleFrom(
          backgroundColor: colorScheme.primary, // Her zaman yeşil (primary)
          foregroundColor: colorScheme.onPrimary, // Yazı beyaz (onPrimary)
          disabledBackgroundColor: colorScheme.primary, // Disabled durumda da yeşil
          disabledForegroundColor: colorScheme.onPrimary, // Disabled durumda da beyaz
          minimumSize: const Size(double.infinity, 56),
          padding: EdgeInsets.symmetric(horizontal: AppSpacing.xl, vertical: AppSpacing.lg),
          elevation: 3,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSpacing.radiusLG), // 18px
          ),
        ).copyWith(
          // Disabled durumda bile yeşil kalması için
          backgroundColor: WidgetStateProperty.all(colorScheme.primary),
          foregroundColor: WidgetStateProperty.all(colorScheme.onPrimary),
        ),
        child: isSaving
            ? SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    colorScheme.onPrimary, // Beyaz loading indicator
                  ),
                ),
              )
            : Text(
                'Kaydet',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: colorScheme.onPrimary, // Beyaz yazı
                ),
              ),
      ),
    );
  }
}
