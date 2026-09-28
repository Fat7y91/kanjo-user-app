import 'share_link_type.dart';

class ShareLinkResolveEntity {
  const ShareLinkResolveEntity({
    required this.type,
    required this.id,
    required this.screen,
  });

  final ShareLinkType type;
  final int id;
  final String screen;

  factory ShareLinkResolveEntity.fromJson(Map<String, dynamic> json) {
    return ShareLinkResolveEntity(
      type: ShareLinkType.fromApi(json['type']?.toString() ?? ''),
      id: int.tryParse(json['id']?.toString() ?? '') ?? 0,
      screen: json['screen']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
        'type': type.apiValue,
        'id': id,
        'screen': screen,
      };
}
