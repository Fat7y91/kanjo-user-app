import 'dart:io';

import 'package:flutter/foundation.dart';

@immutable
class CreateRefundRequestParams {
  final String orderId;
  final String reason;
  final List<File> images;

  const CreateRefundRequestParams({
    required this.orderId,
    required this.reason,
    this.images = const [],
  });

  factory CreateRefundRequestParams.fromJson(Map<String, dynamic> json) {
    final rawImages = json['images'];
    final images = <File>[];
    if (rawImages is List) {
      for (final item in rawImages) {
        final path = item?.toString().trim() ?? '';
        if (path.isNotEmpty) images.add(File(path));
      }
    }
    return CreateRefundRequestParams(
      orderId: json['order_id']?.toString() ?? '',
      reason: json['reason']?.toString() ?? '',
      images: images,
    );
  }

  Map<String, dynamic> toJson() => {
        'order_id': orderId,
        'reason': reason,
        'images': images.map((e) => e.path).toList(),
      };
}
