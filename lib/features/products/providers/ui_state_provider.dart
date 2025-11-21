import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/models/product_category.dart';

// Search query state
class SearchQueryNotifier extends Notifier<String> {
  @override
  String build() => '';
}

final searchQueryProvider = NotifierProvider<SearchQueryNotifier, String>(() {
  return SearchQueryNotifier();
});

// Selected category state
// null = Tümü, ProductCategory = kategori seçili, 'expired' = tarihi geçenler
class SelectedCategoryNotifier extends Notifier<ProductCategory?> {
  @override
  ProductCategory? build() => null;
  
  // Special filter için null değil ama özel bir durum olabilir
  // 'expired' durumu için String kullanabiliriz ama ProductCategory? ile yapalım
  // null = tümü, ProductCategory = kategori, 'expired' için özel kontrol
}

final selectedCategoryProvider = NotifierProvider<SelectedCategoryNotifier, ProductCategory?>(() {
  return SelectedCategoryNotifier();
});

// Tarihi geçenler filtresi (özel filter)
final showExpiredOnlyProvider = NotifierProvider<ShowExpiredOnlyNotifier, bool>(() {
  return ShowExpiredOnlyNotifier();
});

class ShowExpiredOnlyNotifier extends Notifier<bool> {
  @override
  bool build() => false;
  
  void setExpiredOnly(bool value) {
    state = value;
  }
}

