import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../features/products/providers/user_stats_provider.dart';
import '../../features/products/providers/product_provider.dart';
import '../../data/models/product.dart';
import '../../data/models/product_category.dart';
import '../../data/models/product_status.dart';
import '../../core/widgets/main_scaffold.dart';
import '../../core/utils/product_icon_helper.dart';
import '../../core/constants/spacing.dart';
import '../../core/widgets/skeleton_loader.dart';
import '../../core/utils/responsive.dart';
import '../../core/utils/accessibility.dart';
import 'fridge_state_provider.dart';

class FridgeScreen extends ConsumerStatefulWidget {
  const FridgeScreen({super.key});

  @override
  ConsumerState<FridgeScreen> createState() => _FridgeScreenState();
}

class _FridgeScreenState extends ConsumerState<FridgeScreen>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    
    return MainScaffold(
      currentRoute: '/fridge',
      child: const _FridgeView(),
    );
  }
}

// Buzdolabı Görünümü - 4 Raf + Drag-Drop + Animasyonlar
class _FridgeView extends ConsumerStatefulWidget {
  const _FridgeView();

  @override
  ConsumerState<_FridgeView> createState() => _FridgeViewState();
}

class _FridgeViewState extends ConsumerState<_FridgeView>
    with SingleTickerProviderStateMixin {
  late AnimationController _scaleController;
  String? _draggedProductId;
  String? _hoveredShelfId;

  @override
  void initState() {
    super.initState();
    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
  }

  @override
  void dispose() {
    _scaleController.dispose();
    super.dispose();
  }

  void _onDragStarted(String productId) {
    setState(() => _draggedProductId = productId);
  }

  void _onDragEnd() {
    setState(() {
      _draggedProductId = null;
      _hoveredShelfId = null;
    });
  }

  void _onDragEnter(String shelfId) {
    setState(() => _hoveredShelfId = shelfId);
  }

  void _onDragExit() {
    setState(() => _hoveredShelfId = null);
  }

  void _onProductDropped(String productId, String shelfId) {
    // TODO: Ürünü rafa taşıma mantığı (repository'ye eklenebilir)
    _onDragEnd();
  }

  @override
  Widget build(BuildContext context) {
    final productsAsync = ref.watch(productsProvider);
    final selectedSkin = ref.watch(selectedSkinProvider);
    final purchasedStickers = ref.watch(purchasedStickersProvider);

    return productsAsync.when(
      data: (products) {
        // Ürünleri 4 rafa böl
        final shelf1Products = products.take((products.length * 0.25).ceil()).toList();
        final shelf2Products = products.skip(shelf1Products.length).take((products.length * 0.25).ceil()).toList();
        final shelf3Products = products.skip(shelf1Products.length + shelf2Products.length).take((products.length * 0.25).ceil()).toList();
        final shelf4Products = products.skip(shelf1Products.length + shelf2Products.length + shelf3Products.length).toList();

        return Stack(
          children: [
            // Buzdolabı Arka Plan - Full-page 3D/flat-buton stilli
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
                      color: _getSkinColor(selectedSkin),
                      child: Center(
                        child: Icon(
                          Icons.kitchen,
                          size: 200,
                          color: Theme.of(context).textTheme.bodySmall?.color?.withOpacity(0.5) ?? Theme.of(context).colorScheme.onSurface,
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
            
            // Skin Overlay - Arka plana uygulanır
            if (selectedSkin != 'default')
              Positioned.fill(
                child: RepaintBoundary(
                  child: Image.asset(
                    'assets/skins/skin_$selectedSkin.png',
                    fit: BoxFit.cover,
                    cacheWidth: 600,
                    cacheHeight: 900,
                    gaplessPlayback: true,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(color: _getSkinColor(selectedSkin).withOpacity(0.3));
                    },
                  ),
                ),
              ),
            
            // Sticker'lar - Dolabın içine yerleştirilebilir
            ...purchasedStickers.map((stickerId) {
              return Positioned(
                left: 50.0 + (purchasedStickers.indexOf(stickerId) * 80.0),
                top: 100.0 + (purchasedStickers.indexOf(stickerId) * 50.0),
                child: Image.asset(
                  'assets/stickers/sticker_$stickerId.png',
                  width: 60,
                  height: 60,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.secondary.withOpacity(0.3),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(Icons.star, color: Theme.of(context).colorScheme.secondary),
                    );
                  },
                ),
              );
            }),
            
            // İçerik - 4 Raf - prompt.json: top padding 24px, horizontal 20px
            SafeArea(
              child: Padding(
                padding: AppSpacing.screenPadding, // top 24px, horizontal 20px
                child: Column(
                  children: [
                    AppSpacing.gapComponent, // prompt.json: component spacing 20px
                    
                    // Üst Raf (1) - prompt.json: raf yüksekliği 120px
                    SizedBox(
                      height: 120, // prompt.json: 120px
                      child: _ShelfWidget(
                        shelfId: 'shelf1',
                        label: 'Üst Raf',
                        products: shelf1Products,
                        draggedProductId: _draggedProductId,
                        hoveredShelfId: _hoveredShelfId,
                        onDragStarted: _onDragStarted,
                        onDragEnd: _onDragEnd,
                        onDragEnter: _onDragEnter,
                        onDragExit: _onDragExit,
                        onProductDropped: _onProductDropped,
                      ),
                    ),
                    
                    AppSpacing.gapComponent, // prompt.json: component spacing 20px
                    
                    // Orta Üst Raf (2)
                    SizedBox(
                      height: 120, // prompt.json: 120px
                      child: _ShelfWidget(
                        shelfId: 'shelf2',
                        label: 'Orta Üst',
                        products: shelf2Products,
                        draggedProductId: _draggedProductId,
                        hoveredShelfId: _hoveredShelfId,
                        onDragStarted: _onDragStarted,
                        onDragEnd: _onDragEnd,
                        onDragEnter: _onDragEnter,
                        onDragExit: _onDragExit,
                        onProductDropped: _onProductDropped,
                      ),
                    ),
                    
                    AppSpacing.gapComponent,
                    
                    // Orta Alt Raf (3)
                    SizedBox(
                      height: 120, // prompt.json: 120px
                      child: _ShelfWidget(
                        shelfId: 'shelf3',
                        label: 'Orta Alt',
                        products: shelf3Products,
                        draggedProductId: _draggedProductId,
                        hoveredShelfId: _hoveredShelfId,
                        onDragStarted: _onDragStarted,
                        onDragEnd: _onDragEnd,
                        onDragEnter: _onDragEnter,
                        onDragExit: _onDragExit,
                        onProductDropped: _onProductDropped,
                      ),
                    ),
                    
                    AppSpacing.gapComponent,
                    
                    // Alt Raf (4)
                    SizedBox(
                      height: 120, // prompt.json: 120px
                      child: _ShelfWidget(
                        shelfId: 'shelf4',
                        label: 'Alt Raf',
                        products: shelf4Products,
                        draggedProductId: _draggedProductId,
                        hoveredShelfId: _hoveredShelfId,
                        onDragStarted: _onDragStarted,
                        onDragEnd: _onDragEnd,
                        onDragEnter: _onDragEnter,
                        onDragExit: _onDragExit,
                        onProductDropped: _onProductDropped,
                      ),
                    ),
                    
                    AppSpacing.gapXL,
                  ],
                ),
              ),
            ),
          ],
        );
      },
      loading: () => const SkeletonLoaderGrid(
        crossAxisCount: 4,
        itemCount: 8,
      ),
      error: (error, stack) => Center(
        child: Text('Hata: $error'),
      ),
    );
  }

  Color _getSkinColor(String skin) {
    // Tüm skin'ler kırmızı-beyaz tema için surface rengi
    return Theme.of(context).colorScheme.surface;
  }
}

