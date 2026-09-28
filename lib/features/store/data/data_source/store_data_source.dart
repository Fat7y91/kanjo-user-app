import 'package:heraj/config/app_assets.dart';
import '../../domain/entities/store_category_entity.dart';
import '../../domain/entities/store_sub_category_entity.dart';

abstract class StoreDataSource {
  Future<List<StoreCategoryEntity>> fetchCategories();
  Future<List<StoreSubCategoryEntity>> fetchSubCategories();
}

class StoreDummyDataSourceImpl implements StoreDataSource {
  @override
  Future<List<StoreCategoryEntity>> fetchCategories() async {
    return const [
      StoreCategoryEntity(
        id: 1,
        nameAr: 'طعام',
        nameEn: 'Food',
        image: AppAssets.homeCategoryFood,
      ),
      StoreCategoryEntity(
        id: 2,
        nameAr: 'صيدلية',
        nameEn: 'Pharmacy',
        image: AppAssets.homeCategoryPharmacy,
      ),
      StoreCategoryEntity(
        id: 3,
        nameAr: 'بقالة',
        nameEn: 'Grocery',
        image: AppAssets.homeCategoryGrocery,
      ),
      StoreCategoryEntity(
        id: 4,
        nameAr: 'خدمات',
        nameEn: 'Services',
        image: AppAssets.homeCategoryServices,
      ),
    ];
  }

  @override
  Future<List<StoreSubCategoryEntity>> fetchSubCategories() async {
    return const [
      StoreSubCategoryEntity(
        id: 1,
        categoryId: 1,
        nameAr: 'دجاج',
        nameEn: 'Chicken',
        image: AppAssets.homeCategoryFood,
      ),
      StoreSubCategoryEntity(
        id: 2,
        categoryId: 1,
        nameAr: 'وجبات سريعة',
        nameEn: 'Fast Food',
        image: AppAssets.homeCategoryFood,
      ),
      StoreSubCategoryEntity(
        id: 3,
        categoryId: 1,
        nameAr: 'بحريات',
        nameEn: 'Seafood',
        image: AppAssets.homeCategoryFood,
      ),
      StoreSubCategoryEntity(
        id: 4,
        categoryId: 2,
        nameAr: 'أدوية',
        nameEn: 'Medicine',
        image: AppAssets.homeCategoryPharmacy,
      ),
      StoreSubCategoryEntity(
        id: 5,
        categoryId: 2,
        nameAr: 'مكملات',
        nameEn: 'Supplements',
        image: AppAssets.homeCategoryPharmacy,
      ),
      StoreSubCategoryEntity(
        id: 6,
        categoryId: 3,
        nameAr: 'خضروات',
        nameEn: 'Vegetables',
        image: AppAssets.homeCategoryGrocery,
      ),
      StoreSubCategoryEntity(
        id: 7,
        categoryId: 4,
        nameAr: 'توصيل',
        nameEn: 'Delivery',
        image: AppAssets.homeCategoryServices,
      ),
    ];
  }
}

