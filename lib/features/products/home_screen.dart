import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../data/models/product.dart';
import '../../data/models/product_category.dart';
import '../../core/widgets/main_scaffold.dart';
import '../../core/utils/product_icon_helper.dart';
import '../../core/widgets/lottie_animations.dart';
import 'providers/product_provider.dart';
import 'providers/ui_state_provider.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> with AutomaticKeepAliveClientMixin {
  final TextEditingController _searchController = TextEditingController();
  Timer? _debounceTimer;
  final ScrollController _categoryScrollController = ScrollController();

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    _categoryScrollController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 300), () {
      ref.read(searchQueryProvider.notifier).state = _searchController.text;
    });
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    
    final searchQuery = ref.watch(searchQueryProvider);
    final selectedCategory = ref.watch(selectedCategoryProvider);
    final showExpiredOnly = ref.watch(showExpiredOnlyProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    final productsAsync = searchQuery.isNotEmpty
        ? ref.watch(searchProductsProvider(searchQuery))
        : showExpiredOnly
            ? ref.watch(expiredProductsProvider)
            : selectedCategory != null
                ? ref.watch(productsByCategoryProvider(selectedCategory))
                : ref.watch(productsProvider);

    return MainScaffold(
      currentRoute: '/',
      child: Container(
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1C1E22) : const Color(0xFFF6F7FA),
        ),
        child: Stack(
          children: [
            // Ana içerik
            SafeArea(
              top: true,
              bottom: false,
              child: Column(
                children: [
                  // Üst arama alanı - büyük oval
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 24, 20, 16),
                    child: _SearchBar(
                      controller: _searchController,
                      searchQuery: searchQuery,
                      onClear: () {
                        _debounceTimer?.cancel();
                        _searchController.clear();
                        ref.read(searchQueryProvider.notifier).state = '';
                      },
                      isDark: isDark,
                    ),
                  ),
                  
                  // Kategori filtre chip'leri - yatay scrollable
                  _CategoryChips(
                    selectedCategory: selectedCategory,
                    showExpiredOnly: showExpiredOnly,
                    onCategorySelected: (category) {
                      // Kategori seçildiğinde expired filter'ı kapat
                      ref.read(showExpiredOnlyProvider.notifier).setExpiredOnly(false);
                      ref.read(selectedCategoryProvider.notifier).state = category;
                    },
                    onExpiredToggle: (value) {
                      // Expired toggle edildiğinde kategori seçimini temizle
                      ref.read(selectedCategoryProvider.notifier).state = null;
                      ref.read(showExpiredOnlyProvider.notifier).setExpiredOnly(value);
                    },
                    scrollController: _categoryScrollController,
                    isDark: isDark,
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Ürün listesi
                  Expanded(
                    child: productsAsync.when(
                      data: (products) {
                        if (products.isEmpty) {
                          return LottieEmpty(
                            title: 'Henüz ürün yok',
                            subtitle: 'İlk ürününü ekleyerek başla!',
                            icon: Icons.shopping_bag_outlined,
                            onAction: () => context.push('/products/add'),
                            actionLabel: 'Ürün Ekle',
                          );
                        }
                        return RefreshIndicator(
                          onRefresh: () async {
                            ref.invalidate(productsProvider);
                            if (searchQuery.isNotEmpty) {
                              ref.invalidate(searchProductsProvider(searchQuery));
                            }
                            if (selectedCategory != null) {
                              ref.invalidate(productsByCategoryProvider(selectedCategory));
                            }
                            if (showExpiredOnly) {
                              ref.invalidate(expiredProductsProvider);
                            }
                            await ref.read(productsProvider.future);
                          },
                          color: const Color(0xFF38D07F),
                          child: ListView.builder(
                            key: const ValueKey('products_list'),
                            padding: const EdgeInsets.fromLTRB(20, 0, 20, 100),
                            itemCount: products.length,
                            itemBuilder: (context, index) {
                              final product = products[index];
                              return _ProductCard(
                                key: ValueKey('product_${product.id}'),
                                product: product,
                                isDark: isDark,
                              );
                            },
                          ),
                        );
                      },
                      loading: () => const Center(
                        child: LottieLoading(message: 'Ürünler yükleniyor...'),
                      ),
                      error: (error, stack) => LottieError(
                        message: 'Bir hata oluştu: $error',
                        onRetry: () {
                          ref.invalidate(productsProvider);
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),
            
            // FAB - Ürün Ekle butonu
            Positioned(
              right: 20,
              bottom: 20,
              child: _AddProductFAB(isDark: isDark),
            ),
          ],
        ),
      ),
    );
  }
}

// Üst arama barı - büyük oval
class _SearchBar extends StatelessWidget {
  final TextEditingController controller;
  final String searchQuery;
  final VoidCallback onClear;
  final bool isDark;

  const _SearchBar({
    required this.controller,
    required this.searchQuery,
    required this.onClear,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final cardColor = isDark ? const Color(0xFF2A2C30) : Colors.white; // Koyu modda daha açık gri
    
    return Container(
      height: 56,
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 12,
            offset: const Offset(0, 2),
            spreadRadius: 0,
          ),
        ],
      ),
      child: TextField(
        controller: controller,
        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
          fontSize: 16,
        ),
        decoration: InputDecoration(
          hintText: 'Ürün Ara…',
          hintStyle: TextStyle(
            fontSize: 16,
            color: isDark ? Colors.white.withOpacity(0.5) : Colors.black.withOpacity(0.4),
          ),
          prefixIcon: Icon(
            Icons.search,
            size: 24,
            color: isDark ? Colors.white.withOpacity(0.7) : Colors.black.withOpacity(0.5),
          ),
          suffixIcon: searchQuery.isNotEmpty
              ? IconButton(
                  icon: Icon(
                    Icons.clear,
                    size: 20,
                    color: isDark ? Colors.white.withOpacity(0.7) : Colors.black.withOpacity(0.5),
                  ),
                  onPressed: onClear,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                )
              : null,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          isDense: false,
        ),
      ),
    );
  }
}

