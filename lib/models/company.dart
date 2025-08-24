class Company {
  final String id;
  final String name;
  final DateTime createdAt; // ou DateTime si tu préfères
  final String address;
  final String phone;
  final String email;
  final bool verified;

  Company({
    required this.id,
    required this.name,
    required this.createdAt,
    required this.address,
    required this.phone,
    required this.email,
    required this.verified,
  });

  factory Company.fromJson(Map<String, dynamic> json) {
    String _asStr(dynamic v) => (v ?? '').toString();

    // id peut venir sous "id" ou "company_id" selon tes endpoints
    final id = _asStr(json['id'].toString().isNotEmpty ? json['id'] : json['company_id']);
    if (id.isEmpty) {
      throw FormatException('Company.fromJson: id manquant dans la réponse API');
    }

    // parse created_at (ISO-8601 conseillé côté API)
    final createdIso = _asStr(json['created_at']);
    final created = DateTime.tryParse(createdIso) ?? DateTime.now();

    // bool tolérant (bool, int, string)
    bool _asBool(dynamic v) {
      if (v is bool) return v;
      if (v is num) return v != 0;
      final s = v?.toString().toLowerCase();
      return s == 'true' || s == '1' || s == 'yes';
    }

    return Company(
      id: id,
      name: json['name'] ?? '',
      createdAt: created,
      address: json['address'] ?? '',
      phone: json['phone'] ?? '',
      email: json['email'] ?? '',
      verified: _asBool(json['verified']),
    );
  }
}