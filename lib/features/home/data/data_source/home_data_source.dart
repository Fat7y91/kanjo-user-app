import 'package:heraj/config/app_assets.dart';
import '../../domain/entities/home_category_entity.dart';
import '../../domain/entities/home_place_entity.dart';
import '../../domain/entities/home_promo_entity.dart';
import '../../domain/entities/home_sections_content_entity.dart';

abstract class HomeDataSource {
  Future<HomeSectionsContentEntity> getHomeSectionsContent();
}

class HomeDummyDataSourceImpl implements HomeDataSource {
  @override
  Future<HomeSectionsContentEntity> getHomeSectionsContent() async {
    await Future.delayed(Duration(seconds: 1));
    return HomeSectionsContentEntity(
      categories: const [
        HomeCategoryEntity(
          id: 'cat_food',
          title: 'Food',
          imagePath: AppAssets.homeCategoryFood,
        ),
        HomeCategoryEntity(
          id: 'cat_grocery',
          title: 'Grocery',
          imagePath: AppAssets.homeCategoryGrocery,
        ),
        HomeCategoryEntity(
          id: 'cat_pharmacy',
          title: 'Pharmacy',
          imagePath: AppAssets.homeCategoryPharmacy,
        ),
        HomeCategoryEntity(
          id: 'cat_services',
          title: 'Services',
          imagePath: AppAssets.homeCategoryServices,
        ),
      ],
      places: const [
        HomePlaceEntity(
          id: 'place_1',
          title: 'Starbucks',
          imagePath: AppAssets.homeCategoryFood,
          rating: 4.8,
          reviewsCount: 30,
          distanceText: '13 km',
        ),
        HomePlaceEntity(
          id: 'place_2',
          title: 'McDonalds',
          imagePath: AppAssets.homeCategoryGrocery,
          rating: 4.7,
          reviewsCount: 25,
          distanceText: '9 km',
        ),
        HomePlaceEntity(
          id: 'place_3',
          title: 'Burger House',
          imagePath: AppAssets.homeCategoryFood,
          rating: 4.6,
          reviewsCount: 42,
          distanceText: '11 km',
        ),
      ],
      promos: const [
        HomePromoEntity(
          id: 'promo_1',
          imagePath: AppAssets.offerItem,
        ),
        HomePromoEntity(
          id: 'promo_2',
          imagePath: AppAssets.offerItem,
        ),
      ],
    );
  }
}

