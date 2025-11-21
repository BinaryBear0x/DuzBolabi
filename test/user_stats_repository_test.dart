import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:gida_koruyucu/data/models/user_stats.dart';
import 'package:gida_koruyucu/data/repositories/user_stats_repository.dart';

void main() {
  late UserStatsRepository repository;
  late Box testBox;

  setUpAll(() async {
    // Test ortamında Hive.init() kullan (initFlutter değil)
    Hive.init('test_hive');
    Hive.registerAdapter(UserStatsAdapter());
  });

  setUp(() async {
    // Test için gerçek box'ı aç (UserStatsRepository bunu kullanıyor)
    testBox = await Hive.openBox('user_stats');
    repository = UserStatsRepository();
  });

  tearDown(() async {
    await testBox.clear();
    await testBox.close();
  });

  group('UserStatsRepository Tests', () {
    test('getUserStats - yeni stats oluşturulmalı', () async {
      final stats = await repository.getUserStats();

      expect(stats.totalAdded, 0);
      expect(stats.totalConsumed, 0);
      expect(stats.totalTrashed, 0);
      expect(stats.totalPoints, 0);
      expect(stats.currentLevel, 1);
    });

    test('incrementAdded - eklenen ürün sayısı artmalı', () async {
      await repository.incrementAdded();
      final stats = await repository.getUserStats();

      expect(stats.totalAdded, 1);
    });

    test('incrementConsumed - tüketilen ürün sayısı artmalı', () async {
      await repository.incrementConsumed();
      final stats = await repository.getUserStats();

      expect(stats.totalConsumed, 1);
    });

    test('incrementTrashed - çöpe giden ürün sayısı artmalı', () async {
      await repository.incrementTrashed();
      final stats = await repository.getUserStats();

      expect(stats.totalTrashed, 1);
    });

    test('addPoints - puan eklenmeli', () async {
      await repository.addPoints(50);
      final stats = await repository.getUserStats();

      expect(stats.totalPoints, 50);
    });

    test('addPoints - negatif puan eklenmemeli', () async {
      await repository.addPoints(30);
      await repository.addPoints(-50);
      final stats = await repository.getUserStats();

      expect(stats.totalPoints, 0); // Negatif olamaz
    });

    test('updateLevel - level güncellenmeli', () async {
      await repository.addPoints(150);
      final stats = await repository.getUserStats();

      expect(stats.currentLevel, 2); // 150 puan = level 2
    });

    test('multiple operations - çoklu işlemler çalışmalı', () async {
      await repository.incrementAdded();
      await repository.incrementAdded();
      await repository.incrementConsumed();
      await repository.addPoints(100);

      final stats = await repository.getUserStats();

      expect(stats.totalAdded, 2);
      expect(stats.totalConsumed, 1);
      expect(stats.totalTrashed, 0);
      expect(stats.totalPoints, 100);
      expect(stats.currentLevel, 2);
    });
  });
}

