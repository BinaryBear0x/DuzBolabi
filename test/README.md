# Test Dokümantasyonu

Bu klasörde projenin tüm özelliklerini test eden kapsamlı testler bulunmaktadır.

## Test Dosyaları

### 1. `product_repository_test.dart`
- Ürün ekleme
- Ürün güncelleme
- Ürün silme
- Aktif ürünleri listeleme
- Kategoriye göre filtreleme
- Arama işlevselliği

### 2. `user_stats_repository_test.dart`
- Kullanıcı istatistikleri oluşturma
- Eklenen ürün sayısı artırma
- Tüketilen ürün sayısı artırma
- Çöpe giden ürün sayısı artırma
- Puan ekleme
- Level güncelleme

### 3. `gamification_service_test.dart`
- Ürün ekleme puan sistemi
- Ürün tüketme puan sistemi
- Ürün çöpe atma puan sistemi
- Status değişikliği kontrolü

### 4. `product_model_test.dart`
- Kalan gün hesaplama
- Status renk hesaplama (danger/warning/success)
- Default status kontrolü
- Consumed status kontrolü

### 5. `integration_test.dart`
- Tam akış testleri
- Ürün ekleme ve listeleme akışı
- Ürün tüketme akışı
- Ürün çöpe atma akışı
- Arama ve filtreleme akışı
- Puan ve level sistemi akışı

### 6. `widget_test.dart`
- App başlatma testi
- Model testleri

## Test Çalıştırma

### Tüm testleri çalıştır:
```bash
flutter test
```

### Belirli bir test dosyasını çalıştır:
```bash
flutter test test/product_repository_test.dart
```

### Test coverage ile çalıştır:
```bash
flutter test --coverage
```

## Test Sonuçları

Testler şu özellikleri kontrol eder:
- ✅ Ürün CRUD işlemleri
- ✅ Kullanıcı istatistikleri
- ✅ Gamification sistemi
- ✅ Model validasyonları
- ✅ Tam entegrasyon akışları

## Notlar

- Testler için ayrı Hive box'ları kullanılır (test_products, test_user_stats)
- Her test sonrası box'lar temizlenir
- Zaman bazlı testlerde tolerans payı bırakılmıştır (remainingDays)

