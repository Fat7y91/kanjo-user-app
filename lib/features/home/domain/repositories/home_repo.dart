import 'package:fpdart/fpdart.dart';
import 'package:heraj/core/errors/failure.dart';
import '../entities/home_sections_content_entity.dart';

abstract class HomeRepository {
  Future<Either<Failure,HomeSectionsContentEntity>> getHomeSectionsContent();
}