// Kategori filtre chip'leri
class _CategoryChips extends StatelessWidget {
  final ProductCategory? selectedCategory;
  final bool showExpiredOnly;
  final Function(ProductCategory?) onCategorySelected;
  final Function(bool) onExpiredToggle;
  final ScrollController scrollController;
  final bool isDark;

  const _CategoryChips({
    required this.selectedCategory,
    required this.showExpiredOnly,
    required this.onCategorySelected,
    required this.onExpiredToggle,
    required this.scrollController,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final selectedColor = const Color(0xFF38D07F);
    
    return SizedBox(
      height: 44,
      child: ListView(
        controller: scrollController,
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        children: [
          // "Tümü" chip'i
          _CategoryChip(
            label: 'Tümü',
            isSelected: selectedCategory == null && !showExpiredOnly,
            onTap: () => onCategorySelected(null),
            selectedColor: selectedColor,
            isDark: isDark,
          ),
          const SizedBox(width: 8),
          // "Tarihi Geçenler" chip'i
          _CategoryChip(
            label: 'Tarihi Geçenler',
            isSelected: showExpiredOnly,
            onTap: () => onExpiredToggle(!showExpiredOnly),
            selectedColor: selectedColor,
            isDark: isDark,
            icon: Icons.warning_amber_rounded,
          ),
          const SizedBox(width: 8),
          // Kategori chip'leri
          ...ProductCategory.values.map((category) {
            return Padding(
              padding: const EdgeInsets.only(right: 8),
              child: _CategoryChip(
                label: category.displayName,
                isSelected: selectedCategory == category && !showExpiredOnly,
                onTap: () => onCategorySelected(category),
                selectedColor: selectedColor,
                isDark: isDark,
              ),
            );
          }),
        ],
      ),
    );
  }
}

// Tekil kategori chip
class _CategoryChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;
  final Color selectedColor;
  final bool isDark;
  final IconData? icon;

