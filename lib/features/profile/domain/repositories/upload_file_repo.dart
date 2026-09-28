import 'dart:io';

import 'package:fpdart/fpdart.dart';

import '../../../../../../core/errors/failure.dart';
import '../../data/models/upload_file_model.dart';

abstract class UploadFileRepo {
  Future<Either<Failure, UploadFileModel>> uploadFile(File file);
}
