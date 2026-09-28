import 'package:fpdart/fpdart.dart';

import '../../../../../core/errors/failure.dart';

abstract class UpdateProfileRepo {
  Future<Either<Failure, String>> updateProfile(Map<String, dynamic> data);
}
