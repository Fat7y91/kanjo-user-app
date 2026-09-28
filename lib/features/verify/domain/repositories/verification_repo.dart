import 'package:fpdart/fpdart.dart';

import '../../../../../core/errors/failure.dart';

abstract class VerificationRepo {
  String get title;

  String get type;

  String get sendTo;

  Future<Either<Failure, bool>> verify(String code,{String? emailOrPhone});

  Future<Either<Failure, bool>> resend();

  Future<Either<Failure, bool>> send();
}
