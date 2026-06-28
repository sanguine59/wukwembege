enum StallStatus { confirmed, pending, declined }

StallStatus stallStatusFromString(String s) =>
    StallStatus.values.firstWhere((e) => e.name == s, orElse: () => StallStatus.pending);

class Stall {
  final String id;
  final String name;
  final String cuisine;
  final String owner;
  final StallStatus status;
  final String spot;
  final int fee;

  const Stall({
    required this.id,
    required this.name,
    required this.cuisine,
    required this.owner,
    required this.status,
    required this.spot,
    required this.fee,
  });

  Stall copyWith({
    String? name,
    String? cuisine,
    String? owner,
    StallStatus? status,
    String? spot,
    int? fee,
  }) =>
      Stall(
        id: id,
        name: name ?? this.name,
        cuisine: cuisine ?? this.cuisine,
        owner: owner ?? this.owner,
        status: status ?? this.status,
        spot: spot ?? this.spot,
        fee: fee ?? this.fee,
      );

  Map<String, dynamic> toMap() => {
        'id': id,
        'name': name,
        'cuisine': cuisine,
        'owner': owner,
        'status': status.name,
        'spot': spot,
        'fee': fee,
      };

  factory Stall.fromMap(Map<String, dynamic> m) => Stall(
        id: (m['id'] ?? '') as String,
        name: (m['name'] ?? '') as String,
        cuisine: (m['cuisine'] ?? '') as String,
        owner: (m['owner'] ?? '') as String,
        status: stallStatusFromString((m['status'] ?? 'pending') as String),
        spot: (m['spot'] ?? '-') as String,
        fee: (m['fee'] ?? 0) as int,
      );
}
