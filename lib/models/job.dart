class Job {
  final String title;
  final String description;
  final String salary;
  final String jobType;
  final String postedAt;     // "il y a 2 j" ou un ISO date si le backend renvoie ça
  final int candidats;

  Job({
    required this.title,
    required this.description,
    required this.salary,
    required this.jobType,
    required this.postedAt,
    required this.candidats,
  });

  factory Job.fromJson(Map<String, dynamic> json) {
    return Job(
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      salary: json['salary'] ?? '',
      jobType: json['jobType'] ?? '',
      postedAt: json['postedAt'] ?? '',
      candidats: (json['candidats'] ?? 0) as int,
    );
  }
}