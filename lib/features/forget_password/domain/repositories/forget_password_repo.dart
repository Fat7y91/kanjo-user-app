import 'package:fpdart/fpdart.dart';

import '../../../../../core/errors/failure.dart';


abstract class ForgetPasswordRepo {
  String get code;

  String get sendTo;

  Future<Either<Failure, bool>> resetPassword({required String password});
}
