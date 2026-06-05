enum Role { organizer, vendor }

Role roleFromString(String s) =>
    Role.values.firstWhere((e) => e.name == s, orElse: () => Role.organizer);

class Profile {
  final String name;
  final String owner;
  final Role role;
  final String? roleLabel;
  final int? events;
  final int? vendors;
  final String? cuisine;
  final double? rating;
  final int? reviews;
  final String bio;
  final String color;
  final String glyph;
  final String email;
  final String phone;

  const Profile({
    required this.name,
    required this.owner,
    required this.role,
    this.roleLabel,
    this.events,
    this.vendors,
    this.cuisine,
    this.rating,
    this.reviews,
    required this.bio,
    required this.color,
    required this.glyph,
    required this.email,
    required this.phone,
  });

  Map<String, dynamic> toMap() => {
        'name': name,
        'owner': owner,
        'role': role.name,
        'roleLabel': roleLabel,
        'events': events,
        'vendors': vendors,
        'cuisine': cuisine,
        'rating': rating,
        'reviews': reviews,
        'bio': bio,
        'color': color,
        'glyph': glyph,
        'email': email,
        'phone': phone,
      };

  factory Profile.fromMap(Map<String, dynamic> m) => Profile(
        name: (m['name'] ?? '') as String,
        owner: (m['owner'] ?? '') as String,
        role: roleFromString((m['role'] ?? 'organizer') as String),
        roleLabel: m['roleLabel'] as String?,
        events: m['events'] as int?,
        vendors: m['vendors'] as int?,
        cuisine: m['cuisine'] as String?,
        rating: (m['rating'] as num?)?.toDouble(),
        reviews: m['reviews'] as int?,
        bio: (m['bio'] ?? '') as String,
        color: (m['color'] ?? 'blue') as String,
        glyph: (m['glyph'] ?? 'store') as String,
        email: (m['email'] ?? '') as String,
        phone: (m['phone'] ?? '') as String,
      );

  Profile copyWith({
    String? name,
    String? owner,
    Role? role,
    String? roleLabel,
    String? cuisine,
    String? bio,
    String? email,
    String? phone,
  }) =>
      Profile(
        name: name ?? this.name,
        owner: owner ?? this.owner,
        role: role ?? this.role,
        roleLabel: roleLabel ?? this.roleLabel,
        events: events,
        vendors: vendors,
        cuisine: cuisine ?? this.cuisine,
        rating: rating,
        reviews: reviews,
        bio: bio ?? this.bio,
        color: color,
        glyph: glyph,
        email: email ?? this.email,
        phone: phone ?? this.phone,
      );
}
