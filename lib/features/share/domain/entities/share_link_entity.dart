import 'share_link_type.dart';

class ShareLinkEntity {
  const ShareLinkEntity({
    required this.reference,
    required this.url,
    required this.type,
  });

  final String reference;
  final String url;
  final ShareLinkType type;

  factory ShareLinkEntity.fromJson(Map<String, dynamic> json) {
    return ShareLinkEntity(
      reference: json['reference']?.toString() ?? '',
      url: json['url']?.toString() ?? '',
      type: ShareLinkType.fromApi(json['type']?.toString() ?? ''),
    );
  }

  Map<String, dynamic> toJson() => {
        'reference': reference,
        'url': url,
        'type': type.apiValue,
      };
}
