class Point {
  final double latitude;
  final double longitude;
  final String title;
  final String description;
  final String image_url;

  Point({
    required this.latitude,
    required this.longitude,
    required this.title,
    required this.description,
    required this.image_url,
  });

  factory Point.fromJson(Map<String, dynamic> json) {
    return Point(
      latitude: json['latitude'],
      longitude: json['longitude'],
      title: json['title'],
      description: json['description'],
      image_url: json['image_url'],
    );
  }
} 