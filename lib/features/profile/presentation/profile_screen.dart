import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/theme_provider.dart';
import '../../../core/utils/money_formatter.dart';
import '../../../core/widgets/trading_app_bar.dart';
import '../../../core/widgets/user_avatar_view.dart';
import '../../auth/domain/user_profile.dart';
import '../../auth/presentation/auth_providers.dart';
import '../../holdings/presentation/holdings_providers.dart';
import '../../market/presentation/market_providers.dart';
import '../../order/presentation/order_providers.dart';
import '../../wallet/presentation/wallet_providers.dart';
import '../../watchlist/presentation/watchlist_providers.dart';
import '../../watchlist/presentation/widgets/watchlist_selector_sheet.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  void _showLogoutDialog(BuildContext context, WidgetRef ref) {
    final colors = context.colors;
    showDialog<void>(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.54),
      builder: (ctx) => AlertDialog(
        backgroundColor: colors.surfaceElevated,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: colors.border),
        ),
        titlePadding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
        contentPadding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
        actionsPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        title: Text(
          'Log out?',
          style: TextStyle(
            fontFamily: 'Hanken Grotesk',
            fontSize: 17,
            fontWeight: FontWeight.w600,
            color: colors.textPrimary,
            letterSpacing: -0.2,
          ),
        ),
        content: Text(
          'Your watchlists and holdings stay saved on this device.',
          style: TextStyle(
            fontFamily: 'Inter',
            fontSize: 14,
            color: colors.textSecondary,
            height: 1.4,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text(
              'Cancel',
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: colors.textSecondary,
              ),
            ),
          ),
          const SizedBox(width: 8),
          ElevatedButton(
            onPressed: () async {
              Navigator.of(ctx).pop();
              await ref.read(authControllerProvider.notifier).signOut();
              if (context.mounted) {
                context.go('/login');
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: colors.loss,
              elevation: 0,
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: Text(
              'Log out',
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: colors.onPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showPermissionSettingsPrompt(BuildContext context, String message) {
    final colors = context.colors;
    showDialog<void>(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.54),
      builder: (ctx) => AlertDialog(
        backgroundColor: colors.surfaceElevated,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: colors.border),
        ),
        title: Text(
          'Permission Required',
          style: TextStyle(
            fontFamily: 'Hanken Grotesk',
            fontSize: 17,
            fontWeight: FontWeight.w600,
            color: colors.textPrimary,
          ),
        ),
        content: Text(
          message,
          style: TextStyle(
            fontFamily: 'Inter',
            fontSize: 14,
            color: colors.textSecondary,
            height: 1.4,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text(
              'Cancel',
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: colors.textSecondary,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              openAppSettings();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: colors.primary,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text(
              'Open Settings',
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showPermissionSnackBar(BuildContext context, String message) {
    final colors = context.colors;
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: const TextStyle(color: Colors.white),
        ),
        backgroundColor: colors.loss,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  void _showChangePhotoModal(
      BuildContext context, WidgetRef ref, UserProfile? user) {
    final colors = context.colors;
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: colors.surfaceElevated,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 36,
                    height: 4,
                    decoration: BoxDecoration(
                      color: colors.divider,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: Text(
                    'Change Profile Photo',
                    style: TextStyle(
                      fontFamily: 'Hanken Grotesk',
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: colors.textPrimary,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                ListTile(
                  leading: Icon(Icons.camera_alt_outlined, color: colors.primary),
                  title: Text(
                    'Take Photo',
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                      color: colors.textPrimary,
                    ),
                  ),
                  onTap: () async {
                    Navigator.of(ctx).pop();
                    try {
                      final status = await Permission.camera.request();
                      if (status.isGranted || status.isLimited) {
                        final picker = ImagePicker();
                        final photo = await picker.pickImage(
                          source: ImageSource.camera,
                          maxWidth: 1024,
                          maxHeight: 1024,
                          imageQuality: 85,
                        );
                        if (photo != null) {
                          await ref
                              .read(authControllerProvider.notifier)
                              .updateProfileImage(photo.path);
                        }
                      } else if (status.isPermanentlyDenied) {
                        if (context.mounted) {
                          _showPermissionSettingsPrompt(
                            context,
                            'Camera permission is permanently denied. Please enable Camera access in App Settings to take a profile photo.',
                          );
                        }
                      } else {
                        if (context.mounted) {
                          _showPermissionSnackBar(
                            context,
                            'Camera permission is required to take a profile photo.',
                          );
                        }
                      }
                    } catch (e) {
                      debugPrint('Camera capture error: $e');
                    }
                  },
                ),
                ListTile(
                  leading: Icon(Icons.photo_library_outlined, color: colors.primary),
                  title: Text(
                    'Choose from Gallery',
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                      color: colors.textPrimary,
                    ),
                  ),
                  onTap: () async {
                    Navigator.of(ctx).pop();
                    try {
                      final picker = ImagePicker();
                      final photo = await picker.pickImage(
                        source: ImageSource.gallery,
                        maxWidth: 1024,
                        maxHeight: 1024,
                        imageQuality: 85,
                      );
                      if (photo != null) {
                        await ref
                            .read(authControllerProvider.notifier)
                            .updateProfileImage(photo.path);
                      }
                    } on PlatformException catch (e) {
                      debugPrint('Gallery picker platform error: $e');
                      if (e.code == 'photo_access_denied' ||
                          e.code == 'camera_access_denied') {
                        if (context.mounted) {
                          _showPermissionSettingsPrompt(
                            context,
                            'Photo library permission was denied. Please allow access in App Settings.',
                          );
                        }
                      }
                    } catch (e) {
                      debugPrint('Gallery picker error: $e');
                    }
                  },
                ),
                if (user?.hasCustomAvatar == true)
                  ListTile(
                    leading: Icon(Icons.delete_outline, color: colors.loss),
                    title: Text(
                      'Remove Custom Photo',
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                        color: colors.loss,
                      ),
                    ),
                    onTap: () async {
                      Navigator.of(ctx).pop();
                      await ref
                          .read(authControllerProvider.notifier)
                          .removeCustomProfileImage();
                    },
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showTickRateModal(BuildContext context, WidgetRef ref, int currentRate) {
    final colors = context.colors;
    final rates = [
      {'rate': 1, 'title': '1 / sec', 'subtitle': 'Relaxed (1 tick every 1000ms)'},
      {'rate': 5, 'title': '5 / sec', 'subtitle': 'Normal (1 tick every 200ms)'},
      {'rate': 10, 'title': '10 / sec', 'subtitle': 'Fast (1 tick every 100ms)'},
      {'rate': 20, 'title': '20 / sec', 'subtitle': 'Active (1 tick every 50ms)'},
      {'rate': 50, 'title': '50+ / sec', 'subtitle': 'High-Frequency / Stress test (20ms)'},
    ];

    showModalBottomSheet<void>(
      context: context,
      backgroundColor: colors.surfaceElevated,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 36,
                    height: 4,
                    decoration: BoxDecoration(
                      color: colors.divider,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Market Feed Tick Rate',
                        style: TextStyle(
                          fontFamily: 'Hanken Grotesk',
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: colors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Controls real-time price update frequency',
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 13,
                          color: colors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                Divider(height: 1, thickness: 1, color: colors.divider),
                for (final item in rates) ...[
                  ListTile(
                    leading: Icon(
                      (item['rate'] as int) == currentRate
                          ? Icons.radio_button_checked
                          : Icons.radio_button_off,
                      color: (item['rate'] as int) == currentRate
                          ? colors.primary
                          : colors.textMuted,
                    ),
                    title: Text(
                      item['title'] as String,
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 15,
                        fontWeight: (item['rate'] as int) == currentRate
                            ? FontWeight.w700
                            : FontWeight.w500,
                        color: colors.textPrimary,
                      ),
                    ),
                    subtitle: Text(
                      item['subtitle'] as String,
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 12,
                        color: colors.textSecondary,
                      ),
                    ),
                    onTap: () {
                      final rate = item['rate'] as int;
                      ref.read(tickRateProvider.notifier).setTickRate(rate);
                      Navigator.of(ctx).pop();
                    },
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  void _showAboutModal(BuildContext context) {
    final colors = context.colors;
    showDialog<void>(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.54),
      builder: (ctx) => AlertDialog(
        backgroundColor: colors.surfaceElevated,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: colors.border),
        ),
        titlePadding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
        contentPadding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
        actionsPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        title: Row(
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.asset(
                  'assets/icon/app_icon.png',
                  fit: BoxFit.cover,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '021 Trading App',
                  style: TextStyle(
                    fontFamily: 'Hanken Grotesk',
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: colors.textPrimary,
                  ),
                ),
                Text(
                  'Version 1.0.0 (Build 1)',
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 12,
                    color: colors.textSecondary,
                  ),
                ),
              ],
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Divider(height: 1, thickness: 1, color: colors.divider),
            const SizedBox(height: 12),
            Text(
              'A high-performance simulated trading application built with Flutter, Riverpod, and the Google Stitch design system.',
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 13,
                color: colors.textSecondary,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Features:',
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: colors.textPrimary,
              ),
            ),
            const SizedBox(height: 6),
            _buildFeatureBullet(context, 'Real-time mock market feed with customizable tick rates'),
            _buildFeatureBullet(context, 'Watchlists with CRUD, drag-reorder & swipe-to-remove'),
            _buildFeatureBullet(context, 'Instant order execution & full order history'),
            _buildFeatureBullet(context, 'Live portfolio holdings & P&L calculation'),
            _buildFeatureBullet(context, 'Google Sign-In & custom profile photos'),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: colors.chipBackground,
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                'Simulated trading. No real money or financial risk involved.',
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                  color: colors.textMuted,
                ),
              ),
            ),
          ],
        ),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.of(ctx).pop(),
            style: ElevatedButton.styleFrom(
              backgroundColor: colors.primary,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text(
              'Close',
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureBullet(BuildContext context, String text) {
    final colors = context.colors;
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('• ', style: TextStyle(color: colors.primary, fontWeight: FontWeight.bold)),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 12,
                color: colors.textSecondary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authStateProvider);
    final watchlistState = ref.watch(watchlistProvider);
    final holdings = ref.watch(holdingsProvider);
    final orders = ref.watch(orderHistoryProvider);
    final tickRate = ref.watch(tickRateProvider);
    final walletBalancePaise = ref.watch(walletBalancePaiseProvider);
    final colors = context.colors;
    final isDark = context.isDark;

    final activeHoldings = holdings.values.where((h) => h.quantityUnits > 0);
    final holdingsCount = activeHoldings.length;
    final totalInvestedPaise = activeHoldings.fold<int>(0, (sum, h) => sum + h.investedValuePaise);
    final watchlistCount = watchlistState.watchlists.length;

    final textDark = colors.textPrimary;
    final textGrey = colors.textSecondary;
    final borderGrey = colors.border;
    final cardBg = colors.surfaceElevated;
    final chevronColor = colors.textMuted;
    final hairline = colors.divider;

    final displayName = user?.displayTitle ?? 'Rahul Sharma';
    final displaySubtitle = user?.displaySubtitle ?? '+91 98765 43210';
    final clientId = user?.clientId ?? '021RS4821';

    return Scaffold(
      backgroundColor: colors.background,
      appBar: TradingAppBar.secondary(
        title: 'Profile',
        actions: const [],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 12),

              // Block 1 — Identity Card
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 16),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: cardBg,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: borderGrey, width: 1),
                ),
                child: Row(
                  children: [
                    // Dynamic & Editable Profile Avatar
                    UserAvatarView(
                      user: user,
                      size: 52,
                      isEditable: true,
                      onTap: () => _showChangePhotoModal(context, ref, user),
                    ),
                    const SizedBox(width: 14),

                    // Stacked dynamic name, phone/email, Client ID
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            displayName,
                            style: TextStyle(
                              fontFamily: 'Inter',
                              fontSize: 17,
                              fontWeight: FontWeight.w600,
                              color: textDark,
                              letterSpacing: -0.2,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            displaySubtitle,
                            style: TextStyle(
                              fontFamily: 'Inter',
                              fontSize: 13,
                              color: textGrey,
                            ),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            'Client ID · $clientId',
                            style: TextStyle(
                              fontFamily: 'Inter',
                              fontSize: 11,
                              color: chevronColor,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 12),

              // Block 2 — Wallet Strip: Real-time dynamic Available Balance and Invested
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 16),
                padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
                decoration: BoxDecoration(
                  color: cardBg,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: borderGrey, width: 1),
                ),
                child: IntrinsicHeight(
                  child: Row(
                    children: [
                      // Left half: AVAILABLE BALANCE
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'AVAILABLE BALANCE',
                              style: TextStyle(
                                fontFamily: 'Inter',
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                                color: chevronColor,
                                letterSpacing: 0.4,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              MoneyFormatter.formatPaise(walletBalancePaise),
                              style: TextStyle(
                                fontFamily: 'JetBrains Mono',
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                                color: textDark,
                                fontFeatures: const [FontFeature.tabularFigures()],
                              ),
                            ),
                          ],
                        ),
                      ),

                      // 1px vertical divider
                      VerticalDivider(
                        color: hairline,
                        thickness: 1,
                        width: 24,
                      ),

                      // Right half: INVESTED
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'INVESTED',
                              style: TextStyle(
                                fontFamily: 'Inter',
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                                color: chevronColor,
                                letterSpacing: 0.4,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              MoneyFormatter.formatPaise(totalInvestedPaise),
                              style: TextStyle(
                                fontFamily: 'JetBrains Mono',
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                                color: textDark,
                                fontFeatures: const [FontFeature.tabularFigures()],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 12),

              // Block 3 — Menu List: fully interactive and connected to real app state
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: cardBg,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: borderGrey, width: 1),
                ),
                child: Column(
                  children: [
                    // Row 1: Order history
                    _buildNavRow(
                      context: context,
                      title: 'Order history',
                      trailingText: '${orders.length} orders',
                      onTap: () => context.push('/order-history'),
                    ),
                    Divider(height: 1, thickness: 1, color: hairline),

                    // Row 2: Holdings
                    _buildNavRow(
                      context: context,
                      title: 'Holdings',
                      trailingText: '$holdingsCount stocks',
                      onTap: () => context.go('/holdings'),
                    ),
                    Divider(height: 1, thickness: 1, color: hairline),

                    // Row 3: My watchlists
                    _buildNavRow(
                      context: context,
                      title: 'My watchlists',
                      trailingText: '$watchlistCount lists',
                      onTap: () {
                        showModalBottomSheet<void>(
                          context: context,
                          isScrollControlled: true,
                          backgroundColor: Colors.transparent,
                          builder: (_) => const WatchlistSelectorSheet(),
                        );
                      },
                    ),
                    Divider(height: 1, thickness: 1, color: hairline),

                    // Section Divider Label: PREFERENCES
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.fromLTRB(16, 14, 16, 6),
                      color: cardBg,
                      child: Text(
                        'PREFERENCES',
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: chevronColor,
                          letterSpacing: 0.6,
                        ),
                      ),
                    ),
                    Divider(height: 1, thickness: 1, color: hairline),

                    // Row 4: Appearance (Theme Mode Toggle)
                    _buildThemeToggleRow(
                      context: context,
                      ref: ref,
                      isDark: isDark,
                    ),
                    Divider(height: 1, thickness: 1, color: hairline),

                    // Row 5: Tick rate (Real setting adjusting MockMarketFeed)
                    _buildNavRow(
                      context: context,
                      title: 'Tick rate',
                      trailingText: '$tickRate / sec',
                      onTap: () => _showTickRateModal(context, ref, tickRate),
                    ),
                    Divider(height: 1, thickness: 1, color: hairline),

                    // Row 6: About (Real application details modal)
                    _buildNavRow(
                      context: context,
                      title: 'About',
                      trailingText: 'v1.0.0',
                      onTap: () => _showAboutModal(context),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Full-width 48pt outline button for Log Out
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: OutlinedButton(
                    onPressed: () => _showLogoutDialog(context, ref),
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: borderGrey, width: 1),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: Text(
                      'Log out',
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                        color: textDark,
                      ),
                    ),
                  ),
                ),
              ),

              // Pinned near bottom: 11pt centered footer
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 24),
                child: Center(
                  child: Text(
                    'Simulated trading. No real money involved.',
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 11,
                      color: chevronColor,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavRow({
    required BuildContext context,
    required String title,
    required String trailingText,
    required VoidCallback onTap,
  }) {
    final colors = context.colors;
    return InkWell(
      onTap: onTap,
      child: Container(
        height: 52,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Row(
          children: [
            // Left: Title
            Text(
              title,
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 15,
                fontWeight: FontWeight.w500,
                color: colors.textPrimary,
              ),
            ),
            const Spacer(),

            // Right: Trailing value
            Text(
              trailingText,
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 13,
                color: colors.textSecondary,
              ),
            ),
            const SizedBox(width: 6),

            // Chevron
            Icon(
              Icons.chevron_right,
              size: 18,
              color: colors.textMuted,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildThemeToggleRow({
    required BuildContext context,
    required WidgetRef ref,
    required bool isDark,
  }) {
    final colors = context.colors;
    return InkWell(
      onTap: () {
        ref.read(themeModeProvider.notifier).toggleTheme();
      },
      child: Container(
        height: 52,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Row(
          children: [
            Text(
              'Appearance',
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 15,
                fontWeight: FontWeight.w500,
                color: colors.textPrimary,
              ),
            ),
            const Spacer(),
            Text(
              isDark ? 'Dark Mode' : 'Light Mode',
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 13,
                color: colors.textSecondary,
              ),
            ),
            const SizedBox(width: 8),
            Icon(
              isDark ? Icons.dark_mode_outlined : Icons.light_mode_outlined,
              size: 18,
              color: colors.primary,
            ),
          ],
        ),
      ),
    );
  }
}
