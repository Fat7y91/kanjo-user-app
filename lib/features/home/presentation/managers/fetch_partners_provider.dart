import 'package:heraj/features/home/domain/entities/partners.dart';
import 'package:heraj/features/home/domain/entities/testimonials.dart';
import 'package:heraj/features/home/domain/use_case/fetch_partner_use_case.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../main.dart';

final fetchPartnersProvider = FutureProvider.autoDispose<List<Partner>>((ref) async {
  final partners = await getIt<FetchPartnersUseCase>().call();

  return partners.fold((l) {
    throw l;
  }, (r) {
    return r;
  });
});

final fetchTestimonialsProvider = FutureProvider.autoDispose<List<Testimonials>>((ref) async {
  final testimonials = await getIt<FetchTestimonialsUseCase>().call();

  return testimonials.fold((l) {
    throw l;
  }, (r) {
    return r;
  });
});