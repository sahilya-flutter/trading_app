import 'package:intl/intl.dart';

class UserProfile {
  final String id;
  final String? email;
  final String? phone;
  final String? displayName;
  final String? avatarUrl;
  final String provider;
  final DateTime? createdAt;
  final DateTime? lastSignInAt;
  final bool isDemo;

  const UserProfile({
    required this.id,
    this.email,
    this.phone,
    this.displayName,
    this.avatarUrl,
    this.provider = 'google',
    this.createdAt,
    this.lastSignInAt,
    this.isDemo = false,
  });

  bool get isGoogle => provider == 'google' || (email != null && email!.endsWith('@gmail.com'));

  String get displayTitle {
    if (displayName != null && displayName!.isNotEmpty) return displayName!;
    if (email != null && email!.isNotEmpty) return email!;
    if (phone != null && phone!.isNotEmpty) return phone!;
    return isDemo ? 'Demo Trader' : 'Google Trader';
  }

  String get initials {
    final title = displayTitle;
    if (title.isEmpty) return 'T';
    final parts = title.split(' ');
    if (parts.length >= 2 && parts[0].isNotEmpty && parts[1].isNotEmpty) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return title.substring(0, 1).toUpperCase();
  }

  String get formattedJoinedDate {
    if (createdAt != null) {
      return DateFormat('MMM dd, yyyy').format(createdAt!);
    }
    return 'Active Today';
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'email': email,
        'phone': phone,
        'displayName': displayName,
        'avatarUrl': avatarUrl,
        'provider': provider,
        'createdAt': createdAt?.toIso8601String(),
        'lastSignInAt': lastSignInAt?.toIso8601String(),
        'isDemo': isDemo,
      };

  factory UserProfile.fromJson(Map<String, dynamic> json) => UserProfile(
        id: json['id'] as String,
        email: json['email'] as String?,
        phone: json['phone'] as String?,
        displayName: json['displayName'] as String?,
        avatarUrl: json['avatarUrl'] as String?,
        provider: json['provider'] as String? ?? 'google',
        createdAt: json['createdAt'] != null
            ? DateTime.tryParse(json['createdAt'] as String)
            : null,
        lastSignInAt: json['lastSignInAt'] != null
            ? DateTime.tryParse(json['lastSignInAt'] as String)
            : null,
        isDemo: json['isDemo'] as bool? ?? false,
      );

  factory UserProfile.demo() => UserProfile(
        id: 'demo_trader_021',
        email: 'trader.pro@gmail.com',
        displayName: 'Demo Trader',
        provider: 'demo',
        createdAt: DateTime.now(),
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
