import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/service/local_data_manager.dart';

final notificationsEnabledProvider = StateProvider<bool>((ref) {
  return dataManager.notificationEnabled();
});
