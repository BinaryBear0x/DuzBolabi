class AppConstants {
  // Gamification points (eski sistem - uyumluluk için)
  static const int pointsConsumedBeforeExpiry = 10;
  static const int pointsTrashedAfterExpiry = -5;

  // Gamification XP (yeni sistem)
  static const int xpProductConsumed = 20; // Ürün tüketildiğinde +20 XP
  static const int xpProductTrashed = -10; // Ürün çöpe atıldığında -10 XP

  // Notification days
  static const int notificationDays7 = 7;
  static const int notificationDays3 = 3;
  static const int notificationDays1 = 1;

  // Status thresholds
  static const int statusGreenDays = 7;
  static const int statusYellowDays = 3;

  // Level calculation
  static const int pointsPerLevel = 100;
  static const int xpPerLevel = 1000; // Her level 1000 XP
}

