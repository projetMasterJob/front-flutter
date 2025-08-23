class Job {
  final String title;
  final String description;
  final String salary;
  final String jobType;
  final String postedAt;
  final int applicationsCount;

  Job({
    required this.title,
    required this.description,
    required this.salary,
    required this.jobType,
    required this.postedAt,
    required this.applicationsCount,
  });

  factory Job.fromJson(Map<String, dynamic> json) {
    return Job(
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      salary: json['salary'] ?? '',
      jobType: json['job_type'] ?? '',
      postedAt: json['posted_at'] ?? '',
      applicationsCount: int.tryParse(json['applications_count']?.toString() ?? '0') ?? 0,
    );
  }
}