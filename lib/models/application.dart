class Application {
  final String status;          // "pending" | "accepted" | "rejected"
  final DateTime appliedAt;
  final String firstName;
  final String lastName;
  final String email;
  final String phone;
  final String? address;
  final int jobId;
  final String jobTitle;
  final String cvUrl;
  final String description;

  Application({
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.phone,
    required this.address,
    required this.appliedAt,
    required this.status,
    required this.jobId,
    required this.jobTitle,
    this.cvUrl = '',
    this.description = '',
  });

  factory Application.fromJson(Map<String, dynamic> json) {
    return Application(
      firstName: json['first_name'] ?? '',
      lastName: json['last_name'] ?? '',
      email: json['email'] ?? '',
      phone: json['phone'] ?? '',
      address: json['address'] ?? '',
      appliedAt: DateTime.parse(json['applied_at'] ?? ''),
      status: json['status'] ?? '',
      jobId: int.tryParse(json['job_id'].toString()) ?? 0,
      jobTitle: json['job_title'] ?? '',
      cvUrl: (json['cv_url'] ?? json['cvUrl'] ?? '').toString(),
      description: json['description'] ?? '',
    );
  }

  String get fullName =>
      '${firstName.isEmpty ? '' : firstName[0].toUpperCase() + firstName.substring(1)} '
      '${lastName.isEmpty ? '' : lastName[0].toUpperCase() + lastName.substring(1)}'.trim();

  String get statusLabel {
    switch (status) {
      case 'pending': return 'À étudier';
      case 'accepted': return 'Acceptée';
      case 'rejected': return 'Refusée';
      default: return status;
    }
  }
}