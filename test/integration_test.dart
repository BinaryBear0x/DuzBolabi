import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:gida_koruyucu/data/models/product.dart';
import 'package:gida_koruyucu/data/models/product_category.dart';
import 'package:gida_koruyucu/data/models/product_status.dart';
import 'package:gida_koruyucu/data/models/user_stats.dart';
import 'package:gida_koruyucu/data/repositories/product_repository.dart';
import 'package:gida_koruyucu/data/repositories/user_stats_repository.dart';
import 'package:gida_koruyucu/features/gamification/gamification_service.dart';
import 'package:gida_koruyucu/core/constants/app_constants.dart';

void main() {
  late ProductRepository productRepository;
  late UserStatsRepository statsRepository;
  late GamificationService gamificationService;

  setUpAll(() async {
    // Test ortamında Hive.init() kullan (initFlutter değil)
    Hive.init('test_hive');
    Hive.registerAdapter(ProductAdapter());
    Hive.registerAdapter(ProductCategoryAdapter());
    Hive.registerAdapter(ProductStatusAdapter());
    Hive.registerAdapter(UserStatsAdapter());
  });

  setUp(() async {
    // Test için gerçek box'ları aç
    await Hive.openBox<Product>('products');
    await Hive.openBox('user_stats');
    
    productRepository = ProductRepository();
    statsRepository = UserStatsRepository();
    gamificationService = GamificationService(statsRepository);
  });

  tearDown(() async {
    await Hive.box<Product>('products').clear();
    await Hive.box('user_stats').clear();
  });

  group('Integration Tests - Tam Akış', () {
    test('Ürün ekleme ve listeleme akışı', () async {
      // 1. Ürün ekle
      final product = Product(
        id: 'integration-1',
        name: 'Elma',
        expiryDate: DateTime.now().add(const Duration(days: 7)),
        category: ProductCategory.fruitVeg,
        createdAt: DateTime.now(),
      );

      await productRepository.addProduct(product);
      await gamificationService.handleProductAdded(product);

      // 2. Ürünü kontrol et
      final saved = await productRepository.getProductById('integration-1');
      expect(saved, isNotNull);
      expect(saved!.name, 'Elma');

      // 3. Aktif ürünleri listele
      final activeProducts = await productRepository.getActiveProducts();
      expect(activeProducts.length, greaterThan(0));
      expect(activeProducts.any((p) => p.id == 'integration-1'), true);

      // 4. Stats kontrol et
      final stats = await statsRepository.getUserStats();
      expect(stats.totalAdded, 1);
    });

    test('Ürün tüketme akışı', () async {
      // 1. Ürün ekle
      final product = Product(
        id: 'integration-2',
        name: 'Süt',
        expiryDate: DateTime.now().add(const Duration(days: 5)),
        category: ProductCategory.dairy,
        createdAt: DateTime.now(),
      );

      await productRepository.addProduct(product);

      // 2. Ürünü tüket
      product.status = ProductStatus.consumed;
      product.consumedAt = DateTime.now();
      await productRepository.updateProduct(product);
      await gamificationService.handleProductStatusChange(
        product,
        ProductStatus.added,
        ProductStatus.consumed,
      );

      // 3. Aktif ürünlerde olmamalı
      final activeProducts = await productRepository.getActiveProducts();
      expect(activeProducts.any((p) => p.id == 'integration-2'), false);

      // 4. Stats kontrol et
      final stats = await statsRepository.getUserStats();
      expect(stats.totalConsumed, 1);
      expect(stats.totalPoints, AppConstants.pointsConsumedBeforeExpiry);
    });

    test('Ürün çöpe atma akışı', () async {
      // 1. Süresi geçmiş ürün ekle
      final product = Product(
        id: 'integration-3',
        name: 'Eski Ürün',
        expiryDate: DateTime.now().subtract(const Duration(days: 2)),
        category: ProductCategory.other,
        createdAt: DateTime.now().subtract(const Duration(days: 10)),
      );

      await productRepository.addProduct(product);

      // 2. Ürünü çöpe at
      product.status = ProductStatus.trashed;
      product.trashedAt = DateTime.now();
      await productRepository.updateProduct(product);
      await gamificationService.handleProductStatusChange(
        product,
        ProductStatus.added,
        ProductStatus.trashed,
      );

      // 3. Stats kontrol et
      final stats = await statsRepository.getUserStats();
      expect(stats.totalTrashed, 1);
      // Negatif puanlar 0'a çekilir, bu yüzden 0 bekliyoruz
      expect(stats.totalPoints, 0);
    });

    test('Arama ve filtreleme akışı', () async {
      // 1. Birden fazla ürün ekle
      final products = [
        Product(
          id: 'search-1',
          name: 'Elma',
          expiryDate: DateTime.now().add(const Duration(days: 5)),
          category: ProductCategory.fruitVeg,
          createdAt: DateTime.now(),
        ),
        Product(
          id: 'search-2',
          name: 'Ekmek',
          expiryDate: DateTime.now().add(const Duration(days: 3)),
          category: ProductCategory.packaged,
          createdAt: DateTime.now(),
        ),
        Product(
          id: 'search-3',
          name: 'Muz',
          expiryDate: DateTime.now().add(const Duration(days: 7)),
          category: ProductCategory.fruitVeg,
          createdAt: DateTime.now(),
        ),
      ];

      for (final product in products) {
        await productRepository.addProduct(product);
      }

      // 2. Arama yap
      final searchResults = await productRepository.searchProducts('elma');
      expect(searchResults.length, 1);
      expect(searchResults.first.name.toLowerCase(), contains('elma'));

      // 3. Kategoriye göre filtrele
      final fruits = await productRepository.getProductsByCategory(ProductCategory.fruitVeg);
      expect(fruits.length, 2);
      expect(fruits.every((p) => p.category == ProductCategory.fruitVeg), true);
    });

    test('Puan ve level sistemi akışı', () async {
      // 1. Birden fazla ürün ekle ve tüket
      for (int i = 0; i < 3; i++) {
        final product = Product(
          id: 'points-$i',
          name: 'Ürün $i',
          expiryDate: DateTime.now().add(const Duration(days: 5)),
          category: ProductCategory.other,
          createdAt: DateTime.now(),
        );

        await productRepository.addProduct(product);
        product.status = ProductStatus.consumed;
        product.consumedAt = DateTime.now();
        await productRepository.updateProduct(product);
        await gamificationService.handleProductStatusChange(
          product,
          ProductStatus.added,
          ProductStatus.consumed,
        );
      }

      // 2. Stats kontrol et
      final stats = await statsRepository.getUserStats();
      expect(stats.totalConsumed, 3);
      expect(stats.totalPoints, AppConstants.pointsConsumedBeforeExpiry * 3);
      
      // 3. Level kontrol et (her 100 puanda 1 level)
      final expectedLevel = (stats.totalPoints / 100).floor() + 1;
      expect(stats.currentLevel, expectedLevel);
    });
  });
}

