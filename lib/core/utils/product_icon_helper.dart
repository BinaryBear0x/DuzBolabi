import 'package:flutter/material.dart';
import '../../data/models/product_category.dart';

class ProductIconHelper {
  static String getIconPath(ProductCategory category) {
    switch (category) {
      case ProductCategory.fruitVeg:
        return 'assets/icons/apple.png';
      case ProductCategory.dairy:
        return 'assets/icons/milk.png';
      case ProductCategory.meat:
        return 'assets/icons/meat.png';
      case ProductCategory.packaged:
        return 'assets/icons/egg.png';
      case ProductCategory.frozen:
        return 'assets/icons/vegetable.png';
      case ProductCategory.other:
        return 'assets/icons/egg.png';
    }
  }

  static IconData getFallbackIcon(ProductCategory category) {
    switch (category) {
      case ProductCategory.fruitVeg:
        return Icons.apple;
      case ProductCategory.dairy:
        return Icons.local_drink;
      case ProductCategory.meat:
        return Icons.set_meal;
      case ProductCategory.packaged:
        return Icons.inventory_2;
      case ProductCategory.frozen:
        return Icons.ac_unit;
      case ProductCategory.other:
        return Icons.shopping_bag;
    }
  }
}

