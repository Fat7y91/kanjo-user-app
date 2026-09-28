import 'dart:io';

import 'package:fpdart/fpdart.dart';

import '../../../../../../core/errors/failure.dart';
import '../../../../../../core/use_cases/use_case.dart';
import '../../data/models/upload_file_model.dart';
import '../repositories/upload_file_repo.dart';

class UploadFileUseCase extends UseCaseParam<UploadFileModel, File> {
  final UploadFileRepo _uploadFileRepo;

  UploadFileUseCase(this._uploadFileRepo);

  @override
  Future<Either<Failure, UploadFileModel>> call(File param) {
    return _uploadFileRepo.uploadFile(param);
  }
}
