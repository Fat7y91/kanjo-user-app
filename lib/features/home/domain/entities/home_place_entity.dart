class HomePlaceEntity {
  final String id;
  final String title;
  final String imagePath;
  final double rating;
  final int reviewsCount;
  final String distanceText;

  const HomePlaceEntity({
    required this.id,
    required this.title,
    required this.imagePath,
    required this.rating,
    required this.reviewsCount,
    required this.distanceText,
  });
}

