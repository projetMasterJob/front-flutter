class Company {
  final String name;
  final String memberSince; // ou DateTime si tu préfères
  final String tagline;
  final String address;
  final String phone;
  final String email;
  final bool verified;

  Company({
    required this.name,
    required this.memberSince,
    required this.tagline,
    required this.address,
    required this.phone,
    required this.email,
    required this.verified,
  });

  factory Company.fromJson(Map<String, dynamic> json) {
    return Company(
      name: json['name'] ?? '',
      memberSince: json['member_since'] ?? '',
      tagline: json['tagline'] ?? '',
      address: json['address'] ?? '',
      phone: json['phone'] ?? '',
      email: json['email'] ?? '',
      verified: json['verified'] ?? false,
    );
  }
}