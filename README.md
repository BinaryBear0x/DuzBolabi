# Gıda Koruyucu - STT Takip ve Oyunlaştırma

Flutter ile geliştirilmiş, gıda ürünlerinin son tüketim tarihlerini takip eden ve oyunlaştırma özellikleri sunan mobil uygulama.

## Kurulum

1. Flutter SDK'nın kurulu olduğundan emin olun:
   ```bash
   flutter --version
   flutter doctor
   ```

2. Bağımlılıkları yükleyin:
   ```bash
   flutter pub get
   ```

3. Hive adapterlerini oluşturun:
   ```bash
   flutter pub run build_runner build
   ```

4. Uygulamayı çalıştırın:
   ```bash
   flutter run
   ```

## Teknoloji Stack

- **Framework**: Flutter
- **State Management**: Riverpod
- **Routing**: go_router
- **Local Database**: Hive
- **Notifications**: flutter_local_notifications + timezone
- **Charts**: fl_chart
- **Animations**: Lottie

