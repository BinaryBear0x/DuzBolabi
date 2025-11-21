import 'package:flutter/material.dart';
import '../../../core/constants/spacing.dart';

class LevelUpModal extends StatelessWidget {
  final int level;

  const LevelUpModal({
    super.key,
    required this.level,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: AppSpacing.borderRadiusXXL,
      ),
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.xl),
        decoration: BoxDecoration(
          borderRadius: AppSpacing.borderRadiusXXL,
          gradient: LinearGradient(
            colors: [
              Theme.of(context).colorScheme.primary,
              Theme.of(context).colorScheme.primary.withOpacity(0.7),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Level up icon
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.onPrimary.withOpacity(0.3),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.emoji_events,
                size: 50,
                color: Theme.of(context).colorScheme.onPrimary,
              ),
            ),

            const SizedBox(height: AppSpacing.lg),

            // Level up text
            Text(
              'Level Up!',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onPrimary,
                    fontWeight: FontWeight.bold,
                  ),
            ),

            const SizedBox(height: AppSpacing.sm),

            // New level
            Text(
              'Seviye $level\'e ulaştınız!',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: Theme.of(context).colorScheme.onPrimary.withOpacity(0.9),
                  ),
            ),

            const SizedBox(height: AppSpacing.xl),

            // Close button
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.onPrimary,
                foregroundColor: Theme.of(context).colorScheme.primary,
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.xl,
                  vertical: AppSpacing.md,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: AppSpacing.borderRadiusLG,
                ),
              ),
              child: const Text('Harika!'),
            ),
          ],
        ),
      ),
    );
  }
}

