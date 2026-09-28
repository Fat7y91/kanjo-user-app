class RatingParamsEntity {
  const RatingParamsEntity({
    required this.targetId,
    required this.rating,
    this.comment = '',
  });

  final int targetId;
  final int rating;
  final String comment;

  factory RatingParamsEntity.fromJson(Map<String, dynamic> json) {
    return RatingParamsEntity(
      targetId: json['id'] is int
          ? json['id'] as int
          : int.tryParse(json['id']?.toString() ?? '') ?? 0,
      rating: json['rating'] is int
          ? json['rating'] as int
          : int.tryParse(json['rating']?.toString() ?? '') ?? 0,
      comment: json['comment']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
        'id': targetId,
        'rating': rating,
        'comment': comment,
      };
}
