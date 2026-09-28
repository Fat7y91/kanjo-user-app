import 'package:fpdart/fpdart.dart';

import '../errors/failure.dart';

abstract class UseCase {}

abstract class UseCaseParam<Type, Param> extends UseCase {
  Future<Either<Failure, Type>> call(Param param);
}

abstract class UseCaseNoParam<Type> extends UseCase {
  Future<Either<Failure, Type>> call();
}
