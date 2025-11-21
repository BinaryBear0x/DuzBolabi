import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:intl/date_symbol_data_local.dart';
import 'app/app.dart';
import 'data/models/product.dart';
import 'data/models/product_category.dart';
import 'data/models/product_status.dart';
import 'data/models/user_stats.dart';
import 'data/models/skin_item.dart';
import 'data/models/sticker_item.dart';
import 'data/models/shop_package.dart';
import 'core/utils/storage_utils.dart';
import 'core/services/notification_service.dart';
import 'data/repositories/user_stats_repository.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Hive
  await Hive.initFlutter();
  
  // Register Hive adapters
  Hive.registerAdapter(ProductAdapter());
  Hive.registerAdapter(ProductCategoryAdapter());
  Hive.registerAdapter(ProductStatusAdapter());
  Hive.registerAdapter(UserStatsAdapter());
  Hive.registerAdapter(SkinItemAdapter());
  Hive.registerAdapter(StickerItemAdapter());
  Hive.registerAdapter(ShopPackageAdapter());
  
  // Initialize timezone
  tz.initializeTimeZones();
  
  // Initialize intl locale data for Turkish
  await initializeDateFormatting('tr_TR', null);
  
  // Initialize storage
  await StorageUtils.init();
  
  // Initialize notifications
  await NotificationService.initialize();
  
  // Kullanıcıya başlangıç bonusu: 1000 coin ekle
  try {
    final statsRepository = UserStatsRepository();
    await statsRepository.addCoin(1000);
  } catch (e) {
    // Hata olsa bile uygulama çalışmaya devam etsin
    debugPrint('Coin ekleme hatası: $e');
  }
  
  runApp(
    const ProviderScope(
      child: GidaKoruyucuApp(),
    ),
  );
}