// Raf Widget - Drag-Drop + Hover Highlight
class _ShelfWidget extends StatefulWidget {
  final String shelfId;
  final String label;
  final List<Product> products;
  final String? draggedProductId;
  final String? hoveredShelfId;
  final Function(String) onDragStarted;
  final VoidCallback onDragEnd;
  final Function(String) onDragEnter;
  final VoidCallback onDragExit;
  final Function(String, String) onProductDropped;

  const _ShelfWidget({
    required this.shelfId,
    required this.label,
    required this.products,
    required this.draggedProductId,
    required this.hoveredShelfId,
    required this.onDragStarted,
    required this.onDragEnd,
    required this.onDragEnter,
    required this.onDragExit,
    required this.onProductDropped,
  });

  @override
  State<_ShelfWidget> createState() => _ShelfWidgetState();
}

class _ShelfWidgetState extends State<_ShelfWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _highlightController;
  late Animation<double> _highlightAnimation;
  bool _isHovered = false;

  @override
  void initState() {
    super.initState();
    _highlightController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _highlightAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _highlightController,
        curve: Curves.easeInOut,
      ),
    );
  }

  @override
  void didUpdateWidget(_ShelfWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.hoveredShelfId == widget.shelfId) {
      _isHovered = true;
      _highlightController.forward();
    } else {
      _isHovered = false;
      _highlightController.reverse();
    }
  }

  @override
  void dispose() {
    _highlightController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isHovered = widget.hoveredShelfId == widget.shelfId;
    
    return AnimatedBuilder(
      animation: _highlightAnimation,
      builder: (context, child) {
        // prompt.json: Raf kartları tek tip layout, border primary %20 opacity (#4BCB8B33)
        return Container(
          padding: EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.sm,
          ),
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: AppSpacing.borderRadiusXL, // prompt.json: card 24px
            border: Border.all(
              color: Theme.of(context).colorScheme.primary.withOpacity(0.2), // prompt.json: primary %20 opacity
              width: 1.5,
            ),
            boxShadow: AppSpacing.softShadow,
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Label - prompt.json: text alignment düzelt
              SizedBox(
                width: 80,
                child: Text(
                  widget.label,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                  textAlign: TextAlign.left,
                ),
              ),
              AppSpacing.gapSM,
              // Ürünler - prompt.json: iconlar 56px container, ürün iconları 24px
              Expanded(
                child: widget.products.isEmpty
                    ? Center(
                        child: Text(
                          'Boş',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
                          ),
                        ),
                      )
                    : DragTarget<String>(
                        onWillAccept: (data) => true,
                        onAccept: (productId) {
                          widget.onProductDropped(productId, widget.shelfId);
                        },
                        onLeave: (_) => widget.onDragExit(),
                        builder: (context, candidateData, rejectedData) {
                          return RepaintBoundary(
                            child: ListView.builder(
                              key: ValueKey('${widget.shelfId}_list'),
                              scrollDirection: Axis.horizontal,
                              itemCount: widget.products.length,
                              itemExtent: 56, // prompt.json: iconlar 56px container
                              itemBuilder: (context, index) {
                                final product = widget.products[index];
                                return Padding(
                                  padding: EdgeInsets.only(right: AppSpacing.xs),
                                  child: _DraggableProductItem(
                                    product: product,
                                    isDragging: widget.draggedProductId == product.id,
                                    onDragStarted: () => widget.onDragStarted(product.id),
                                    onDragEnd: widget.onDragEnd,
                                  ),
                                );
                              },
                            ),
                          );
                        },
                      ),
              ),
            ],
          ),
        );
      },
    );
  }
}

