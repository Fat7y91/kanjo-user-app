import 'dart:io';

import 'package:dio/dio.dart';
import 'package:fpdart/fpdart.dart';

import '../../../../../core/errors/failure.dart';
import '../../domain/repositories/upload_file_repo.dart';
import '../data_sources/upload_file_data_source.dart';
import '../models/upload_file_model.dart';

class UploadFileRepoImpl extends UploadFileRepo {
  final UploadFileDataSource uploadFileDataSource;

  UploadFileRepoImpl(this.uploadFileDataSource);

  @override
  Future<Either<Failure, UploadFileModel>> uploadFile(File file) async {
    try {
      final response = await uploadFileDataSource.uploadFile(file);
      return Right(response);
    } catch (e) {
      if (e is DioException) {
        return Left(ServerFailure.fromDioError(e));
      }
      return Left(GeneralError(e));
    }
  }
}
