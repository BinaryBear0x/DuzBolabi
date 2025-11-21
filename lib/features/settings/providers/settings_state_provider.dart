import 'package:flutter_riverpod/flutter_riverpod.dart';

// Notification enabled state
class NotificationsEnabledNotifier extends Notifier<bool> {
  @override
  bool build() => true;
}

final notificationsEnabledProvider = NotifierProvider<NotificationsEnabledNotifier, bool>(() {
  return NotificationsEnabledNotifier();
});

