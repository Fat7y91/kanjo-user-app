import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:heraj/features/settings/data/models/settings_model.dart';
import 'package:heraj/features/settings/domain/use_case/fetch_settings_use_case.dart';
import '../../../../main.dart';

/// Cached for the app session (used by splash GIF and later screens).
final appSettingsProvider = StateProvider<SettingsModel?>((ref) => null);

final fetchSettingsProvider = FutureProvider<SettingsModel>((ref) async {
  final res = await getIt<FetchSettingsUseCase>().call();
  final settings = res.fold((l) => throw l, (r) => r);
  ref.read(appSettingsProvider.notifier).state = settings;
  return settings;
});
