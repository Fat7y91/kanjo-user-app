import 'home_category_entity.dart';
import 'home_place_entity.dart';
import 'home_promo_entity.dart';

class HomeSectionsContentEntity {
  final List<HomeCategoryEntity> categories;
  final List<HomePlaceEntity> places;
  final List<HomePromoEntity> promos;

  const HomeSectionsContentEntity({
    required this.categories,
    required this.places,
    required this.promos,
  });
}

