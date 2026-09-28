import 'package:heraj/config/api_path.dart';
import 'package:heraj/core/service/webservice/dio_helper.dart';

import '../models/settings_model.dart';

abstract class SettingsDataSource {
  Future<SettingsModel> getSettings();
}

class SettingsDataSourceImpl extends SettingsDataSource {
  final ApiService apiService;

  SettingsDataSourceImpl({required this.apiService});

  @override
  Future<SettingsModel> getSettings() async {
    final res = await apiService.get(
      url: ApiPath.settings,
      returnDataOnly: true,
    );
    return SettingsModel.fromJson(
      Map<String, dynamic>.from(res as Map),
    );
  }
}
