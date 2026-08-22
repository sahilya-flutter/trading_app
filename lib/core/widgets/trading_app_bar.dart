import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../app/theme/app_colors.dart';
import '../../app/theme/theme_provider.dart';
import '../../features/auth/presentation/auth_providers.dart';
import '../../features/home/presentation/widgets/notification_sheet.dart';
import '../../features/notifications/presentation/notifications_providers.dart';
import 'user_avatar_view.dart';

class TradingAppBar extends ConsumerWidget implements PreferredSizeWidget {
  final Widget? titleWidget;
  final String? title;
  final String? subtitle;
  final Widget? leading;
  final bool showBackButton;
  final VoidCallback? onBack;
  final List<Widget>? actions;
  final bool showLiveMarketIndicator;
  final bool isStressMode;
  final double height;

  const TradingAppBar({
    super.key,
    this.titleWidget,
    this.title,
    this.subtitle,
    this.leading,
    this.showBackButton = false,
    this.onBack,
    this.actions,
    this.showLiveMarketIndicator = false,
    this.isStressMode = false,
    this.height = 56.0,
  });

  /// Factory for the Home Dashboard header
  factory TradingAppBar.home({
    Key? key,
  }) {
    return TradingAppBar(
      key: key,
      title: '021 Trading App',
    );
  }

  /// Factory for the Market screen header with live indicator
  factory TradingAppBar.market({
    Key? key,
    bool isStressMode = false,
    String? subtitle,
    List<Widget>? actions,
  }) {
    return TradingAppBar(
      key: key,
      title: 'Market Overview',
      subtitle: subtitle,
      showLiveMarketIndicator: true,
      isStressMode: isStressMode,
      actions: actions,
    );
  }

  /// Factory for the Watchlist screen header
  factory TradingAppBar.watchlist({
    Key? key,
    List<Widget>? actions,
  }) {
    return TradingAppBar(
      key: key,
      title: 'Watchlist',
      actions: actions,
    );
  }

  /// Factory for the Holdings & Portfolio header
  factory TradingAppBar.holdings({
    Key? key,
    List<Widget>? actions,
  }) {
    return TradingAppBar(
      key: key,
      title: 'Holdings & Portfolio',
      actions: actions,
    );
  }

  /// Factory for secondary screens with back navigation
  factory TradingAppBar.secondary({
    Key? key,
    required String title,
    String? subtitle,
    VoidCallback? onBack,
    List<Widget>? actions,
    bool showBackButton = true,
  }) {
    return TradingAppBar(
      key: key,
      title: title,
      subtitle: subtitle,
      showBackButton: showBackButton,
      onBack: onBack,
      actions: actions,
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(height);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.colors;
    final isDark = context.isDark;
    final user = ref.watch(authStateProvider);
    final unreadCount = ref.watch(unreadNotificationsCountProvider);

    Widget? leadingContent;
    if (showBackButton) {
      leadingContent = IconButton(
        icon: Icon(Icons.arrow_back, color: colors.textPrimary, size: 22),
        tooltip: 'Back',
        onPressed: onBack ?? () => context.pop(),
      );
    } else if (leading != null) {
      leadingContent = leading;
    }

    // Title / Center Content
    Widget titleContent;
    if (titleWidget != null) {
      titleContent = titleWidget!;
    } else if (showLiveMarketIndicator) {
      final dotColor = isStressMode ? Colors.amber : colors.gain;
      titleContent = Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: dotColor,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: dotColor.withValues(alpha: 0.6),
                      blurRadius: 6,
                      spreadRadius: 2,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Flexible(
                child: Text(
                  title ?? '',
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontFamily: 'Hanken Grotesk',
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.3,
                    color: colors.textPrimary,
                  ),
                ),
              ),
            ],
          ),
          if (subtitle != null) ...[
            Padding(
              padding: const EdgeInsets.only(left: 16),
              child: Text(
                subtitle!,
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 11,
                  color: colors.textSecondary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ],
      );
    } else {
      titleContent = Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title ?? '',
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontFamily: 'Hanken Grotesk',
              fontSize: 18,
              fontWeight: FontWeight.w700,
              letterSpacing: -0.3,
              color: colors.textPrimary,
            ),
          ),
          if (subtitle != null) ...[
            const SizedBox(height: 1),
            Text(
              subtitle!,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 11,
                color: colors.textSecondary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ],
      );
    }

    return AppBar(
      backgroundColor: colors.surface,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: false,
      titleSpacing: showBackButton ? 0 : 16,
      leading: leadingContent,
      title: titleContent,
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(1),
        child: Container(
          color: colors.border.withValues(alpha: 0.6),
          height: 1,
        ),
      ),
      actions: actions ??
          [
            // Theme Toggle
            IconButton(
              icon: Icon(
                isDark ? Icons.light_mode_outlined : Icons.dark_mode_outlined,
                color: colors.textSecondary,
                size: 20,
              ),
              tooltip: isDark ? 'Switch to Light theme' : 'Switch to Dark theme',
              onPressed: () {
                ref.read(themeModeProvider.notifier).toggleTheme();
              },
            ),

            // Notification Bell with Unread Badge
            IconButton(
              icon: Stack(
                clipBehavior: Clip.none,
                children: [
                  Icon(
                    Icons.notifications_outlined,
                    color: colors.textSecondary,
                    size: 22,
                  ),
                  if (unreadCount > 0)
                    Positioned(
                      right: -2,
                      top: -2,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                        decoration: BoxDecoration(
                          color: colors.gain,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: colors.surface, width: 1.5),
                        ),
                        constraints: const BoxConstraints(
                          minWidth: 16,
                          minHeight: 16,
                        ),
                        child: Text(
                          unreadCount > 9 ? '9+' : '$unreadCount',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 9,
                            fontWeight: FontWeight.w700,
                            fontFamily: 'Inter',
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                ],
              ),
              tooltip: 'Notifications',
              onPressed: () => NotificationSheet.show(context),
            ),

            // Profile Avatar
            Padding(
              padding: const EdgeInsets.only(right: 12, left: 4),
              child: GestureDetector(
                onTap: () => context.push('/profile'),
                child: CircleAvatar(
                  radius: 16,
                  backgroundColor: Colors.transparent,
                  child: UserAvatarView(
                    user: user,
                    size: 32,
                    fontSize: 12,
                  ),
                ),
              ),
            ),
          ],
    );
  }
}
