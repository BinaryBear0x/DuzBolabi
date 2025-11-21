import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../../data/models/product.dart';

final onboardingCompletedProvider = NotifierProvider<OnboardingNotifier, bool>(() {
  return OnboardingNotifier();
});

final isAuthenticatedProvider = NotifierProvider<AuthNotifier, bool>(() {
  return AuthNotifier();
});

class OnboardingNotifier extends Notifier<bool> {
  late final Box _box;

  static bool _getOnboardingStatus() {
    try {
      final box = Hive.box('settings');
      return box.get('onboarding_completed', defaultValue: false) as bool;
    } catch (e) {
      return false;
    }
  }

  @override
  bool build() {
    _box = Hive.box('settings');
    return _getOnboardingStatus();
  }

  Future<void> setCompleted(bool value) async {
    await _box.put('onboarding_completed', value);
    state = value;
  }
}

class AuthNotifier extends Notifier<bool> {
  late final Box _box;

  static bool _getAuthStatus() {
    try {
      final box = Hive.box('settings');
      return box.get('is_authenticated', defaultValue: false) as bool;
    } catch (e) {
      return false;
    }
  }

  @override
  bool build() {
    _box = Hive.box('settings');
    return _getAuthStatus();
  }

  Future<void> setAuthenticated(bool value) async {
    await _box.put('is_authenticated', value);
    state = value;
  }
}

class StorageUtils {
  static Future<void> init() async {
    // Products box'ını doğru tipte aç
    // Eğer zaten açıksa ve yanlış tipte açılmışsa, kapatıp tekrar aç
    try {
      if (Hive.isBoxOpen('products')) {
        try {
          // Box<Product> olarak erişmeyi dene
          final box = Hive.box<Product>('products');
          // Eğer bu satıra geldiysek, box doğru tipte açılmış
        } catch (e) {
          // Box yanlış tipte açılmış, kapatıp tekrar aç
          await Hive.box('products').close();
          await Hive.openBox<Product>('products');
        }
      } else {
        await Hive.openBox<Product>('products');
      }
    } catch (e) {
      // Hata durumunda box'ı kapatıp tekrar aç
      try {
        if (Hive.isBoxOpen('products')) {
          await Hive.box('products').close();
        }
      } catch (_) {}
      await Hive.openBox<Product>('products');
    }
    
    // User stats box'ını aç
    if (!Hive.isBoxOpen('user_stats')) {
      try {
        await Hive.openBox('user_stats');
      } catch (e) {
        // Box açma hatası - eski format sorunu olabilir
        // Box'ı kapatıp yeniden açmayı dene
        try {
          if (Hive.isBoxOpen('user_stats')) {
            await Hive.box('user_stats').close();
          }
        } catch (_) {}
        // Yeniden aç
        await Hive.openBox('user_stats');
      }
    }
    
    // Settings box'ını aç
    if (!Hive.isBoxOpen('settings')) {
      await Hive.openBox('settings');
    }
  }

  static Future<void> setOnboardingCompleted(bool value) async {
    final box = Hive.box('settings');
    await box.put('onboarding_completed', value);
  }

  static Future<void> setAuthenticated(bool value) async {
    final box = Hive.box('settings');
    await box.put('is_authenticated', value);
  }
}

