class Testimonials {
  final String? designation;
  final String? name;
  final String? picture;
  final int testimonialId;
  final String? text;

  Testimonials({
    this.designation,
    this.name,
    this.picture,
    required this.testimonialId,
    this.text,
  });

  factory Testimonials.fromJson(Map<String, dynamic> json) => Testimonials(
    designation: json["designation"],
    name: json["name"],
    picture: json["picture"],
    testimonialId: json["testimonial_id"],
    text: json["text"],
  );

  Map<String, dynamic> toJson() => {
    "designation": designation,
    "name": name,
    "picture": picture,
    "testimonial_id": testimonialId,
    "text": text,
  };
}