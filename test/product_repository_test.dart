import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:gida_koruyucu/data/models/product.dart';
import 'package:gida_koruyucu/data/models/product_category.dart';
import 'package:gida_koruyucu/data/models/product_status.dart';
import 'package:gida_koruyucu/data/repositories/product_repository.dart';

void main() {
  late ProductRepository repository;
  late Box<Product> testBox;

  setUpAll(() async {
    // Test ortamında Hive.init() kullan (initFlutter değil)
    Hive.init('test_hive');
    Hive.registerAdapter(ProductAdapter());
    Hive.registerAdapter(ProductCategoryAdapter());
    Hive.registerAdapter(ProductStatusAdapter());
  });

  setUp(() async {
    // Test için gerçek box'ı aç (ProductRepository bunu kullanıyor)
    testBox = await Hive.openBox<Product>('products');
    repository = ProductRepository();
  });

  tearDown(() async {
    await testBox.clear();
    await testBox.close();
  });

  group('ProductRepository Tests', () {
    test('addProduct - ürün eklenmeli', () async {
      final product = Product(
        id: 'test-1',
        name: 'Test Ürün',
        expiryDate: DateTime.now().add(const Duration(days: 7)),
        category: ProductCategory.fruitVeg,
        createdAt: DateTime.now(),
      );

      await repository.addProduct(product);
      final saved = await repository.getProductById('test-1');

      expect(saved, isNotNull);
      expect(saved!.name, 'Test Ürün');
      expect(saved.category, ProductCategory.fruitVeg);
    });

    test('getActiveProducts - sadece aktif ürünler dönmeli', () async {
      final activeProduct = Product(
        id: 'active-1',
        name: 'Aktif Ürün',
        expiryDate: DateTime.now().add(const Duration(days: 5)),
        category: ProductCategory.dairy,
        status: ProductStatus.added,
        createdAt: DateTime.now(),
      );

      final consumedProduct = Product(
        id: 'consumed-1',
        name: 'Tüketilen Ürün',
        expiryDate: DateTime.now().add(const Duration(days: 3)),
        category: ProductCategory.meat,
        status: ProductStatus.consumed,
        createdAt: DateTime.now(),
      );

      await repository.addProduct(activeProduct);
      await repository.addProduct(consumedProduct);

      final activeProducts = await repository.getActiveProducts();

      expect(activeProducts.length, 1);
      expect(activeProducts.first.id, 'active-1');
    });

    test('updateProduct - ürün güncellenmeli', () async {
      final product = Product(
        id: 'update-1',
        name: 'Güncellenecek Ürün',
        expiryDate: DateTime.now().add(const Duration(days: 10)),
        category: ProductCategory.packaged,
        createdAt: DateTime.now(),
      );

      await repository.addProduct(product);
      product.status = ProductStatus.consumed;
      product.consumedAt = DateTime.now();
      await repository.updateProduct(product);

      final updated = await repository.getProductById('update-1');
      expect(updated!.status, ProductStatus.consumed);
      expect(updated.consumedAt, isNotNull);
    });

    test('deleteProduct - ürün silinmeli', () async {
      final product = Product(
        id: 'delete-1',
        name: 'Silinecek Ürün',
        expiryDate: DateTime.now().add(const Duration(days: 5)),
        category: ProductCategory.frozen,
        createdAt: DateTime.now(),
      );

      await repository.addProduct(product);
      await repository.deleteProduct('delete-1');

      final deleted = await repository.getProductById('delete-1');
      expect(deleted, isNull);
    });

    test('getProductsByCategory - kategoriye göre filtrelemeli', () async {
      final fruit1 = Product(
        id: 'fruit-1',
        name: 'Elma',
        expiryDate: DateTime.now().add(const Duration(days: 5)),
        category: ProductCategory.fruitVeg,
        createdAt: DateTime.now(),
      );

      final fruit2 = Product(
        id: 'fruit-2',
        name: 'Muz',
        expiryDate: DateTime.now().add(const Duration(days: 3)),
        category: ProductCategory.fruitVeg,
        createdAt: DateTime.now(),
      );

      final dairy = Product(
        id: 'dairy-1',
        name: 'Süt',
        expiryDate: DateTime.now().add(const Duration(days: 7)),
        category: ProductCategory.dairy,
        createdAt: DateTime.now(),
      );

      await repository.addProduct(fruit1);
      await repository.addProduct(fruit2);
      await repository.addProduct(dairy);

      final fruits = await repository.getProductsByCategory(ProductCategory.fruitVeg);
      expect(fruits.length, 2);
      expect(fruits.every((p) => p.category == ProductCategory.fruitVeg), true);
    });

    test('searchProducts - arama çalışmalı', () async {
      final product1 = Product(
        id: 'search-1',
        name: 'Elma',
        expiryDate: DateTime.now().add(const Duration(days: 5)),
        category: ProductCategory.fruitVeg,
        createdAt: DateTime.now(),
      );

      final product2 = Product(
        id: 'search-2',
        name: 'Ekmek',
        expiryDate: DateTime.now().add(const Duration(days: 3)),
        category: ProductCategory.packaged,
        createdAt: DateTime.now(),
      );

      final product3 = Product(
        id: 'search-3',
        name: 'Muz',
        expiryDate: DateTime.now().add(const Duration(days: 7)),
        category: ProductCategory.fruitVeg,
        createdAt: DateTime.now(),
      );

      await repository.addProduct(product1);
      await repository.addProduct(product2);
      await repository.addProduct(product3);

      final results = await repository.searchProducts('elma');
      expect(results.length, 1);
      expect(results.first.name.toLowerCase(), contains('elma'));
    });

    test('searchProducts - sadece aktif ürünler aranmalı', () async {
      final active = Product(
        id: 'active-search',
        name: 'Aktif Ürün',
        expiryDate: DateTime.now().add(const Duration(days: 5)),
        category: ProductCategory.other,
        status: ProductStatus.added,
        createdAt: DateTime.now(),
      );

      final consumed = Product(
        id: 'consumed-search',
        name: 'Tüketilen Ürün',
        expiryDate: DateTime.now().add(const Duration(days: 3)),
        category: ProductCategory.other,
        status: ProductStatus.consumed,
        createdAt: DateTime.now(),
      );

      await repository.addProduct(active);
      await repository.addProduct(consumed);

      final results = await repository.searchProducts('ürün');
      expect(results.length, 1);
      expect(results.first.status, ProductStatus.added);
    });
  });
}

