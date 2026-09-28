import 'package:heraj/features/home/domain/entities/partners.dart';
import 'package:heraj/features/home/domain/entities/testimonials.dart';
import 'package:heraj/features/home/domain/repositories/partner_repo.dart';
import 'package:fpdart/fpdart.dart';
import '../../../../core/errors/failure.dart';
import '../../../../core/use_cases/use_case.dart';

class FetchPartnersUseCase extends UseCaseNoParam<List<Partner>> {
  final PartnerRepo partnerRepo;

  FetchPartnersUseCase({required this.partnerRepo});

  @override
  Future<Either<Failure, List<Partner>>> call([void param]) async {
    final res = await partnerRepo.getPartners();
    return res;
  }
}

class FetchTestimonialsUseCase extends UseCaseNoParam<List<Testimonials>> {
  final PartnerRepo partnerRepo;

  FetchTestimonialsUseCase({required this.partnerRepo});

  @override
  Future<Either<Failure, List<Testimonials>>> call([void param]) async {
    final res = await partnerRepo.getTestimonials();
    return res;
  }
}
