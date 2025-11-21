import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:go_router/go_router.dart';
import '../../data/models/product.dart';
import '../../data/models/product_status.dart';
import '../../data/models/product_category.dart';
import '../../core/widgets/main_scaffold.dart';
import '../../core/widgets/lottie_animations.dart';
import '../../core/widgets/skeleton_loader.dart';
import '../../features/products/providers/product_provider.dart';

class WeeklyReportScreen extends ConsumerStatefulWidget {
  const WeeklyReportScreen({super.key});

  @override
  ConsumerState<WeeklyReportScreen> createState() => _WeeklyReportScreenState();
}

class _WeeklyReportScreenState extends ConsumerState<WeeklyReportScreen>
    with AutomaticKeepAliveClientMixin, TickerProviderStateMixin {
  late AnimationController _cardAnimationController;
  late AnimationController _chartAnimationController;
  late Animation<double> _cardStaggerAnimation;
  late Animation<double> _chartFadeAnimation;
  
  String _selectedFilter = 'Son 30 Gün';
  DateTime? _startDate;
  DateTime? _endDate;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    
    _cardAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 480),
    );
    
    _chartAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 450),
    );
    
    _cardStaggerAnimation = CurvedAnimation(
      parent: _cardAnimationController,
      curve: Curves.easeOut,
    );
    
    _chartFadeAnimation = CurvedAnimation(
      parent: _chartAnimationController,
      curve: Curves.easeOutCubic,
    );
    
    if (mounted) {
      _cardAnimationController.forward().catchError((e) {
        // Animation hatası olsa bile devam et
      });
      Future.delayed(const Duration(milliseconds: 200), () {
        if (mounted && !_chartAnimationController.isAnimating) {
          _chartAnimationController.forward().catchError((e) {
            // Animation hatası olsa bile devam et
          });
        }
      });
    }
  }

  @override
  void dispose() {
    _cardAnimationController.stop();
    _cardAnimationController.dispose();
    _chartAnimationController.stop();
    _chartAnimationController.dispose();
    super.dispose();
  }

  Map<String, dynamic> _calculateMetrics(List<Product> products) {
    final now = DateTime.now();
    final thirtyDaysAgo = now.subtract(const Duration(days: 30));
    final sevenDaysFromNow = now.add(const Duration(days: 7));

    int consumedLast30Days = 0;
    int upcomingIn7Days = 0;
    int totalConsumed = 0;
    int totalTrashed = 0;
    int totalAdded = 0;

    for (final product in products) {
      if (product.consumedAt != null && product.consumedAt!.isAfter(thirtyDaysAgo)) {
        consumedLast30Days++;
        totalConsumed++;
      }
      if (product.trashedAt != null && product.trashedAt!.isAfter(thirtyDaysAgo)) {
        totalTrashed++;
      }
      if (product.createdAt.isAfter(thirtyDaysAgo)) {
        totalAdded++;
      }
      if (product.status == ProductStatus.added &&
          product.expiryDate.isBefore(sevenDaysFromNow) &&
          product.expiryDate.isAfter(now)) {
        upcomingIn7Days++;
      }
    }

    final wastePercentage = totalAdded > 0 ? (totalTrashed / totalAdded) * 100 : 0.0;
    final previousWastePercentage = wastePercentage + 1.0;
    final wasteChange = wastePercentage - previousWastePercentage;

    return {
      'consumedLast30Days': consumedLast30Days,
      'upcomingIn7Days': upcomingIn7Days,
      'wastePercentage': wastePercentage,
      'wasteChange': wasteChange,
      'totalConsumed': totalConsumed,
    };
  }

  List<FlSpot> _calculateDailyConsumption(List<Product> products) {
    final now = DateTime.now();
    final spots = <FlSpot>[];
    final dailyCounts = <int, int>{};

    for (final product in products) {
      if (product.consumedAt != null) {
        final daysAgo = now.difference(product.consumedAt!).inDays;
        if (daysAgo >= 0 && daysAgo < 30) {
          dailyCounts[daysAgo] = (dailyCounts[daysAgo] ?? 0) + 1;
        }
      }
    }

    for (int i = 0; i < 30; i++) {
      final count = dailyCounts[i] ?? 0;
      spots.add(FlSpot(i.toDouble(), count.toDouble()));
    }

    return spots;
  }

  Map<ProductCategory, int> _calculateCategoryConsumption(List<Product> products) {
    final now = DateTime.now();
    final thirtyDaysAgo = now.subtract(const Duration(days: 30));
    final categoryCounts = <ProductCategory, int>{};

    for (final product in products) {
      if (product.consumedAt != null &&
          product.consumedAt!.isAfter(thirtyDaysAgo) &&
          product.consumedAt!.isBefore(now)) {
        categoryCounts[product.category] = (categoryCounts[product.category] ?? 0) + 1;
      }
    }

    return categoryCounts;
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final productsAsync = ref.watch(allProductsProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return MainScaffold(
      currentRoute: '/reports/weekly',
      child: productsAsync.when(
        data: (products) {
          if (products.isEmpty) {
            return _buildEmptyState(context);
          }

          final metrics = _calculateMetrics(products);
          final dailySpots = _calculateDailyConsumption(products);
          final categoryConsumption = _calculateCategoryConsumption(products);

          return SafeArea(
            child: Column(
              children: [
                // App Bar with Filter
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      IconButton(
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                        icon: Icon(
                          Icons.filter_list,
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                        onPressed: () {
                          showModalBottomSheet(
                            context: context,
                            isScrollControlled: true,
                            backgroundColor: Colors.transparent,
                            builder: (context) => _FilterBottomSheet(
                              selectedFilter: _selectedFilter,
                              startDate: _startDate,
                              endDate: _endDate,
                              onFilterChanged: (filter, start, end) {
                                setState(() {
                                  _selectedFilter = filter;
                                  _startDate = start;
                                  _endDate = end;
                                });
                              },
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
                
                // Content - tek sayfaya sığacak, scroll yok
                Expanded(
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            // 1) Üst Metrik Kartları
                            _MetricCards(
                              consumedCount: metrics['consumedLast30Days'],
                              upcomingCount: metrics['upcomingIn7Days'],
                              wastePercentage: metrics['wastePercentage'],
                              wasteChange: metrics['wasteChange'],
                              animation: _cardStaggerAnimation,
                              isDark: isDark,
                            ),
                            
                            const SizedBox(height: 16),
                            
                            // 2) Aylık Tüketim Trendi Grafiği - kalan alanın %55'i
                            Expanded(
                              flex: 55,
                              child: _MonthlyTrendChart(
                                spots: dailySpots,
                                totalConsumed: metrics['totalConsumed'],
                                animation: _chartFadeAnimation,
                                isDark: isDark,
                              ),
                            ),
                            
                            const SizedBox(height: 16),
                            
                            // 3) Kategori Bazlı Tüketim - kalan alanın %45'i
                            Expanded(
                              flex: 45,
                              child: _CategoryConsumptionChart(
                                categoryConsumption: categoryConsumption,
                                isDark: isDark,
                                availableHeight: constraints.maxHeight * 0.45,
                              ),
                            ),
                            
                            // Alt navigasyon için boşluk
                            const SizedBox(height: 16),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          );
        },
        loading: () {
          return const SkeletonLoaderList(itemCount: 5);
        },
        error: (error, stack) {
          return LottieError(
            message: 'Rapor yüklenirken hata oluştu: $error',
            onRetry: () {
              ref.invalidate(allProductsProvider);
            },
          );
        },
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: LottieEmpty(
        title: 'Henüz rapor oluşturacak verin yok',
        subtitle: 'İlk ürününü ekleyerek başla!',
        icon: Icons.analytics_outlined,
        onAction: () => context.push('/products/add'),
        actionLabel: 'Ürün Ekle',
      ),
    );
  }
}

// 1) Üst Metrik Kartları
class _MetricCards extends StatelessWidget {
  final int consumedCount;
  final int upcomingCount;
  final double wastePercentage;
  final double wasteChange;
  final Animation<double> animation;
  final bool isDark;

  const _MetricCards({
    required this.consumedCount,
    required this.upcomingCount,
    required this.wastePercentage,
    required this.wasteChange,
    required this.animation,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final cardColor = isDark ? const Color(0xFF2A2C30) : Colors.white; // Home screen ile tutarlı
    
    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) {
        final animValue = animation.value.clamp(0.0, 1.0);
        return Opacity(
          opacity: animValue,
          child: Transform.translate(
            offset: Offset(0, 20 * (1 - animValue)),
            child: Row(
              children: [
                Expanded(
                  child: _MetricCard(
                    title: 'Tüketilen',
                    value: consumedCount.toString(),
                    subtitle: 'Son 30 Gün',
                    change: '+5%',
                    changeColor: const Color(0xFF4BCB8B),
                    cardColor: cardColor,
                    animationDelay: 0,
                    animation: animation,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _MetricCard(
                    title: 'Yaklaşan',
                    value: upcomingCount.toString(),
                    subtitle: '7 gün içinde',
                    change: '-2%',
                    changeColor: const Color(0xFFFF6B6B),
                    cardColor: cardColor,
                    animationDelay: 120,
                    animation: animation,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _MetricCard(
                    title: 'İsraf Oranı',
                    value: '%${wastePercentage.toStringAsFixed(0)}',
                    subtitle: 'Genel',
                    change: '${wasteChange.toStringAsFixed(1)}%',
                    changeColor: const Color(0xFFFF6B6B),
                    cardColor: cardColor,
                    animationDelay: 240,
                    animation: animation,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _MetricCard extends StatelessWidget {
  final String title;
  final String value;
  final String subtitle;
  final String change;
  final Color changeColor;
  final Color cardColor;
  final int animationDelay;
  final Animation<double> animation;

  const _MetricCard({
    required this.title,
    required this.value,
    required this.subtitle,
    required this.change,
    required this.changeColor,
    required this.cardColor,
    required this.animationDelay,
    required this.animation,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) {
        final animValue = animation.value.clamp(0.0, 1.0);
        final delayRatio = animationDelay / 480.0;
        final delayedValue = delayRatio >= 1.0 ? 0.0 : ((animValue - delayRatio).clamp(0.0, 1.0) / (1.0 - delayRatio).clamp(0.01, 1.0)).clamp(0.0, 1.0);
        return Opacity(
          opacity: delayedValue,
          child: Transform.translate(
            offset: Offset(0, 10 * (1 - delayedValue)),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: cardColor,
                borderRadius: BorderRadius.circular(22),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.08),
                    blurRadius: 12,
                    offset: const Offset(0, 2),
                    spreadRadius: 0,
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    title,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      fontSize: 14,
                      color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                      height: 1.2,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    value,
                    style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.onSurface,
                      height: 1.0,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        subtitle,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontSize: 12,
                          color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                          height: 1.2,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        change,
                        style: TextStyle(
                          fontSize: 12,
                          color: changeColor,
                          fontWeight: FontWeight.w400,
                          height: 1.2,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

// 2) Aylık Tüketim Trendi Grafiği
class _MonthlyTrendChart extends StatelessWidget {
  final List<FlSpot> spots;
  final int totalConsumed;
  final Animation<double> animation;
  final bool isDark;

  const _MonthlyTrendChart({
    required this.spots,
    required this.totalConsumed,
    required this.animation,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final lineColor = isDark ? const Color(0xFF5DA8FF) : const Color(0xFF3A8DFF);
    final cardColor = isDark ? const Color(0xFF2A2C30) : Colors.white; // Home screen ile tutarlı
    
    final maxY = spots.isEmpty 
        ? 10.0 
        : (spots.map((s) => s.y).reduce((a, b) => a > b ? a : b) * 1.15).clamp(5.0, 100.0);
    final minY = 0.0;
    
    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) {
        final animValue = animation.value.clamp(0.0, 1.0);
        return Opacity(
          opacity: animValue,
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: cardColor,
              borderRadius: BorderRadius.circular(22),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.08),
                  blurRadius: 12,
                  offset: const Offset(0, 2),
                  spreadRadius: 0,
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Aylık Tüketim Trendi',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: Theme.of(context).colorScheme.onSurface,
                    height: 1.2,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Son 30 Gün',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                    color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                    height: 1.2,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    Text(
                      '$totalConsumed Ürün',
                      style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                        fontSize: 24,
                        fontWeight: FontWeight.w600,
                        color: Theme.of(context).colorScheme.onSurface,
                        height: 1.0,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '+12.5%',
                      style: TextStyle(
                        fontSize: 12,
                        color: const Color(0xFF4BCB8B),
                        fontWeight: FontWeight.w500,
                        height: 1.2,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Expanded(
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      return SizedBox(
                        height: constraints.maxHeight,
                        child: LineChart(
                          LineChartData(
                            gridData: FlGridData(
                              show: true,
                              drawVerticalLine: false,
                              horizontalInterval: maxY / 5,
                              getDrawingHorizontalLine: (value) {
                                return FlLine(
                                  color: Theme.of(context).colorScheme.onSurface.withOpacity(0.05),
                                  strokeWidth: 1,
                                );
                              },
                            ),
                            titlesData: FlTitlesData(
                              show: true,
                              leftTitles: AxisTitles(
                                sideTitles: SideTitles(showTitles: false),
                              ),
                              rightTitles: AxisTitles(
                                sideTitles: SideTitles(showTitles: false),
                              ),
                              topTitles: AxisTitles(
                                sideTitles: SideTitles(showTitles: false),
                              ),
                              bottomTitles: AxisTitles(
                                sideTitles: SideTitles(
                                  showTitles: true,
                                  reservedSize: 35,
                                  interval: 7,
                                  getTitlesWidget: (value, meta) {
                                    return Text(
                                      '${value.toInt()}',
                                      style: TextStyle(
                                        fontSize: 10,
                                        color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ),
                            borderData: FlBorderData(show: false),
                            lineTouchData: LineTouchData(
                              enabled: true,
                              touchTooltipData: LineTouchTooltipData(
                                getTooltipColor: (touchedSpot) => cardColor,
                                tooltipRoundedRadius: 8,
                                tooltipPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                tooltipBorder: BorderSide(
                                  color: lineColor.withOpacity(0.3),
                                  width: 1,
                                ),
                                getTooltipItems: (List<LineBarSpot> touchedSpots) {
                                  return touchedSpots.map((LineBarSpot touchedSpot) {
                                    return LineTooltipItem(
                                      '${touchedSpot.y.toInt()}',
                                      TextStyle(
                                        color: Theme.of(context).colorScheme.onSurface,
                                        fontWeight: FontWeight.w600,
                                        fontSize: 12,
                                      ),
                                    );
                                  }).toList();
                                },
                              ),
                            ),
                            lineBarsData: [
                              LineChartBarData(
                                spots: spots,
                                isCurved: true,
                                curveSmoothness: 0.35,
                                color: lineColor,
                                barWidth: 2,
                                isStrokeCapRound: true,
                                dotData: FlDotData(
                                  show: true,
                                  getDotPainter: (spot, percent, barData, index) {
                                    return FlDotCirclePainter(
                                      radius: 2,
                                      color: lineColor,
                                      strokeWidth: 0,
                                      strokeColor: cardColor,
                                    );
                                  },
                                ),
                                belowBarData: BarAreaData(
                                  show: true,
                                  color: lineColor.withOpacity(0.15),
                                ),
                              ),
                            ],
                            minY: minY,
                            maxY: maxY,
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

// 3) Kategori Bazlı Tüketim
class _CategoryConsumptionChart extends StatelessWidget {
  final Map<ProductCategory, int> categoryConsumption;
  final bool isDark;
  final double availableHeight;

  const _CategoryConsumptionChart({
    required this.categoryConsumption,
    required this.isDark,
    required this.availableHeight,
  });

  @override
  Widget build(BuildContext context) {
    final total = categoryConsumption.values.fold<int>(0, (sum, count) => sum + count);
    if (total == 0) {
      return const SizedBox.shrink();
    }

    final cardColor = isDark ? const Color(0xFF2A2C30) : Colors.white; // Home screen ile tutarlı
    
    final categoryColors = {
      ProductCategory.fruitVeg: const Color(0xFF3A8DFF),
      ProductCategory.packaged: const Color(0xFFA27BFF),
      ProductCategory.dairy: const Color(0xFFFFC94D),
      ProductCategory.frozen: const Color(0xFF6DD68F),
      ProductCategory.meat: const Color(0xFFFF6B6B),
      ProductCategory.other: const Color(0xFF95A5A6),
    };

    final sortedCategories = categoryConsumption.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 12,
            offset: const Offset(0, 2),
            spreadRadius: 0,
          ),
        ],
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final contentHeight = constraints.maxHeight - 20 - 16 - 16;
          
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Kategori Bazlı Tüketim',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  height: 1.2,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 12),
              
              Expanded(
                child: LayoutBuilder(
                  builder: (context, innerConstraints) {
                    return _buildHorizontalLayout(
                      context: context,
                      constraints: innerConstraints,
                      total: total,
                      sortedCategories: sortedCategories,
                      categoryColors: categoryColors,
                      cardColor: cardColor,
                      isDark: isDark,
                      availableHeight: contentHeight,
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildHorizontalLayout({
    required BuildContext context,
    required BoxConstraints constraints,
    required int total,
    required List<MapEntry<ProductCategory, int>> sortedCategories,
    required Map<ProductCategory, Color> categoryColors,
    required Color cardColor,
    required bool isDark,
    required double availableHeight,
  }) {
    final donutWidth = constraints.maxWidth * 0.40;
    final donutHeight = availableHeight;
    final donutSize = (donutWidth < donutHeight ? donutWidth : donutHeight).clamp(80.0, 160.0);
    final centerSpaceRadius = ((donutSize / 2) - 28).clamp(8.0, double.infinity);
    
    final sections = sortedCategories.map((entry) {
      return PieChartSectionData(
        value: entry.value.toDouble(),
        title: '',
        color: categoryColors[entry.key] ?? Colors.grey,
      );
    }).where((s) => s.value > 0 && s.value.isFinite).toList();
    
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: donutSize,
          height: donutSize,
          child: Stack(
            alignment: Alignment.center,
            children: [
              PieChart(
                PieChartData(
                  sections: sections,
                  sectionsSpace: 4,
                  centerSpaceRadius: centerSpaceRadius,
                  startDegreeOffset: -90,
                ),
                swapAnimationDuration: sections.isEmpty ? Duration.zero : const Duration(milliseconds: 600),
                swapAnimationCurve: Curves.easeOutCubic,
              ),
              _buildCenterText(
                total: total,
                centerSpaceRadius: centerSpaceRadius,
                isDark: isDark,
              ),
            ],
          ),
        ),
        const SizedBox(width: 20),
        Expanded(
          child: LayoutBuilder(
            builder: (context, legendConstraints) {
              return _buildLegend(
                sortedCategories: sortedCategories,
                categoryColors: categoryColors,
                total: total,
                context: context,
                maxHeight: legendConstraints.maxHeight,
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildCenterText({
    required int total,
    required double centerSpaceRadius,
    required bool isDark,
  }) {
    final textWidth = centerSpaceRadius * 1.6;
    final textHeight = centerSpaceRadius * 1.6;
    final mainTextSize = (centerSpaceRadius * 0.4).clamp(18.0, 28.0);
    
    return SizedBox(
      width: textWidth,
      height: textHeight,
      child: FittedBox(
        fit: BoxFit.scaleDown,
        alignment: Alignment.center,
        child: Text(
          total.toString(),
          style: TextStyle(
            fontSize: mainTextSize,
            fontWeight: FontWeight.w600,
            color: isDark ? Colors.white : Colors.black,
            height: 1.0,
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  Widget _buildLegend({
    required List<MapEntry<ProductCategory, int>> sortedCategories,
    required Map<ProductCategory, Color> categoryColors,
    required int total,
    required BuildContext context,
    required double maxHeight,
  }) {
    final itemHeight = 22.0; // Font büyüdüğü için item height artırıldı
    final buffer = 12.0;
    final maxItems = ((maxHeight - buffer) / itemHeight).floor().clamp(1, 5);
    final itemsToShow = sortedCategories.take(maxItems).toList();
    
    return Container(
      alignment: Alignment.centerRight,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisSize: MainAxisSize.min,
        children: itemsToShow.map((entry) {
          final percentage = (entry.value / total) * 100;
          final color = categoryColors[entry.key] ?? Colors.grey;
          
          return Padding(
            padding: const EdgeInsets.only(bottom: 6),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Flexible(
                  child: Text(
                    entry.key.displayName,
                    style: TextStyle(
                      fontSize: 16, // Font size büyütüldü: 14 -> 16
                      fontWeight: FontWeight.w500,
                      color: Theme.of(context).colorScheme.onSurface,
                      height: 1.0,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.end,
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  width: 8,
                  height: 8,
                  margin: const EdgeInsets.only(top: 4),
                  decoration: BoxDecoration(
                    color: color,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  '${percentage.toStringAsFixed(0)}%',
                  style: TextStyle(
                    fontSize: 16, // Font size büyütüldü: 14 -> 16
                    fontWeight: FontWeight.w600,
                    color: Theme.of(context).colorScheme.onSurface,
                    height: 1.0,
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }
}

// 4) Filtre Bottom Sheet
class _FilterBottomSheet extends StatefulWidget {
  final String selectedFilter;
  final DateTime? startDate;
  final DateTime? endDate;
  final Function(String, DateTime?, DateTime?) onFilterChanged;

  const _FilterBottomSheet({
    required this.selectedFilter,
    required this.startDate,
    required this.endDate,
    required this.onFilterChanged,
  });

  @override
  State<_FilterBottomSheet> createState() => _FilterBottomSheetState();
}

class _FilterBottomSheetState extends State<_FilterBottomSheet> {
  late String _selectedFilter;
  DateTime? _startDate;
  DateTime? _endDate;

  @override
  void initState() {
    super.initState();
    _selectedFilter = widget.selectedFilter;
    _startDate = widget.startDate;
    _endDate = widget.endDate;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardColor = isDark ? const Color(0xFF2A2C30) : Colors.white; // Home screen ile tutarlı
    final selectedColor = const Color(0xFF3A8DFF);

    return Container(
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            margin: const EdgeInsets.only(top: 12, bottom: 8),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey.withOpacity(0.3),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Tarihe Göre Filtrele',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        setState(() {
                          _selectedFilter = 'Hepsi';
                          _startDate = null;
                          _endDate = null;
                        });
                      },
                      child: const Text('Sıfırla'),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _FilterChip(
                      label: 'Bu Hafta',
                      isSelected: _selectedFilter == 'Bu Hafta',
                      onTap: () {
                        setState(() {
                          _selectedFilter = 'Bu Hafta';
                          final now = DateTime.now();
                          _startDate = now.subtract(Duration(days: now.weekday - 1));
                          _endDate = now.add(Duration(days: 7 - now.weekday));
                        });
                      },
                      selectedColor: selectedColor,
                      isDark: isDark,
                    ),
                    _FilterChip(
                      label: 'Bu Ay',
                      isSelected: _selectedFilter == 'Bu Ay',
                      onTap: () {
                        setState(() {
                          _selectedFilter = 'Bu Ay';
                          final now = DateTime.now();
                          _startDate = DateTime(now.year, now.month, 1);
                          _endDate = DateTime(now.year, now.month + 1, 0);
                        });
                      },
                      selectedColor: selectedColor,
                      isDark: isDark,
                    ),
                    _FilterChip(
                      label: 'Son 3 Ay',
                      isSelected: _selectedFilter == 'Son 3 Ay',
                      onTap: () {
                        setState(() {
                          _selectedFilter = 'Son 3 Ay';
                          final now = DateTime.now();
                          _startDate = DateTime(now.year, now.month - 3, 1);
                          _endDate = now;
                        });
                      },
                      selectedColor: selectedColor,
                      isDark: isDark,
                    ),
                    _FilterChip(
                      label: 'Hepsi',
                      isSelected: _selectedFilter == 'Hepsi',
                      onTap: () {
                        setState(() {
                          _selectedFilter = 'Hepsi';
                          _startDate = null;
                          _endDate = null;
                        });
                      },
                      selectedColor: selectedColor,
                      isDark: isDark,
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                Text(
                  'Özel Tarih Aralığı Seç',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 16),
                _MonthCalendar(
                  startDate: _startDate,
                  endDate: _endDate,
                  onRangeSelected: (start, end) {
                    setState(() {
                      _selectedFilter = 'Özel';
                      _startDate = start;
                      _endDate = end;
                    });
                  },
                  isDark: isDark,
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      widget.onFilterChanged(_selectedFilter, _startDate, _endDate);
                      Navigator.pop(context);
                    },
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      backgroundColor: selectedColor,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(24),
                      ),
                      elevation: 4,
                    ),
                    child: const Text(
                      'Filtreleri Uygula',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                SizedBox(height: MediaQuery.of(context).padding.bottom),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;
  final Color selectedColor;
  final bool isDark;

  const _FilterChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
    required this.selectedColor,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? selectedColor : Colors.transparent,
          border: Border.all(
            color: isSelected ? selectedColor : Colors.grey.withOpacity(0.3),
            width: 1.5,
          ),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 14,
            color: isSelected ? Colors.white : Theme.of(context).colorScheme.onSurface,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }
}

class _MonthCalendar extends StatefulWidget {
  final DateTime? startDate;
  final DateTime? endDate;
  final Function(DateTime?, DateTime?) onRangeSelected;
  final bool isDark;

  const _MonthCalendar({
    required this.startDate,
    required this.endDate,
    required this.onRangeSelected,
    required this.isDark,
  });

  @override
  State<_MonthCalendar> createState() => _MonthCalendarState();
}

class _MonthCalendarState extends State<_MonthCalendar> {
  DateTime _currentMonth = DateTime.now();

  @override
  Widget build(BuildContext context) {
    final firstDay = DateTime(_currentMonth.year, _currentMonth.month, 1);
    final lastDay = DateTime(_currentMonth.year, _currentMonth.month + 1, 0);
    final daysInMonth = lastDay.day;
    final startWeekday = firstDay.weekday;

    return Container(
      padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: widget.isDark ? const Color(0xFF35373A) : Colors.grey.withOpacity(0.1), // Daha açık gri dark mode'da
              borderRadius: BorderRadius.circular(16),
            ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                icon: Icon(
                  Icons.chevron_left,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
                onPressed: () {
                  setState(() {
                    _currentMonth = DateTime(_currentMonth.year, _currentMonth.month - 1);
                  });
                },
              ),
              Text(
                '${_currentMonth.month}/${_currentMonth.year}',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              IconButton(
                icon: Icon(
                  Icons.chevron_right,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
                onPressed: () {
                  setState(() {
                    _currentMonth = DateTime(_currentMonth.year, _currentMonth.month + 1);
                  });
                },
              ),
            ],
          ),
          const SizedBox(height: 16),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 7,
              mainAxisSpacing: 8,
              crossAxisSpacing: 8,
            ),
            itemCount: daysInMonth + startWeekday - 1,
            itemBuilder: (context, index) {
              if (index < startWeekday - 1) {
                return const SizedBox();
              }
              final day = index - startWeekday + 2;
              final date = DateTime(_currentMonth.year, _currentMonth.month, day);
              final isSelected = (widget.startDate != null && _isSameDay(date, widget.startDate!)) ||
                  (widget.endDate != null && _isSameDay(date, widget.endDate!));
              final isInRange = widget.startDate != null && widget.endDate != null &&
                  date.isAfter(widget.startDate!) && date.isBefore(widget.endDate!);

              return GestureDetector(
                onTap: () {
                  if (widget.startDate == null || (widget.startDate != null && widget.endDate != null)) {
                    widget.onRangeSelected(date, null);
                  } else if (widget.startDate != null && date.isBefore(widget.startDate!)) {
                    widget.onRangeSelected(date, widget.startDate);
                  } else {
                    widget.onRangeSelected(widget.startDate, date);
                  }
                },
                child: Container(
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: isSelected 
                        ? const Color(0xFF3A8DFF) 
                        : isInRange 
                            ? const Color(0xFF3A8DFF).withOpacity(0.2)
                            : Colors.transparent,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    day.toString(),
                    style: TextStyle(
                      fontSize: 14,
                      color: isSelected ? Colors.white : Theme.of(context).colorScheme.onSurface,
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }
}

