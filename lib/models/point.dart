class Point {
  final String id;
  final double latitude;
  final double longitude;
  final String title;
  final String description;
  final String address;
  final String cp;
  final String entity_type;
  final String image_url;

  Point({
    required this.id,
    required this.latitude,
    required this.longitude,
    required this.title,
    required this.description,
    required this.address,
    required this.cp,
    required this.entity_type,
    required this.image_url,
  });
}