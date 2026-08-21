class UserProfile {
  final String id;
  final String? email;
  final String? phone;
  final String? displayName;
  final String? avatarUrl;
  final bool isDemo;

  const UserProfile({
    required this.id,
    this.email,
    this.phone,
    this.displayName,
    this.avatarUrl,
    this.isDemo = false,
  });

  String get displayTitle {
    if (displayName != null && displayName!.isNotEmpty) return displayName!;
    if (email != null && email!.isNotEmpty) return email!;
    if (phone != null && phone!.isNotEmpty) return phone!;
    return isDemo ? 'Demo Trader' : 'Trader';
  }

  String get initials {
    final title = displayTitle;
    if (title.isEmpty) return 'T';
    final parts = title.split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return title.substring(0, 1).toUpperCase();
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'email': email,
        'phone': phone,
        'displayName': displayName,
        'avatarUrl': avatarUrl,
        'isDemo': isDemo,
      };

  factory UserProfile.fromJson(Map<String, dynamic> json) => UserProfile(
        id: json['id'] as String,
        email: json['email'] as String?,
        phone: json['phone'] as String?,
        displayName: json['displayName'] as String?,
        avatarUrl: json['avatarUrl'] as String?,
        isDemo: json['isDemo'] as bool? ?? false,
      );

  factory UserProfile.demo() => const UserProfile(
        id: 'demo_user_021',
        email: 'trader@demo.com',
        phone: '+91 98765 43210',
        displayName: 'Demo Trader',
        isDemo: true,
      );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UserProfile &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;
}
