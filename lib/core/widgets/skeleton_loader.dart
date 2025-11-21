import 'package:flutter/material.dart';
import '../constants/spacing.dart';

/// Optimize edilmiş skeleton loader widget'ı
/// Shimmer effect ile modern loading pattern
class SkeletonLoader extends StatefulWidget {
  final double? width;
  final double? height;
  final BorderRadius? borderRadius;
  final Color? baseColor;
  final Color? highlightColor;
  
  const SkeletonLoader({
    super.key,
    this.width,
    this.height,
    this.borderRadius,
    this.baseColor,
    this.highlightColor,
  });

  // Preset skeleton loaders
  const SkeletonLoader.card({
    super.key,
    this.width,
    this.height = 120,
    this.borderRadius = AppSpacing.borderRadiusXL,
    this.baseColor,
    this.highlightColor,
  });

  const SkeletonLoader.listItem({
    super.key,
    this.width,
    this.height = 80,
    this.borderRadius = AppSpacing.borderRadiusLG,
    this.baseColor,
    this.highlightColor,
  });

  const SkeletonLoader.circle({
    super.key,
    this.width,
    this.height,
    this.borderRadius = AppSpacing.borderRadiusRound,
    this.baseColor,
    this.highlightColor,
  });

  @override
  State<SkeletonLoader> createState() => _SkeletonLoaderState();
}

class _SkeletonLoaderState extends State<SkeletonLoader>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat();
    
    _animation = Tween<double>(begin: -1.0, end: 2.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final baseColor = widget.baseColor ?? 
        (isDark ? Colors.grey[800]! : Colors.grey[200]!);
    final highlightColor = widget.highlightColor ?? 
        (isDark ? Colors.grey[700]! : Colors.grey[100]!);

    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Container(
          width: widget.width,
          height: widget.height,
          decoration: BoxDecoration(
            borderRadius: widget.borderRadius ?? AppSpacing.borderRadiusMD,
            gradient: LinearGradient(
              begin: Alignment(_animation.value - 1, 0),
              end: Alignment(_animation.value, 0),
              colors: [
                baseColor,
                highlightColor,
                baseColor,
              ],
              stops: const [0.0, 0.5, 1.0],
            ),
          ),
        );
      },
    );
  }
}

/// Skeleton loader list - ürün listesi için
class SkeletonLoaderList extends StatelessWidget {
  final int itemCount;
  final double itemHeight;
  
  const SkeletonLoaderList({
    super.key,
    this.itemCount = 5,
    this.itemHeight = 100,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: AppSpacing.screenPadding,
      itemCount: itemCount,
      itemBuilder: (context, index) {
        return Padding(
          padding: EdgeInsets.only(bottom: AppSpacing.lg),
          child: Row(
            children: [
              const SkeletonLoader.circle(
                width: 60,
                height: 60,
              ),
              AppSpacing.gapLG,
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SkeletonLoader(
                      height: 16,
                      borderRadius: AppSpacing.borderRadiusSM,
                    ),
                    AppSpacing.gapSM,
                    SkeletonLoader(
                      height: 12,
                      width: 120,
                      borderRadius: AppSpacing.borderRadiusSM,
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

/// Skeleton loader grid - buzdolabı grid için
class SkeletonLoaderGrid extends StatelessWidget {
  final int crossAxisCount;
  final double childAspectRatio;
  final int itemCount;
  
  const SkeletonLoaderGrid({
    super.key,
    this.crossAxisCount = 3,
    this.childAspectRatio = 1.0,
    this.itemCount = 6,
  });

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      padding: AppSpacing.screenPadding,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        crossAxisSpacing: AppSpacing.md,
        mainAxisSpacing: AppSpacing.md,
        childAspectRatio: childAspectRatio,
      ),
      itemCount: itemCount,
      itemBuilder: (context, index) {
        return const SkeletonLoader.card();
      },
    );
  }
}

