import 'package:flutter_riverpod/flutter_riverpod.dart';

class SelectedSkinNotifier extends Notifier<String> {
  @override
  String build() {
    return 'default';
  }

  void setSkin(String skin) {
    state = skin;
  }
}

class PurchasedStickersNotifier extends Notifier<List<String>> {
  @override
  List<String> build() {
    return [];
  }

  void addSticker(String stickerId) {
    if (!state.contains(stickerId)) {
      state = [...state, stickerId];
    }
  }
}

final selectedSkinProvider = NotifierProvider<SelectedSkinNotifier, String>(() {
  return SelectedSkinNotifier();
});

final purchasedStickersProvider = NotifierProvider<PurchasedStickersNotifier, List<String>>(() {
  return PurchasedStickersNotifier();
});
