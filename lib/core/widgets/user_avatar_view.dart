import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../../app/theme/app_colors.dart';
import '../../features/auth/domain/user_profile.dart';

class UserAvatarView extends StatelessWidget {
  final UserProfile? user;
  final double size;
  final bool isEditable;
  final VoidCallback? onTap;
  final Color? backgroundColor;
  final Color? textColor;
  final double fontSize;

  const UserAvatarView({
    super.key,
    required this.user,
    this.size = 48,
    this.isEditable = false,
    this.onTap,
    this.backgroundColor,
    this.textColor,
    this.fontSize = 18,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final bg = backgroundColor ?? colors.chipBackground;
    final fg = textColor ?? colors.primary;

    Widget avatarContent = _buildAvatarContent(context, bg, fg);

    if (isEditable) {
      avatarContent = Stack(
        clipBehavior: Clip.none,
        children: [
          avatarContent,
          Positioned(
            bottom: 0,
            right: 0,
            child: Container(
              width: size * 0.38,
              height: size * 0.38,
              decoration: BoxDecoration(
                color: colors.primary,
                shape: BoxShape.circle,
                border: Border.all(
                  color: colors.surfaceElevated,
                  width: 2,
                ),
              ),
              child: Center(
                child: Icon(
                  Icons.camera_alt_rounded,
                  size: size * 0.20,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      );
    }

    if (onTap != null) {
      return GestureDetector(
        onTap: onTap,
        child: avatarContent,
      );
    }

    return avatarContent;
  }

  Widget _buildAvatarContent(BuildContext context, Color bg, Color fg) {
    // 1. Check Custom Locally Selected Avatar File
    if (user != null &&
        user!.customAvatarPath != null &&
        user!.customAvatarPath!.isNotEmpty) {
      final path = user!.customAvatarPath!;
      if (!kIsWeb) {
        try {
          final file = File(path);
          if (file.existsSync()) {
            return Container(
              width: size,
              height: size,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: bg,
              ),
              child: ClipOval(
                child: Image.file(
                  file,
                  width: size,
                  height: size,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) =>
                      _buildNetworkOrInitials(context, bg, fg),
                ),
              ),
            );
          }
        } catch (e) {
          debugPrint('Error loading custom avatar file: $e');
        }
      }
    }

    return _buildNetworkOrInitials(context, bg, fg);
  }

  Widget _buildNetworkOrInitials(BuildContext context, Color bg, Color fg) {
    // 2. Check Network / Google photoURL
    if (user != null &&
        user!.avatarUrl != null &&
        user!.avatarUrl!.isNotEmpty) {
      return Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: bg,
        ),
        child: ClipOval(
          child: Image.network(
            user!.avatarUrl!,
            width: size,
            height: size,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) =>
                _buildInitials(context, bg, fg),
          ),
        ),
      );
    }

    // 3. Fallback to Initials Default Avatar
    return _buildInitials(context, bg, fg);
  }

  Widget _buildInitials(BuildContext context, Color bg, Color fg) {
    final initials = user?.initials ?? 'T';
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: bg,
      ),
      child: Center(
        child: Text(
          initials,
          style: TextStyle(
            fontFamily: 'Hanken Grotesk',
            fontSize: fontSize > 0 ? fontSize : (size * 0.38),
            fontWeight: FontWeight.w600,
            color: fg,
          ),
        ),
      ),
    );
  }
}
