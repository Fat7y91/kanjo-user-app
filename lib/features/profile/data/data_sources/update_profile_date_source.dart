import 'dart:io';

import 'package:dio/dio.dart';
import 'package:path/path.dart' as path;

import '../../../../../config/api_path.dart';
import '../../../../../core/service/webservice/dio_helper.dart';

abstract class UpdateProfileDataSource {
  Future<String> updateProfile(Map<String, dynamic> data);
}

class UpdateProfileDataSourceImpl extends UpdateProfileDataSource {
  final ApiService apiService;

  UpdateProfileDataSourceImpl(this.apiService);

  @override
  Future<String> updateProfile(Map<String, dynamic> data) async {
    final formMap = <String, dynamic>{
      '_method': 'PUT',
    };

    for (final key in [
      'name',
      'email',
      'phone',
      'password',
      'birthdate',
      'gender',
    ]) {
      final value = data[key];
      if (value == null) continue;
      if (value is String && value.isEmpty) continue;
      formMap[key] = value;
    }

    final imageValue =
        data['profile_image'] ?? data['image'] ?? data['avatar'];
    if (imageValue is File) {
      formMap['profile_image'] = await MultipartFile.fromFile(
        imageValue.path,
        filename: path.basename(imageValue.path),
      );
    }

    final res = await apiService.post(
      url: ApiPath.updateProfile,
      requestBody: FormData.fromMap(formMap),
      returnDataOnly: false,
      receiveTimeout: const Duration(seconds: 60),
      sendTimeOut: const Duration(seconds: 60),
    );

    return res['message']?.toString() ?? 'Profile updated successfully';
  }
}
