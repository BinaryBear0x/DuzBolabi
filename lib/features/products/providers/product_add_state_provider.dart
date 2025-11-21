import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/models/product_category.dart';

// Product add screen state
class ProductAddDateNotifier extends Notifier<DateTime?> {
  @override
  DateTime? build() => null;
}

final productAddDateProvider = NotifierProvider<ProductAddDateNotifier, DateTime?>(() {
  return ProductAddDateNotifier();
});

class ProductAddCategoryNotifier extends Notifier<ProductCategory> {
  @override
  ProductCategory build() => ProductCategory.other;
}

final productAddCategoryProvider = NotifierProvider<ProductAddCategoryNotifier, ProductCategory>(() {
  return ProductAddCategoryNotifier();
});

class ProductAddSavingNotifier extends Notifier<bool> {
  @override
  bool build() => false;
}

final productAddSavingProvider = NotifierProvider<ProductAddSavingNotifier, bool>(() {
  return ProductAddSavingNotifier();
});

