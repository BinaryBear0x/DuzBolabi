import 'package:flutter_test/flutter_test.dart';
import 'package:gida_koruyucu/data/models/product.dart';
import 'package:gida_koruyucu/data/models/product_category.dart';
import 'package:gida_koruyucu/data/models/product_status.dart';

void main() {
  group('Product Model Tests', () {
    test('remainingDays - kalan gün hesaplanmalı', () {
      final now = DateTime.now();
      final expiry = now.add(const Duration(days: 7));
      final product = Product(
        id: 'test-1',
        name: 'Test Ürün',
        expiryDate: expiry,
        category: ProductCategory.other,
        createdAt: now,
      );

      // Zaman farkı nedeniyle 6 veya 7 olabilir
      expect(product.remainingDays, greaterThanOrEqualTo(6));
      expect(product.remainingDays, lessThanOrEqualTo(7));
    });

    test('remainingDays - geçmiş tarih negatif olmalı', () {
      final now = DateTime.now();
      final product = Product(
        id: 'test-2',
        name: 'Test Ürün',
        expiryDate: now.subtract(const Duration(days: 3)),
        category: ProductCategory.other,
        createdAt: now.subtract(const Duration(days: 10)),
      );

      expect(product.remainingDays, lessThan(0));
    });

    test('statusColor - danger durumu kırmızı olmalı', () {
      final product = Product(
        id: 'test-3',
        name: 'Test Ürün',
        expiryDate: DateTime.now().subtract(const Duration(days: 1)),
        category: ProductCategory.other,
        createdAt: DateTime.now().subtract(const Duration(days: 10)),
      );

      expect(product.statusColor, 'danger');
    });

    test('statusColor - warning durumu sarı olmalı', () {
      final product = Product(
        id: 'test-4',
        name: 'Test Ürün',
        expiryDate: DateTime.now().add(const Duration(days: 5)), // 5 gün = warning (3-7 arası)
        category: ProductCategory.other,
        createdAt: DateTime.now(),
      );

      expect(product.statusColor, 'warning');
    });

    test('statusColor - success durumu yeşil olmalı', () {
      final product = Product(
        id: 'test-5',
        name: 'Test Ürün',
        expiryDate: DateTime.now().add(const Duration(days: 10)),
        category: ProductCategory.other,
        createdAt: DateTime.now(),
      );

      expect(product.statusColor, 'success');
    });

    test('Product - default status added olmalı', () {
      final product = Product(
        id: 'test-6',
        name: 'Test Ürün',
        expiryDate: DateTime.now().add(const Duration(days: 5)),
        category: ProductCategory.other,
        createdAt: DateTime.now(),
      );

      expect(product.status, ProductStatus.added);
    });

    test('Product - consumed status consumedAt set edilmeli', () {
      final product = Product(
        id: 'test-7',
        name: 'Test Ürün',
        expiryDate: DateTime.now().add(const Duration(days: 5)),
        category: ProductCategory.other,
        createdAt: DateTime.now(),
      );

      product.status = ProductStatus.consumed;
      product.consumedAt = DateTime.now();

      expect(product.status, ProductStatus.consumed);
      expect(product.consumedAt, isNotNull);
    });
  });
}

