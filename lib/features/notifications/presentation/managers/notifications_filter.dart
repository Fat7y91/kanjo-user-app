import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

enum NotificationFilterType {
  all(null),
  seen(1),
  unseen(0);

  const NotificationFilterType(this.key);

  final int? key;
}

final notificationsProvider = StateNotifierProvider.autoDispose<
    NotificationFilterNotifier, Map<String, dynamic>>((ref) {
  return NotificationFilterNotifier();
});

class NotificationFilterNotifier extends StateNotifier<Map<String, dynamic>> {
  NotificationFilterNotifier() : super({'status': null});

  void updateStatus(NotificationFilterType type) {
    _updateState({...state, 'status': type.key});
  }

  void _updateState(Map<String, dynamic> newState) {
    if (!mapEquals(state, newState)) {
      state = newState;
    }
  }
}
