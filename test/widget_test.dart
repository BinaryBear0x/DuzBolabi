import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';
import 'package:gida_koruyucu/app/app.dart';
import 'package:gida_koruyucu/data/models/product.dart';
import 'package:gida_koruyucu/data/models/product_category.dart';
import 'package:gida_koruyucu/data/models/product_status.dart';
import 'package:gida_koruyucu/data/models/user_stats.dart';
import 'package:gida_koruyucu/core/utils/storage_utils.dart';

void main() {
  setUpAll(() async {
    // Test ortamında Hive.init() kullan
    Hive.init('test_hive');
    Hive.registerAdapter(ProductAdapter());
    Hive.registerAdapter(ProductCategoryAdapter());
    Hive.registerAdapter(ProductStatusAdapter());
    Hive.registerAdapter(UserStatsAdapter());
  });

  setUp(() async {
    // Test için gerekli box'ları aç
    await Hive.openBox('products');
    await Hive.openBox('user_stats');
    await Hive.openBox('settings');
  });

  tearDown(() async {
    // Test sonrası box'ları temizle
    await Hive.box('products').clear();
    await Hive.box('user_stats').clear();
    await Hive.box('settings').clear();
  });

  testWidgets('App başlatılabilmeli', (WidgetTester tester) async {
    // App'i build et
    await tester.pumpWidget(
      const ProviderScope(
        child: GidaKoruyucuApp(),
      ),
    );

    // App'in başlatıldığını kontrol et
    expect(find.byType(MaterialApp), findsOneWidget);
  });

  testWidgets('Product model - remainingDays hesaplama', (WidgetTester tester) async {
    final now = DateTime.now();
    final expiry = now.add(const Duration(days: 5));
    final product = Product(
      id: 'test',
      name: 'Test',
      expiryDate: expiry,
      category: ProductCategory.other,
      createdAt: now,
    );

    // Zaman farkı nedeniyle 4 veya 5 olabilir
    expect(product.remainingDays, greaterThanOrEqualTo(4));
    expect(product.remainingDays, lessThanOrEqualTo(5));
  });

  testWidgets('Product model - statusColor kontrolü', (WidgetTester tester) async {
    // Danger durumu
    final dangerProduct = Product(
      id: 'danger',
      name: 'Danger',
      expiryDate: DateTime.now().subtract(const Duration(days: 1)),
      category: ProductCategory.other,
      createdAt: DateTime.now().subtract(const Duration(days: 10)),
    );
    expect(dangerProduct.statusColor, 'danger');

    // Warning durumu (3-7 gün arası)
    final warningProduct = Product(
      id: 'warning',
      name: 'Warning',
      expiryDate: DateTime.now().add(const Duration(days: 5)),
      category: ProductCategory.other,
      createdAt: DateTime.now(),
    );
    expect(warningProduct.statusColor, 'warning');

    // Success durumu
    final successProduct = Product(
      id: 'success',
      name: 'Success',
      expiryDate: DateTime.now().add(const Duration(days: 10)),
      category: ProductCategory.other,
      createdAt: DateTime.now(),
    );
    expect(successProduct.statusColor, 'success');
  });
}
