import 'package:hive/hive.dart';

part 'product_status.g.dart';

@HiveType(typeId: 2)
enum ProductStatus {
  @HiveField(0)
  added,
  @HiveField(1)
  consumed,
  @HiveField(2)
  trashed;

  String get displayName {
    switch (this) {
      case ProductStatus.added:
        return 'Eklendi';
      case ProductStatus.consumed:
        return 'Tüketildi';
      case ProductStatus.trashed:
        return 'Çöpe Gitti';
    }
  }
}

