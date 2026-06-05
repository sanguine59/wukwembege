class Participation {
  final String id;
  final String status;
  final String? spot;

  const Participation({required this.id, required this.status, this.spot});

  Map<String, dynamic> toMap() => {
        'id': id,
        'status': status,
        if (spot != null) 'spot': spot,
      };

  factory Participation.fromMap(Map<String, dynamic> m) => Participation(
        id: (m['id'] ?? '') as String,
        status: (m['status'] ?? 'pending') as String,
        spot: m['spot'] as String?,
      );
}
