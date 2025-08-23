class Application {
  final String id;
  final String status;          // "pending" | "accepted" | "rejected"
  final DateTime appliedAt;
  final String firstName;
  final String lastName;
  final String email;
  final String phone;
  final String? address;
  final String jobId;
  final String jobTitle;
  final String cvUrl;
  final String description;
  final String userId;


  Application({
    required this.id,
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
    required this.userId,
  });

  factory Application.fromJson(Map<String, dynamic> json) {
    String _asStr(dynamic v) => (v ?? '').toString();
    
    return Application(
      id: _asStr(json['id']),
      firstName: json['first_name'] ?? '',
      lastName: json['last_name'] ?? '',
      email: json['email'] ?? '',
      phone: json['phone'] ?? '',
      address: json['address'] ?? '',
      appliedAt: DateTime.parse(json['applied_at'] ?? ''),
      status: json['status'] ?? '',
      jobId: _asStr(json['job_id']),
      jobTitle: json['job_title'] ?? '',
      cvUrl: (json['cv_url'] ?? json['cvUrl'] ?? '').toString(),
      description: json['description'] ?? '',
      userId: _asStr(json['user_id']),
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

  Application copyWith({String? status}) => Application(
    id: id,
    jobId: jobId,
    status: status ?? this.status,
    appliedAt: appliedAt,
    firstName: firstName,
    lastName: lastName,
    email: email,
    phone: phone,
    address: address,
    cvUrl: cvUrl,
    description: description,
    jobTitle: jobTitle,
    userId: userId,
  );
}