import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import '../constants/spacing.dart';

/// Lottie animasyon widget'ları
/// Success, error, empty state için optimize edilmiş

class LottieSuccess extends StatelessWidget {
  final String? message;
  final VoidCallback? onAnimationComplete;
  
  const LottieSuccess({
    super.key,
    this.message,
    this.onAnimationComplete,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Lottie.asset(
          'assets/animations/success.json',
          width: 200,
          height: 200,
          fit: BoxFit.contain,
          repeat: false,
          onLoaded: (composition) {
            // Animasyon tamamlandığında callback çağır
            Future.delayed(composition.duration, () {
              onAnimationComplete?.call();
            });
          },
          errorBuilder: (context, error, stackTrace) {
            // Fallback: Icon ile success göster
            return Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.check_circle,
                size: 100,
                color: Theme.of(context).colorScheme.primary,
              ),
            );
          },
        ),
        if (message != null) ...[
          AppSpacing.gapLG,
          Text(
            message!,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: Theme.of(context).colorScheme.primary,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ],
    );
  }
}

class LottieError extends StatelessWidget {
  final String? message;
  final VoidCallback? onRetry;
  
  const LottieError({
    super.key,
    this.message,
    this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Lottie.asset(
          'assets/animations/error.json',
          width: 200,
          height: 200,
          fit: BoxFit.contain,
          repeat: true,
          errorBuilder: (context, error, stackTrace) {
            // Fallback: Icon ile error göster
            return Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.error.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.error_outline,
                size: 100,
                color: Theme.of(context).colorScheme.error,
              ),
            );
          },
        ),
        if (message != null) ...[
          AppSpacing.gapLG,
          Padding(
            padding: AppSpacing.screenHorizontal,
            child: Text(
              message!,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: Theme.of(context).colorScheme.error,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
        if (onRetry != null) ...[
          AppSpacing.gapXL,
          ElevatedButton.icon(
            onPressed: onRetry,
            icon: const Icon(Icons.refresh),
            label: const Text('Tekrar Dene'),
          ),
        ],
      ],
    );
  }
}

class LottieEmpty extends StatelessWidget {
  final String title;
  final String? subtitle;
  final IconData? icon;
  final VoidCallback? onAction;
  final String? actionLabel;
  
  const LottieEmpty({
    super.key,
    required this.title,
    this.subtitle,
    this.icon,
    this.onAction,
    this.actionLabel,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Lottie.asset(
          'assets/animations/empty.json',
          width: 250,
          height: 250,
          fit: BoxFit.contain,
          repeat: true,
          errorBuilder: (context, error, stackTrace) {
            // Fallback: Icon ile empty state göster
            return Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon ?? Icons.inbox_outlined,
                size: 100,
                color: Theme.of(context).colorScheme.primary.withOpacity(0.5),
              ),
            );
          },
        ),
        AppSpacing.gapLG,
        Text(
          title,
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
          textAlign: TextAlign.center,
        ),
        if (subtitle != null) ...[
          AppSpacing.gapMD,
          Padding(
            padding: AppSpacing.screenHorizontal,
            child: Text(
              subtitle!,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: Theme.of(context).textTheme.bodyMedium?.color,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
        if (onAction != null && actionLabel != null) ...[
          AppSpacing.gapXL,
          ElevatedButton.icon(
            onPressed: onAction,
            icon: const Icon(Icons.add),
            label: Text(actionLabel!),
          ),
        ],
      ],
    );
  }
}

class LottieLoading extends StatelessWidget {
  final String? message;
  
  const LottieLoading({
    super.key,
    this.message,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Lottie.asset(
          'assets/animations/loading.json',
          width: 150,
          height: 150,
          fit: BoxFit.contain,
          repeat: true,
          errorBuilder: (context, error, stackTrace) {
            // Fallback: CircularProgressIndicator
            return const SizedBox(
              width: 150,
              height: 150,
              child: CircularProgressIndicator(),
            );
          },
        ),
        if (message != null) ...[
          AppSpacing.gapLG,
          Text(
            message!,
            style: Theme.of(context).textTheme.bodyLarge,
            textAlign: TextAlign.center,
          ),
        ],
      ],
    );
  }
}

