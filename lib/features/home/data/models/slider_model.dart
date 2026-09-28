import '../../domain/entities/slider_target_entity.dart';
import '../../domain/entities/slider_target_type.dart';

class SliderModel {
  final int id;
  final String imageUrl;
  final SliderTargetEntity? target;

  const SliderModel({
    required this.id,
    required this.imageUrl,
    this.target,
  });

  bool get canNavigate =>
      target != null &&
      target!.type != SliderTargetType.home &&
      target!.id > 0;

  factory SliderModel.fromJson(Map<String, dynamic> json) {
    final targetRaw = json['target'];
    final SliderTargetEntity? target = targetRaw is Map
        ? SliderTargetEntity.fromJson(Map<String, dynamic>.from(targetRaw))
        : null;

    return SliderModel(
      id: json['id'] is int
          ? json['id'] as int
          : int.tryParse(json['id']?.toString() ?? '') ?? 0,
      imageUrl: json['image_url']?.toString() ??
          json['image']?.toString() ??
          '',
      target: target,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'image_url': imageUrl,
        'target': target?.toJson(),
      };
}
