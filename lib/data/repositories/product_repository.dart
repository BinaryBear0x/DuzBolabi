import 'package:hive_flutter/hive_flutter.dart';
import '../models/product.dart';
import '../models/product_category.dart';
import '../models/product_status.dart';

class ProductRepository {
  static const String _boxName = 'products';

  Box<Product> get _box {
    // Box'ın açık ve doğru tipte olduğundan emin ol
    if (!Hive.isBoxOpen(_boxName)) {
      throw Exception('Products box is not open. Please call StorageUtils.init() first.');
    }
    return Hive.box<Product>(_boxName);
  }

  Future<List<Product>> getAllProducts() async {
    return _box.values.toList();
  }

  Future<List<Product>> getActiveProducts() async {
    return _box.values
        .where((product) => product.status == ProductStatus.added)
        .toList();
  }

  Future<Product?> getProductById(String id) async {
    return _box.get(id);
  }

  Future<void> addProduct(Product product) async {
    try {
      // Hive put işlemi - senkron ama çok hızlı (genelde <1ms)
      // Future döndürmek için microtask kullan
      await Future.microtask(() {
        _box.put(product.id, product);
      });
    } catch (e) {
      throw Exception('Ürün eklenirken hata oluştu: $e');
    }
  }

  Future<void> updateProduct(Product product) async {
    await _box.put(product.id, product);
  }

  Future<void> deleteProduct(String id) async {
    await _box.delete(id);
  }

  Future<List<Product>> getProductsByCategory(ProductCategory category) async {
    return _box.values
        .where((product) => 
            product.category == category && 
            product.status == ProductStatus.added)
        .toList();
  }

  // Tarihi geçen aktif ürünleri getir
  Future<List<Product>> getExpiredProducts() async {
    return _box.values
        .where((product) => 
            product.status == ProductStatus.added &&
            product.remainingDays < 0)
        .toList();
  }

  Future<List<Product>> searchProducts(String query) async {
    final lowerQuery = query.toLowerCase();
    return _box.values
        .where((product) =>
            product.name.toLowerCase().contains(lowerQuery) &&
            product.status == ProductStatus.added)
        .toList();
  }

  Future<void> deleteAllProducts() async {
    await _box.clear();
  }
}

