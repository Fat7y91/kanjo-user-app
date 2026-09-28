import 'services_json.dart';

class ServiceRatingEntity {
  final int id;
  final String userName;
  final String? userImageUrl;
  final double rating;
  final String comment;

  const ServiceRatingEntity({
    required this.id,
    required this.userName,
    this.userImageUrl,
    required this.rating,
    required this.comment,
  });

  factory ServiceRatingEntity.fromJson(Map<String, dynamic> json) {
    final user = asMap(json['user']) ?? asMap(json['customer']);
    return ServiceRatingEntity(
      id: asInt(json['id']),
      userName: json['user_name']?.toString() ??
          user?['name']?.toString() ??
          json['name']?.toString() ??
          '',
      userImageUrl: json['user_image_url']?.toString() ??
          json['avatar_url']?.toString() ??
          user?['image']?.toString() ??
          user?['avatar_url']?.toString() ??
          user?['profile_image_url']?.toString(),
      rating: asDouble(json['rating'] ?? json['stars'] ?? json['score']),
      comment: json['comment']?.toString() ??
          json['body']?.toString() ??
          json['review']?.toString() ??
          json['message']?.toString() ??
          '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_name': userName,
      'user_image_url': userImageUrl,
      'rating': rating,
      'comment': comment,
    };
  }
}
