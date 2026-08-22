import 'package:intl/intl.dart';

class UserProfile {
  final String id;
  final String? email;
  final String? phone;
  final String? displayName;
  final String? avatarUrl;
  final String? customAvatarPath;
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
    this.customAvatarPath,
    this.provider = 'google',
    this.createdAt,
    this.lastSignInAt,
    this.isDemo = false,
  });

  bool get isGoogle =>
      provider == 'google' || (email != null && email!.endsWith('@gmail.com'));

  bool get hasCustomAvatar =>
      customAvatarPath != null && customAvatarPath!.isNotEmpty;

  bool get hasNetworkAvatar => avatarUrl != null && avatarUrl!.isNotEmpty;

  String get displayTitle {
    if (displayName != null && displayName!.isNotEmpty) return displayName!;
    if (email != null && email!.isNotEmpty) return email!;
    if (phone != null && phone!.isNotEmpty) return phone!;
    return isDemo ? 'Demo Trader' : 'Google Trader';
  }

  String get displaySubtitle {
    if (phone != null && phone!.isNotEmpty) return phone!;
    if (email != null && email!.isNotEmpty) return email!;
    return '021 Trader';
  }

  String get initials {
    final title = displayTitle;
    if (title.isEmpty) return 'T';
    final parts = title.trim().split(RegExp(r'\s+'));
    if (parts.length >= 2 && parts[0].isNotEmpty && parts[1].isNotEmpty) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return title.substring(0, 1).toUpperCase();
  }

  String get clientId {
    if (isDemo) return '021DEMO4821';
    final rawInitials = initials.replaceAll(RegExp(r'[^a-zA-Z0-9]'), '');
    final cleanId = id.replaceAll(RegExp(r'[^a-zA-Z0-9]'), '').toUpperCase();
    final suffix =
        cleanId.length >= 4 ? cleanId.substring(cleanId.length - 4) : '4821';
    return '021$rawInitials$suffix';
  }

  String get formattedJoinedDate {
    if (createdAt != null) {
      return DateFormat('MMM dd, yyyy').format(createdAt!);
    }
    return 'Active Today';
  }

  UserProfile copyWith({
    String? id,
    String? email,
    String? phone,
    String? displayName,
    String? avatarUrl,
    String? customAvatarPath,
    bool clearCustomAvatar = false,
    String? provider,
    DateTime? createdAt,
    DateTime? lastSignInAt,
    bool? isDemo,
  }) {
    return UserProfile(
      id: id ?? this.id,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      displayName: displayName ?? this.displayName,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      customAvatarPath: clearCustomAvatar
          ? null
          : (customAvatarPath ?? this.customAvatarPath),
      provider: provider ?? this.provider,
      createdAt: createdAt ?? this.createdAt,
      lastSignInAt: lastSignInAt ?? this.lastSignInAt,
      isDemo: isDemo ?? this.isDemo,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'email': email,
        'phone': phone,
        'displayName': displayName,
        'avatarUrl': avatarUrl,
        'customAvatarPath': customAvatarPath,
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
        customAvatarPath: json['customAvatarPath'] as String?,
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
          id == other.id &&
          customAvatarPath == other.customAvatarPath &&
          avatarUrl == other.avatarUrl;

  @override
  int get hashCode => id.hashCode ^ (customAvatarPath?.hashCode ?? 0);
}
