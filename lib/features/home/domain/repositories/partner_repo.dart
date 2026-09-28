import 'package:heraj/features/home/domain/entities/partners.dart';
import 'package:heraj/features/home/domain/entities/testimonials.dart';
import 'package:fpdart/fpdart.dart';
import '../../../../core/errors/failure.dart';

abstract class PartnerRepo {
  Future<Either<Failure, List<Partner>>> getPartners();
  Future<Either<Failure, List<Testimonials>>> getTestimonials();
}