  const _CategoryChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
    required this.selectedColor,
    required this.isDark,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected 
              ? selectedColor 
              : (isDark ? Colors.white.withOpacity(0.1) : Colors.grey.withOpacity(0.15)),
          borderRadius: BorderRadius.circular(22),
        ),
        child: Center(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (icon != null) ...[
                Icon(
                  icon,
                  size: 16,
                  color: isSelected 
                      ? Colors.white 
                      : (isDark ? Colors.white : Colors.black87),
                ),
                const SizedBox(width: 6),
              ],
              Text(
                label,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: isSelected 
                      ? Colors.white 
                      : (isDark ? Colors.white : Colors.black87),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Ürün kartı
class _ProductCard extends StatelessWidget {
  final Product product;
  final bool isDark;

  const _ProductCard({
    super.key,
    required this.product,
    required this.isDark,
  });

  String _getStatusLabel(String statusColor) {
    switch (statusColor) {
      case 'danger':
        return 'Bozuk';
      case 'warning':
        return 'Yakında Tüket';
      case 'success':
        return 'Taze';
      default:
        return 'Taze';
    }
  }

  Color _getStatusBadgeColor(String statusColor) {
    switch (statusColor) {
      case 'danger':
        return const Color(0xFFFF6B6B); // Soft kırmızı
      case 'warning':
        return const Color(0xFFF7C94A); // Sarı pastel
      case 'success':
        return const Color(0xFF38D07F); // Yeşil
      default:
        return const Color(0xFF38D07F);
    }
  }

  Color _getStatusTextColor(String statusColor) {
    switch (statusColor) {
      case 'danger':
        return Colors.white;
      case 'warning':
        return Colors.black87;
      case 'success':
        return Colors.white;
      default:
        return Colors.white;
    }
  }

  String _getIconPath(ProductCategory category) {
    return ProductIconHelper.getIconPath(category);
  }

  IconData _getFallbackIcon(ProductCategory category) {
    return ProductIconHelper.getFallbackIcon(category);
  }

  @override
  Widget build(BuildContext context) {
    final cardColor = isDark ? const Color(0xFF2A2C30) : Colors.white; // Koyu modda daha açık gri
    final statusColor = product.statusColor;
    final badgeColor = _getStatusBadgeColor(statusColor);
    final badgeTextColor = _getStatusTextColor(statusColor);
    final statusLabel = _getStatusLabel(statusColor);
    final iconPath = _getIconPath(product.category);
    final fallbackIcon = _getFallbackIcon(product.category);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 12,
            offset: const Offset(0, 2),
            spreadRadius: 0,
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => context.push('/products/${product.id}'),
          borderRadius: BorderRadius.circular(22),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Sol tarafta kategori icon'u - yuvarlak illustrasyon
                Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    color: badgeColor.withOpacity(0.15),
                    shape: BoxShape.circle,
                  ),
                  child: ClipOval(
                    child: Image.asset(
                      iconPath,
                      fit: BoxFit.contain,
                      cacheWidth: 64,
                      cacheHeight: 64,
                      errorBuilder: (context, error, stackTrace) {
                        return Icon(
                          fallbackIcon,
                          color: badgeColor,
                          size: 32,
                        );
                      },
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                // Orta kısım - ürün adı ve kategori
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        product.name,
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: isDark ? Colors.white : Colors.black87,
                          height: 1.2,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        product.category.displayName,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w400,
                          color: isDark ? Colors.white.withOpacity(0.6) : Colors.black.withOpacity(0.6),
                          height: 1.2,
                        ),
                      ),
                    ],
                  ),
                ),
                // Sağ tarafta durum rozeti
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: badgeColor,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    statusLabel,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: badgeTextColor,
                    ),
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

// FAB - Ürün Ekle butonu
class _AddProductFAB extends StatelessWidget {
  final bool isDark;

  const _AddProductFAB({required this.isDark});

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton.extended(
      onPressed: () => context.push('/products/add'),
      backgroundColor: const Color(0xFF38D07F),
      foregroundColor: Colors.white,
      elevation: 6,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(28),
      ),
      icon: const Icon(Icons.add, size: 24),
      label: const Text(
        'Ürün Ekle',
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