// Draggable Ürün Item - Bounce Animation + Drag
class _DraggableProductItem extends StatefulWidget {
  final Product product;
  final bool isDragging;
  final VoidCallback onDragStarted;
  final VoidCallback onDragEnd;

  const _DraggableProductItem({
    required this.product,
    required this.isDragging,
    required this.onDragStarted,
    required this.onDragEnd,
  });

  @override
  State<_DraggableProductItem> createState() => _DraggableProductItemState();
}

class _DraggableProductItemState extends State<_DraggableProductItem>
    with SingleTickerProviderStateMixin {
  late AnimationController _bounceController;
  late Animation<double> _bounceAnimation;
  bool _hasAnimated = false;

  @override
  void initState() {
    super.initState();
    _bounceController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );
    _bounceAnimation = TweenSequence<double>([
      TweenSequenceItem(tween: Tween<double>(begin: 1.0, end: 1.2), weight: 1),
      TweenSequenceItem(tween: Tween<double>(begin: 1.2, end: 1.0), weight: 1),
    ]).animate(
      CurvedAnimation(
        parent: _bounceController,
        curve: Curves.easeOutBack,
      ),
    );
    
    // Ürün eklenince bounce animation
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && !_hasAnimated) {
        _bounceController.forward().catchError((e) {
          // Animation hatası olsa bile devam et
        });
        _hasAnimated = true;
      }
    });
  }

  @override
  void dispose() {
    _bounceController.stop(); // Önce durdur
    _bounceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final iconPath = _getIconPath(widget.product.category);
    final fallbackIcon = _getFallbackIcon(widget.product.category);
    final color = _getStatusColor(widget.product.statusColor);

    return AnimatedBuilder(
      animation: _bounceAnimation,
      builder: (context, child) {
        // Animation value'yu clamp et - TweenSequence hatasını önlemek için
        double animationValue;
        try {
          final rawValue = _bounceAnimation.value;
          if (!rawValue.isFinite || rawValue.isNaN) {
            animationValue = 1.0; // Geçersiz değer için varsayılan
          } else {
            // TweenSequence için value'yu clamp et
            animationValue = rawValue.clamp(0.0, 2.0); // 1.0-1.2-1.0 için 2.0'a kadar olabilir
          }
        } catch (e) {
          animationValue = 1.0; // Hata durumunda varsayılan
        }
        
        // Scale değerini hesapla
        final scaleValue = widget.isDragging ? 0.8 : animationValue;
        
        return Transform.scale(
          scale: scaleValue.clamp(0.5, 1.5), // Scale değerini de clamp et
          child: Draggable<String>(
            data: widget.product.id,
            feedback: Material(
              child: Container(
                width: 56, // prompt.json: 56px
                height: 56,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.9),
                  borderRadius: AppSpacing.borderRadiusLG,
                  boxShadow: AppSpacing.softShadowMD,
                ),
                child: Center(
                  child: Image.asset(
                    iconPath,
                    fit: BoxFit.contain,
                    width: 24, // prompt.json: 24px
                    height: 24,
                    cacheWidth: 24,
                    cacheHeight: 24,
                    errorBuilder: (context, error, stackTrace) {
                      return Icon(
                        fallbackIcon,
                        size: 24,
                        color: color,
                      );
                    },
                  ),
                ),
              ),
            ),
            onDragStarted: widget.onDragStarted,
            onDragEnd: (_) => widget.onDragEnd(),
            childWhenDragging: Container(
              decoration: BoxDecoration(
                color: Colors.grey.withOpacity(0.3),
                borderRadius: AppSpacing.borderRadiusLG,
              ),
            ),
            child: RepaintBoundary(
              child: Container(
                width: 56, // prompt.json: iconlar 56px container
                height: 56,
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                  borderRadius: AppSpacing.borderRadiusLG,
                  border: Border.all(
                    color: color.withOpacity(0.3),
                    width: 1.5,
                  ),
                  boxShadow: AppSpacing.softShadow,
                ),
                child: Center( // prompt.json: ortalanmış
                  child: ClipRRect(
                    borderRadius: AppSpacing.borderRadiusLG,
                    child: Image.asset(
                      iconPath,
                      fit: BoxFit.contain,
                      width: 24, // prompt.json: ürün iconları 24px
                      height: 24,
                      cacheWidth: 24,
                      cacheHeight: 24,
                      errorBuilder: (context, error, stackTrace) {
                        return Icon(
                          fallbackIcon,
                          size: 24, // prompt.json: 24px
                          color: color,
                        );
                      },
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  String _getIconPath(ProductCategory category) {
    return ProductIconHelper.getIconPath(category);
  }

  IconData _getFallbackIcon(ProductCategory category) {
    return ProductIconHelper.getFallbackIcon(category);
  }

  Color _getStatusColor(String statusColor) {
    final colorScheme = Theme.of(context).colorScheme;
    switch (statusColor) {
      case 'green':
        return colorScheme.primary;
      case 'yellow':
        return colorScheme.secondary;
      case 'red':
        return colorScheme.error;
      default:
        return colorScheme.primary;
    }
  }
}

// Oyunlaştırma Görünümü
class _GamificationView extends ConsumerWidget {
  const _GamificationView();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statsAsync = ref.watch(userStatsProvider);
    final selectedSkin = ref.watch(selectedSkinProvider);
    final purchasedStickers = ref.watch(purchasedStickersProvider);

    return statsAsync.when(
      data: (stats) {
        return SingleChildScrollView(
          padding: AppSpacing.screenPadding,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Puan ve Level Kartı
              Container(
                padding: AppSpacing.cardPadding,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Theme.of(context).colorScheme.primary,
                      Theme.of(context).colorScheme.primary.withOpacity(0.7),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: AppSpacing.borderRadiusXXL,
                  boxShadow: AppSpacing.softShadowMD,
                ),
                child: Column(
                  children: [
                    Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.surface.withOpacity(0.3),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.emoji_events,
                        size: 50,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                    AppSpacing.gapLG,
                    Text(
                      'Seviye ${stats.currentLevel}',
                      style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        color: Theme.of(context).colorScheme.onSurface,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    AppSpacing.gapSM,
                    Text(
                      '${stats.totalPoints} Puan',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                    AppSpacing.gapLG,
                    // Progress Bar
                    Container(
                      height: 8,
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.surface.withOpacity(0.3),
                        borderRadius: AppSpacing.borderRadiusSM,
                      ),
                      child: FractionallySizedBox(
                        alignment: Alignment.centerLeft,
                        widthFactor: (stats.totalPoints % 100) / 100,
                        child: Container(
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.onSurface,
                            borderRadius: AppSpacing.borderRadiusSM,
                          ),
                        ),
                      ),
                    ),
                    AppSpacing.gapSM,
                    Text(
                      '${stats.totalPoints % 100}/100 bir sonraki seviyeye',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                      ),
                    ),
                  ],
                ),
              ),
              
              AppSpacing.gapXL,
              
              // İstatistikler
              Row(
                children: [
                  Expanded(
                    child: _StatCard(
                      icon: Icons.add_circle,
                      label: 'Eklenen',
                      value: stats.totalAdded.toString(),
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                  AppSpacing.gapMD,
                  Expanded(
                    child: _StatCard(
                      icon: Icons.check_circle,
                      label: 'Tüketilen',
                      value: stats.totalConsumed.toString(),
                      color: const Color(0xFF4A90E2),
                    ),
                  ),
                  AppSpacing.gapMD,
                  Expanded(
                    child: _StatCard(
                      icon: Icons.delete,
                      label: 'Çöpe Giden',
                      value: stats.totalTrashed.toString(),
                      color: Theme.of(context).colorScheme.error,
                    ),
                  ),
                ],
              ),
              
              AppSpacing.gapXL,
              
              // Buzdolabı Temaları
              Container(
                padding: AppSpacing.cardPadding,
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                  borderRadius: AppSpacing.borderRadiusXL,
                  boxShadow: AppSpacing.softShadow,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Buzdolabı Temaları',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    AppSpacing.gapLG,
                    _buildSkinList(context, ref, stats.currentLevel, selectedSkin),
                  ],
                ),
              ),
              
              AppSpacing.gapXL,
              
              // Stickerlar
              Container(
                padding: AppSpacing.cardPadding,
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                  borderRadius: AppSpacing.borderRadiusXL,
                  boxShadow: AppSpacing.softShadow,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Stickerlar',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    AppSpacing.gapLG,
                    _buildStickerList(context, ref, stats.totalPoints, purchasedStickers),
                  ],
                ),
              ),
              
              AppSpacing.gapXL,
            ],
          ),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => Center(child: Text('Hata: $error')),
    );
  }

  Widget _buildSkinList(
    BuildContext context,
    WidgetRef ref,
    int currentLevel,
    String selectedSkin,
  ) {
    final surfaceColor = Theme.of(context).colorScheme.surface;
    final skins = [
      {'name': 'Varsayılan Beyaz', 'id': 'default', 'level': 1, 'color': surfaceColor},
      {'name': 'Mavi Taze', 'id': 'blue', 'level': 3, 'color': surfaceColor},
      {'name': 'Retro Sarı', 'id': 'retro', 'level': 5, 'color': surfaceColor},
      {'name': 'Metalik Gri', 'id': 'gray', 'level': 8, 'color': surfaceColor},
    ];

    return Column(
      children: skins.map((skin) {
        final skinId = skin['id'] as String;
        final level = skin['level'] as int;
        final color = skin['color'] as Color;
        final unlocked = currentLevel >= level;
        final isSelected = selectedSkin == skinId;

        return Container(
          margin: EdgeInsets.only(bottom: AppSpacing.md),
          decoration: BoxDecoration(
            color: isSelected
                ? Theme.of(context).colorScheme.primary.withOpacity(0.1)
                : Theme.of(context).cardColor.withOpacity(0.5),
            borderRadius: AppSpacing.borderRadiusLG,
            border: Border.all(
              color: isSelected
                  ? Theme.of(context).colorScheme.primary
                  : Colors.transparent,
              width: 2,
            ),
          ),
          child: ListTile(
            leading: Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: color.withOpacity(0.3),
                borderRadius: AppSpacing.borderRadiusMD,
                border: Border.all(
                  color: color,
                  width: 2,
                ),
              ),
              child: unlocked
                  ? Icon(
                      isSelected ? Icons.check_circle : Icons.circle,
                      color: isSelected ? Theme.of(context).colorScheme.primary : color,
                      size: 24,
                    )
                  : Icon(
                      Icons.lock,
                      color: Theme.of(context).textTheme.bodySmall?.color ?? Colors.grey,
                      size: 24,
                    ),
            ),
            title: Text(
              skin['name'] as String,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                color: unlocked ? null : Colors.grey,
              ),
            ),
            subtitle: Text('Seviye $level'),
            trailing: unlocked && isSelected
                ? Icon(Icons.check, color: Theme.of(context).colorScheme.primary)
                : unlocked
                    ? TextButton(
                        onPressed: () {
                          ref.read(selectedSkinProvider.notifier).setSkin(skinId);
                        },
                        child: const Text('Seç'),
                      )
                    : null,
            enabled: unlocked,
          ),
        );
      }).toList(),
    );
  }

  Widget _buildStickerList(
    BuildContext context,
    WidgetRef ref,
    int totalPoints,
    List<String> purchasedStickers,
  ) {
    final stickers = [
      {'name': 'Yeşil Yaprak', 'cost': 50, 'id': 'leaf'},
      {'name': 'Altın Yıldız', 'cost': 80, 'id': 'star'},
      {'name': 'Kırmızı Kalp', 'cost': 100, 'id': 'heart'},
    ];

    return Column(
      children: stickers.map((sticker) {
        final stickerId = sticker['id'] as String;
        final cost = sticker['cost'] as int;
        final canAfford = totalPoints >= cost;
        final isPurchased = purchasedStickers.contains(stickerId);

        return Container(
          margin: EdgeInsets.only(bottom: AppSpacing.md),
          decoration: BoxDecoration(
            color: isPurchased
                ? Theme.of(context).colorScheme.primary.withOpacity(0.1)
                : Theme.of(context).cardColor.withOpacity(0.5),
            borderRadius: AppSpacing.borderRadiusLG,
            border: Border.all(
              color: isPurchased
                  ? Theme.of(context).colorScheme.primary
                  : Colors.transparent,
              width: 1,
            ),
          ),
          child: ListTile(
            leading: Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: const Color(0xFFFFC857).withOpacity(0.2),
                borderRadius: AppSpacing.borderRadiusMD,
              ),
              child: Image.asset(
                'assets/stickers/sticker_$stickerId.png',
                errorBuilder: (context, error, stackTrace) {
                  return const Icon(Icons.star, color: Color(0xFFFFC857), size: 24);
                },
              ),
            ),
            title: Text(sticker['name'] as String),
            subtitle: Text('$cost Puan'),
            trailing: isPurchased
                ? Icon(Icons.check_circle, color: Theme.of(context).colorScheme.primary)
                : canAfford
                    ? ElevatedButton(
                        onPressed: () => _showBuyStickerDialog(
                          context,
                          ref,
                          stickerId,
                          sticker['name'] as String,
                          cost,
                          totalPoints,
                        ),
                        child: const Text('Satın Al'),
                      )
                    : Text(
                        'Yetersiz Puan',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.grey,
                        ),
                      ),
          ),
        );
      }).toList(),
    );
  }

  void _showBuyStickerDialog(
    BuildContext context,
    WidgetRef ref,
    String stickerId,
    String stickerName,
    int cost,
    int totalPoints,
  ) {
    if (!context.mounted) return;
    
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: AppSpacing.borderRadiusXXL,
        ),
        title: const Text('Sticker Satın Al'),
        content: Text('Bu sticker $cost puan. Satın almak ister misin?'),
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
              ref.read(purchasedStickersProvider.notifier).addSticker(stickerId);
              
              if (dialogContext.mounted) {
                Navigator.pop(dialogContext);
              }
              
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('$stickerName satın alındı! 🎉'),
                    backgroundColor: Theme.of(context).colorScheme.primary,
                  ),
                );
              }
            },
            child: const Text('Satın Al'),
          ),
        ],
      ),
    );
  }
}

// Stat Card Widget
class _StatCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _StatCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: AppSpacing.cardPadding,
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: AppSpacing.borderRadiusLG,
        border: Border.all(
          color: color.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 32),
          AppSpacing.gapSM,
          Text(
            value,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
          AppSpacing.gapXS,
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: color.withOpacity(0.8),
            ),
          ),
        ],
      ),
    );
  }
}
