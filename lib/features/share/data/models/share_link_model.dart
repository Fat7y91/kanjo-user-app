import '../../domain/entities/share_link_entity.dart';
import '../../domain/entities/share_link_resolve_entity.dart';

class ShareLinkModel extends ShareLinkEntity {
  const ShareLinkModel({
    required super.reference,
    required super.url,
    required super.type,
  });

  factory ShareLinkModel.fromJson(Map<String, dynamic> json) {
    return ShareLinkModel(
      reference: json['reference']?.toString() ?? '',
      url: json['url']?.toString() ?? '',
      type: ShareLinkEntity.fromJson(json).type,
    );
  }
}

class ShareLinkResolveModel extends ShareLinkResolveEntity {
  const ShareLinkResolveModel({
    required super.type,
    required super.id,
    required super.screen,
  });

  factory ShareLinkResolveModel.fromJson(Map<String, dynamic> json) {
    return ShareLinkResolveModel(
      type: ShareLinkResolveEntity.fromJson(json).type,
      id: ShareLinkResolveEntity.fromJson(json).id,
      screen: ShareLinkResolveEntity.fromJson(json).screen,
    );
  }
}
