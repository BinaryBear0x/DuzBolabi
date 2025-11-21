import 'package:hive/hive.dart';
import 'product_category.dart';
import 'product_status.dart';

part 'product.g.dart';

@HiveType(typeId: 0)
class Product extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String name;

  @HiveField(2)
  final DateTime expiryDate;

  @HiveField(3)
  final ProductCategory category;

  @HiveField(4)
  ProductStatus status;

  @HiveField(5)
  final DateTime createdAt;

  @HiveField(6)
  DateTime? consumedAt;

  @HiveField(7)
  DateTime? trashedAt;

  Product({
    required this.id,
    required this.name,
    required this.expiryDate,
    required this.category,
    this.status = ProductStatus.added,
    required this.createdAt,
    this.consumedAt,
    this.trashedAt,
  });

  int get remainingDays {
    final now = DateTime.now();
    final difference = expiryDate.difference(now);
    return difference.inDays;
  }

  String get statusColor {
    if (status == ProductStatus.consumed) return 'success';
    if (status == ProductStatus.trashed) return 'danger';
    
    if (remainingDays > 7) return 'success';
    if (remainingDays >= 3) return 'warning';
    return 'danger';
  }

  Product copyWith({
    String? id,
    String? name,
    DateTime? expiryDate,
    ProductCategory? category,
    ProductStatus? status,
    DateTime? createdAt,
    DateTime? consumedAt,
    DateTime? trashedAt,
  }) {
    return Product(
      id: id ?? this.id,
      name: name ?? this.name,
      expiryDate: expiryDate ?? this.expiryDate,
      category: category ?? this.category,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      consumedAt: consumedAt ?? this.consumedAt,
      trashedAt: trashedAt ?? this.trashedAt,
    );
  }
}

