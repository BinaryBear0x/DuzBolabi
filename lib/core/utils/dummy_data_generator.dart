import 'package:uuid/uuid.dart';
import '../../data/models/product.dart';
import '../../data/models/product_category.dart';
import '../../data/models/product_status.dart';
import '../../data/repositories/product_repository.dart';
import '../../data/repositories/user_stats_repository.dart';

class DummyDataGenerator {
  static const _uuid = Uuid();
  
  // Türkçe ürün isimleri
  static final List<String> _productNames = [
    // Süt Ürünleri
    'Süt', 'Yoğurt', 'Peynir', 'Tereyağı', 'Kaşar Peyniri', 'Lor Peyniri', 'Krem Peynir',
    // Et & Tavuk
    'Tavuk Göğsü', 'Kıyma', 'Kuzu Eti', 'Dana Eti', 'Tavuk But', 'Hindi', 'Sucuk',
    // Meyve & Sebze
    'Elma', 'Muz', 'Portakal', 'Domates', 'Salatalık', 'Biber', 'Patlıcan', 'Soğan', 'Havuç', 'Brokoli',
    // Paketli Gıda
    'Makarna', 'Pirinç', 'Un', 'Şeker', 'Tuz', 'Zeytinyağı', 'Ayçiçek Yağı', 'Bal', 'Reçel',
    // Dondurulmuş
    'Dondurma', 'Dondurulmuş Sebze', 'Dondurulmuş Et', 'Dondurulmuş Balık',
    // Diğer
    'Ekmek', 'Yumurta', 'Çay', 'Kahve', 'Bisküvi', 'Çikolata',
  ];
  
  static final Map<ProductCategory, List<String>> _categoryProducts = {
    ProductCategory.dairy: ['Süt', 'Yoğurt', 'Peynir', 'Tereyağı', 'Kaşar Peyniri', 'Lor Peyniri', 'Krem Peynir'],
    ProductCategory.meat: ['Tavuk Göğsü', 'Kıyma', 'Kuzu Eti', 'Dana Eti', 'Tavuk But', 'Hindi', 'Sucuk'],
    ProductCategory.fruitVeg: ['Elma', 'Muz', 'Portakal', 'Domates', 'Salatalık', 'Biber', 'Patlıcan', 'Soğan', 'Havuç', 'Brokoli'],
    ProductCategory.packaged: ['Makarna', 'Pirinç', 'Un', 'Şeker', 'Tuz', 'Zeytinyağı', 'Ayçiçek Yağı', 'Bal', 'Reçel'],
    ProductCategory.frozen: ['Dondurma', 'Dondurulmuş Sebze', 'Dondurulmuş Et', 'Dondurulmuş Balık'],
    ProductCategory.other: ['Ekmek', 'Yumurta', 'Çay', 'Kahve', 'Bisküvi', 'Çikolata'],
  };

  /// Tüm verileri sil ve 3 haftalık sahte veri oluştur
  static Future<void> generateDummyData(
    ProductRepository productRepository,
    UserStatsRepository statsRepository,
  ) async {
    // Tüm ürünleri sil
    await productRepository.deleteAllProducts();
    
    // User stats'i sıfırla
    final stats = await statsRepository.getUserStats();
    stats.totalAdded = 0;
    stats.totalConsumed = 0;
    stats.totalTrashed = 0;
    stats.totalPoints = 0;
    await statsRepository.updateUserStats(stats);
    
    final now = DateTime.now();
    final products = <Product>[];
    
    // 3 hafta geriye git (21 gün)
    for (int weekOffset = 2; weekOffset >= 0; weekOffset--) {
      final weekStart = now.subtract(Duration(days: (weekOffset * 7) + (now.weekday - 1)));
      final weekStartOfDay = DateTime(weekStart.year, weekStart.month, weekStart.day);
      
      // Her hafta için 15-25 arası ürün oluştur
      final productsPerWeek = 15 + (weekOffset * 3); // İlk hafta 15, son hafta 21
      
      for (int i = 0; i < productsPerWeek; i++) {
        final dayOffset = i % 7; // Hafta içinde gün
        final createdAt = weekStartOfDay.add(Duration(days: dayOffset, hours: 8 + (i % 12)));
        
        // Rastgele kategori seç
        final category = ProductCategory.values[i % ProductCategory.values.length];
        final categoryProducts = _categoryProducts[category] ?? _productNames;
        final productName = categoryProducts[i % categoryProducts.length];
        
        // Rastgele expiry date (3-30 gün arası)
        final expiryDays = 3 + (i % 28);
        final expiryDate = createdAt.add(Duration(days: expiryDays));
        
        // Status belirleme: %60 tüketildi, %20 çöpe gitti, %20 bekliyor
        final statusRand = i % 10;
        ProductStatus status;
        DateTime? consumedAt;
        DateTime? trashedAt;
        
        if (statusRand < 6) {
          // Tüketildi
          status = ProductStatus.consumed;
          final consumedDayOffset = dayOffset + 1 + (i % 3); // 1-3 gün sonra tüketildi
          consumedAt = createdAt.add(Duration(days: consumedDayOffset, hours: 12 + (i % 8)));
        } else if (statusRand < 8) {
          // Çöpe gitti
          status = ProductStatus.trashed;
          final trashedDayOffset = dayOffset + 2 + (i % 4); // 2-5 gün sonra çöpe gitti
          trashedAt = createdAt.add(Duration(days: trashedDayOffset, hours: 14 + (i % 6)));
        } else {
          // Bekliyor (added)
          status = ProductStatus.added;
        }
        
        final product = Product(
          id: _uuid.v4(),
          name: productName,
          expiryDate: expiryDate,
          category: category,
          status: status,
          createdAt: createdAt,
          consumedAt: consumedAt,
          trashedAt: trashedAt,
        );
        
        products.add(product);
      }
    }
    
    // Tüm ürünleri ekle
    for (final product in products) {
      await productRepository.addProduct(product);
    }
  }
}

