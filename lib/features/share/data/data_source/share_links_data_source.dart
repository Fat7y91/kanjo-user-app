import 'package:dio/dio.dart';
import '../../../../config/api_path.dart';
import '../../../../core/service/webservice/dio_helper.dart';
import '../../domain/entities/create_share_link_params.dart';
import '../../domain/entities/share_link_entity.dart';
import '../../domain/entities/share_link_resolve_entity.dart';

abstract class ShareLinksDataSource {
  Future<ShareLinkEntity> createShareLink(CreateShareLinkParams params);

  Future<ShareLinkResolveEntity> resolveShareLink(String reference);
}

class ShareLinksDataSourceImpl extends ShareLinksDataSource {
  ShareLinksDataSourceImpl({required this.apiService});

  final ApiService apiService;

  @override
  Future<ShareLinkEntity> createShareLink(CreateShareLinkParams params) async {
    final response = await apiService.post(
      url: ApiPath.shareLinks,
      requestBody: FormData.fromMap({
        'type': params.type.apiValue,
        'id': params.id.toString(),
      }),
      returnDataOnly: true,
    );
    return ShareLinkEntity.fromJson(Map<String, dynamic>.from(response as Map));
  }

  @override
  Future<ShareLinkResolveEntity> resolveShareLink(String reference) async {
    final response = await apiService.get(
      url: ApiPath.resolveShareLink(reference),
      returnDataOnly: true,
    );
    return ShareLinkResolveEntity.fromJson(
      Map<String, dynamic>.from(response as Map),
    );
  }
}
