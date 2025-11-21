import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/repositories/product_repository.dart';
import '../../../data/models/product.dart';
import '../../../data/models/product_category.dart';

final productRepositoryProvider = Provider<ProductRepository>((ref) {
  return ProductRepository();
});

final productsProvider = FutureProvider.autoDispose<List<Product>>((ref) async {
  final repository = ref.watch(productRepositoryProvider);
  ref.keepAlive(); // Sayfa geçişlerinde cache'de kalsın
  return await repository.getActiveProducts();
});

final productProvider = FutureProvider.family<Product?, String>((ref, id) async {
  final repository = ref.watch(productRepositoryProvider);
  return await repository.getProductById(id);
});

final productsByCategoryProvider =
    FutureProvider.family<List<Product>, ProductCategory>((ref, category) async {
  final repository = ref.watch(productRepositoryProvider);
  return await repository.getProductsByCategory(category);
});

// Tarihi geçen ürünler provider'ı
final expiredProductsProvider = FutureProvider.autoDispose<List<Product>>((ref) async {
  final repository = ref.watch(productRepositoryProvider);
  ref.keepAlive();
  return await repository.getExpiredProducts();
});

final searchProductsProvider =
    FutureProvider.family<List<Product>, String>((ref, query) async {
  final repository = ref.watch(productRepositoryProvider);
  if (query.isEmpty) {
    return await repository.getActiveProducts();
  }
  return await repository.searchProducts(query);
});

// Raporlar için tüm ürünleri getir (tüketilen ve çöpe giden dahil)
final allProductsProvider = FutureProvider.autoDispose<List<Product>>((ref) async {
  final repository = ref.watch(productRepositoryProvider);
  ref.keepAlive(); // Sayfa geçişlerinde cache'de kalsın
  return await repository.getAllProducts();
});

