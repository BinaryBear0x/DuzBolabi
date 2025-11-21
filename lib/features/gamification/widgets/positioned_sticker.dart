import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/models/sticker_item.dart';
import '../providers/shop_provider.dart';

class PositionedSticker extends ConsumerWidget {
  final StickerItem sticker;
  final StickerPosition? position;

  const PositionedSticker({
    super.key,
    required this.sticker,
    this.position,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final defaultPosition = StickerPosition(
      positionX: 50.0,
      positionY: 100.0,
      scale: 1.0,
      rotation: 0.0,
    );

    final finalPosition = position ?? defaultPosition;

    // Eğer sticker'da pozisyon bilgisi varsa, onu kullan
    final x = sticker.positionX ?? finalPosition.positionX;
    final y = sticker.positionY ?? finalPosition.positionY;
    final scale = sticker.scale;
    final rotation = sticker.rotation;

    return Positioned(
      left: x,
      top: y,
      child: Transform.scale(
        scale: scale,
        child: Transform.rotate(
          angle: rotation,
          child: GestureDetector(
            onPanUpdate: (details) {
              // Drag işlemi - pozisyonu güncelle
              // Bu implementasyon daha sonra geliştirilebilir
            },
            child: Image.asset(
              sticker.assetPath,
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
                  child: Icon(
                    Icons.star,
                    color: Theme.of(context).colorScheme.secondary,
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}

