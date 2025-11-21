import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/product.dart';
import '../../data/models/product_status.dart';
import '../../features/products/providers/product_provider.dart';
import 'package:intl/intl.dart';

class TrashScreen extends ConsumerWidget {
  const TrashScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Çöp kutusu için tüm ürünleri getir (trashed olanları görmek için)
    final productsAsync = ref.watch(allProductsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Çöp Kutusu'),
      ),
      body: productsAsync.when(
        data: (products) {
          // Tek döngüde filtrele - performans için
          final trashedProducts = <Product>[];
          for (final product in products) {
            if (product.status == ProductStatus.trashed) {
              trashedProducts.add(product);
            }
          }

          if (trashedProducts.isEmpty) {
            return const Center(
              child: Text('Çöp kutusu boş'),
            );
          }

          return RepaintBoundary(
            child: ListView.builder(
              key: const ValueKey('trash_list'),
              padding: const EdgeInsets.all(16),
              itemCount: trashedProducts.length,
              itemBuilder: (context, index) {
                final product = trashedProducts[index];
                return _TrashItemCard(
                  key: ValueKey('trash_item_${product.id}'),
                  product: product,
                );
              },
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(child: Text('Hata: $error')),
      ),
    );
  }
}

class _TrashItemCard extends ConsumerWidget {
  final Product product;

  const _TrashItemCard({
    super.key,
    required this.product,
  });

  Future<void> _restoreProduct(BuildContext context, WidgetRef ref) async {
    if (!context.mounted) return;
    
    try {
      product.status = ProductStatus.added;
      product.trashedAt = null;

      final repository = ref.read(productRepositoryProvider);
      await repository.updateProduct(product);

      if (context.mounted) {
        // Tüm product provider'ları invalidate et - raporlar için allProductsProvider da güncellensin
        ref.invalidate(productsProvider);
        ref.invalidate(allProductsProvider);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Ürün geri yüklendi'),
            backgroundColor: Color(0xFF42C97B),
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Hata: $e'),
            backgroundColor: const Color(0xFFFF6B6B),
          ),
        );
      }
    }
  }

  Future<void> _deletePermanently(BuildContext context, WidgetRef ref) async {
    if (!context.mounted) return;
    
    final confirmed = await showDialog<bool>(
      context: context,
      barrierDismissible: true,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
        title: const Text('Kalıcı Olarak Sil'),
        content: const Text('Bu ürünü kalıcı olarak silmek istediğinizden emin misiniz?'),
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
              foregroundColor: const Color(0xFFFF6B6B),
            ),
            child: const Text('Sil'),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      try {
        final repository = ref.read(productRepositoryProvider);
        await repository.deleteProduct(product.id);

        if (context.mounted) {
          // Tüm product provider'ları invalidate et - raporlar için allProductsProvider da güncellensin
          ref.invalidate(productsProvider);
          ref.invalidate(allProductsProvider);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Ürün kalıcı olarak silindi'),
              backgroundColor: Color(0xFFFF6B6B),
            ),
          );
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Hata: $e'),
              backgroundColor: const Color(0xFFFF6B6B),
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return RepaintBoundary(
      child: _TrashItemCardContent(
        product: product,
        onRestore: () => _restoreProduct(context, ref),
        onDelete: () => _deletePermanently(context, ref),
      ),
    );
  }
}

class _TrashItemCardContent extends StatelessWidget {
  final Product product;
  final VoidCallback onRestore;
  final VoidCallback onDelete;

  const _TrashItemCardContent({
    required this.product,
    required this.onRestore,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('dd/MM/yyyy');

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.error.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            Icons.delete,
            color: Theme.of(context).colorScheme.error,
          ),
        ),
        title: Text(product.name),
        subtitle: Text(
          'Çöpe gitti: ${product.trashedAt != null ? dateFormat.format(product.trashedAt!) : 'Bilinmiyor'}',
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.restore),
              onPressed: onRestore,
              tooltip: 'Geri Yükle',
            ),
            IconButton(
              icon: const Icon(Icons.delete_forever),
              onPressed: onDelete,
              tooltip: 'Kalıcı Olarak Sil',
            ),
          ],
        ),
      ),
    );
  }
}

