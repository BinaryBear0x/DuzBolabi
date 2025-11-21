import 'package:flutter_test/flutter_test.dart';
import 'package:gida_koruyucu/data/models/product.dart';
import 'package:gida_koruyucu/data/models/product_category.dart';
import 'package:gida_koruyucu/data/models/product_status.dart';
import 'package:gida_koruyucu/data/models/user_stats.dart';
import 'package:gida_koruyucu/data/repositories/user_stats_repository.dart';
import 'package:gida_koruyucu/features/gamification/gamification_service.dart';
import 'package:gida_koruyucu/core/constants/app_constants.dart';
import 'package:hive/hive.dart';

void main() {
  late GamificationService service;
  late UserStatsRepository repository;
  late Box testBox;

  setUpAll(() async {
    // Test ortamında Hive.init() kullan (initFlutter değil)
    Hive.init('test_hive');
    Hive.registerAdapter(UserStatsAdapter());
  });

  setUp(() async {
    // Test için gerçek box'ı aç
    testBox = await Hive.openBox('user_stats');
    repository = UserStatsRepository();
    service = GamificationService(repository);
  });

  tearDown(() async {
    await testBox.clear();
    await testBox.close();
  });

  group('GamificationService Tests', () {
    test('handleProductAdded - ürün eklendiğinde added artmalı', () async {
      final product = Product(
        id: 'test-1',
        name: 'Test Ürün',
        expiryDate: DateTime.now().add(const Duration(days: 7)),
        category: ProductCategory.other,
        createdAt: DateTime.now(),
      );

      await service.handleProductAdded(product);
      final stats = await repository.getUserStats();

      expect(stats.totalAdded, 1);
    });

    test('handleProductStatusChange - consumed before expiry puan vermeli', () async {
      final product = Product(
        id: 'test-2',
        name: 'Test Ürün',
        expiryDate: DateTime.now().add(const Duration(days: 5)),
        category: ProductCategory.other,
        status: ProductStatus.added,
        createdAt: DateTime.now(),
      );

      await service.handleProductStatusChange(
        product,
        ProductStatus.added,
        ProductStatus.consumed,
      );

      final stats = await repository.getUserStats();
      expect(stats.totalConsumed, 1);
      expect(stats.totalPoints, AppConstants.pointsConsumedBeforeExpiry);
    });

    test('handleProductStatusChange - trashed after expiry puan düşürmeli', () async {
      final product = Product(
        id: 'test-3',
        name: 'Test Ürün',
        expiryDate: DateTime.now().subtract(const Duration(days: 2)),
        category: ProductCategory.other,
        status: ProductStatus.added,
        createdAt: DateTime.now().subtract(const Duration(days: 10)),
      );

      await service.handleProductStatusChange(
        product,
        ProductStatus.added,
        ProductStatus.trashed,
      );

      final stats = await repository.getUserStats();
      expect(stats.totalTrashed, 1);
      // Negatif puanlar 0'a çekilir, bu yüzden 0 bekliyoruz
      expect(stats.totalPoints, 0);
    });

    test('handleProductStatusChange - aynı status değişmemeli', () async {
      final product = Product(
        id: 'test-4',
        name: 'Test Ürün',
        expiryDate: DateTime.now().add(const Duration(days: 5)),
        category: ProductCategory.other,
        status: ProductStatus.consumed,
        createdAt: DateTime.now(),
      );

      final initialStats = await repository.getUserStats();
      final initialConsumed = initialStats.totalConsumed;

      await service.handleProductStatusChange(
        product,
        ProductStatus.consumed,
        ProductStatus.consumed,
      );

      final stats = await repository.getUserStats();
      expect(stats.totalConsumed, initialConsumed);
    });
  });
}

