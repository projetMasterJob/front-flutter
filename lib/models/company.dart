class Company {
  final String name;
  final String createdAt; // ou DateTime si tu préfères
  final String address;
  final String phone;
  final String email;
  final bool verified;

  Company({
    required this.name,
    required this.createdAt,
    required this.address,
    required this.phone,
    required this.email,
    required this.verified,
  });

  factory Company.fromJson(Map<String, dynamic> json) {
    return Company(
      name: json['name'] ?? '',
      createdAt: json['created_at'] ?? '',
      address: json['address'] ?? '',
      phone: json['phone'] ?? '',
      email: json['email'] ?? '',
      verified: json['verified'] ?? false,
    );
  }
}