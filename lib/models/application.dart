class Application {
  final String status;          // "pending" | "accepted" | "rejected"
  final DateTime appliedAt;
  final String firstName;
  final String lastName;
  final String email;
  final String phone;
  final String? address;

  Application({
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.phone,
    required this.address,
    required this.appliedAt,
    required this.status,
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