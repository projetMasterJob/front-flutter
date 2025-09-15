class Job {
  final String id;
  final String title;
  final String description;
  final String salary;
  final String jobType;
  final String postedAt;
  final int applicationsCount;
  final String? address;
  final String? postalCode;
  final double? latitude;
  final double? longitude;
  final String? imageUrl;

  Job({
    required this.id,
    required this.title,
    required this.description,
    required this.salary,
    required this.jobType,
    required this.postedAt,
    required this.applicationsCount,
    this.address,
    this.postalCode,
    this.latitude,
    this.longitude,
    this.imageUrl,
  });

  factory Job.fromJson(Map<String, dynamic> json) {
    return Job(
      id: json['id']?.toString() ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      salary: json['salary'] ?? '',
      jobType: json['job_type'] ?? '',
      postedAt: json['posted_at'] ?? '',
      applicationsCount: int.tryParse(json['applications_count']?.toString() ?? '0') ?? 0,
      address: json['address'],
      postalCode: json['postal_code'],
      latitude: json['latitude']?.toDouble(),
      longitude: json['longitude']?.toDouble(),
      imageUrl: json['image_url'],
    );
  }
}