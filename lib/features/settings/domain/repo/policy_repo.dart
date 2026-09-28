import 'package:fpdart/fpdart.dart';
import '../../../../../core/errors/failure.dart';
import '../entities/message_entity.dart';

abstract class PrivacyPolicyRepo {
  Future<Either<Failure, Message>> getPolicy();
  Future<Either<Failure, Message>> getWhoAreWe();
}
