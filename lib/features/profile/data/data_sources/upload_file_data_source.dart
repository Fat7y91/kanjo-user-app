import 'dart:io';
import 'package:dio/dio.dart';
import '../../../../../config/api_path.dart';
import '../../../../../core/service/webservice/dio_helper.dart';
import '../models/upload_file_model.dart';

abstract class UploadFileDataSource {
  Future<UploadFileModel> uploadFile(File file);
}

class UploadFileDataSourceImpl implements UploadFileDataSource {
  final ApiService _apiService;

  UploadFileDataSourceImpl(this._apiService);

  @override
  Future<UploadFileModel> uploadFile(File file) async {
    final res = await _apiService.post(
      url: ApiPath.uploadImage,
      receiveTimeout: null,
      sendTimeOut: null,
      returnDataOnly: true,
      requestBody: FormData.fromMap({
        'images': await MultipartFile.fromFile(file.path),
      }),
    );

    // Handle response structure: {"images": ["url1", "url2", ...]}
    final list = res["images"] as List?;
    if (list == null || list.isEmpty) {
      throw Exception('No images returned from server');
    }

    // Get the first image URL
    final imageUrl = list.first?.toString();
    if (imageUrl == null || imageUrl.isEmpty) {
      throw Exception('Invalid image URL returned from server');
    }

    return UploadFileModel(filePath: imageUrl);
  }
}
