import 'package:flutter_test/flutter_test.dart';

// Tüm test dosyalarını import et
import 'product_repository_test.dart' as product_repo_test;
import 'user_stats_repository_test.dart' as user_stats_test;
import 'gamification_service_test.dart' as gamification_test;
import 'product_model_test.dart' as product_model_test;
import 'integration_test.dart' as integration_test;

void main() {
  group('Tüm Testler', () {
    test('Product Repository Testleri', () {
      product_repo_test.main();
    });

    test('User Stats Repository Testleri', () {
      user_stats_test.main();
    });

    test('Gamification Service Testleri', () {
      gamification_test.main();
    });

    test('Product Model Testleri', () {
      product_model_test.main();
    });

    test('Integration Testleri', () {
      integration_test.main();
    });
  });
}

