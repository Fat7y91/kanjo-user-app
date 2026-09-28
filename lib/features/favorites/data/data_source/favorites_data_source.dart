import 'package:dio/dio.dart';

import '../../../../config/api_path.dart';
import '../../../../core/models/paginated_response.dart';
import '../../../../core/service/webservice/dio_helper.dart';
import '../models/wishlist_item_model.dart';

abstract class FavoritesDataSource {
  Future<List<WishlistItemModel>> getWishlist();

  Future<bool> toggleWishlist({
    required int productId,
    int? productVariantId,
  });

  Future<bool> addToWishlist({
    required int productId,
    int? productVariantId,
  });

  Future<bool> removeWishlistItem(int wishlistItemId);
}

class FavoritesDataSourceImpl extends FavoritesDataSource {
  final ApiService apiService;

  FavoritesDataSourceImpl({required this.apiService});

  @override
  Future<List<WishlistItemModel>> getWishlist() async {
    return fetchAllPaginatedPages(
      fetchPage: (page) async {
        final res = await apiService.get(
          url: ApiPath.getFavoritesList(
            page: page,
            perPage: PaginationConfig.largePerPage,
          ),
          returnDataOnly: false,
        );
        return parsePaginatedResponse(
          res,
          (json) => WishlistItemModel.fromJson(json),
        );
      },
    );
  }

  @override
  Future<bool> toggleWishlist({
    required int productId,
    int? productVariantId,
  }) async {
    await apiService.post(
      url: ApiPath.toggleFavorite,
      requestBody: FormData.fromMap({
        'product_id': productId,
        if (productVariantId != null) 'product_variant_id': productVariantId,
      }),
      returnDataOnly: true,
    );
    return true;
  }

  @override
  Future<bool> addToWishlist({
    required int productId,
    int? productVariantId,
  }) async {
    await apiService.post(
      url: ApiPath.addFavorite,
      requestBody: {
        'product_id': productId,
        'product_variant_id': productVariantId,
      },
      returnDataOnly: true,
    );
    return true;
  }

  @override
  Future<bool> removeWishlistItem(int wishlistItemId) async {
    await apiService.delete(url: ApiPath.deleteFavorite(wishlistItemId));
    return true;
  }
}
