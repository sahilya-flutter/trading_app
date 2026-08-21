import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_text_styles.dart';
import 'auth_providers.dart';

class LoginScreen extends ConsumerWidget {
  const LoginScreen({super.key});

  void _onGoogleSignIn(BuildContext context, WidgetRef ref) async {
    final success =
        await ref.read(authControllerProvider.notifier).signInWithGoogle();
    if (success && context.mounted) {
      context.go('/market');
    }
  }

  void _onDemoLogin(BuildContext context, WidgetRef ref) async {
    final success =
        await ref.read(authControllerProvider.notifier).signInDemo();
    if (success && context.mounted) {
      context.go('/market');
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authControllerProvider);

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 28.0, vertical: 24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 24),

                // Glowing App Icon
                Center(
                  child: Container(
                    padding: const EdgeInsets.all(22),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [AppColors.primary, AppColors.primaryDark],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primary.withValues(alpha: 0.4),
                          blurRadius: 28,
                          spreadRadius: 4,
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.trending_up,
                      size: 54,
                      color: Colors.white,
                    ),
                  ),
                ),

                const SizedBox(height: 28),

                // App Brand Name & Subtitle
                Text(
                  '021 Trading App',
                  style: AppTextStyles.headingLarge.copyWith(
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.5,
                    fontSize: 28,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  'Realtime Indian Stock Market Simulator',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.textSecondary,
                  ),
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: 36),

                // Feature Highlights Card
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceElevated,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Column(
                    children: [
                      _buildFeatureRow(
                        icon: Icons.flash_on,
                        iconColor: Colors.amber,
                        title: 'Live Realtime Market Feed',
                        subtitle: '10 Universe stocks with micro-flash ticks',
                      ),
                      const Divider(height: 24),
                      _buildFeatureRow(
                        icon: Icons.security,
                        iconColor: AppColors.gain,
                        title: 'Zero Precision Errors',
                        subtitle: 'Precise financial integer-paise math',
                      ),
                      const Divider(height: 24),
                      _buildFeatureRow(
                        icon: Icons.account_balance_wallet_outlined,
                        iconColor: AppColors.primaryLight,
                        title: 'Virtual Paper Portfolio',
                        subtitle: '₹1,00,000 simulated starting capital',
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 36),

                // Error Message if any
                if (authState.errorMessage != null) ...[
                  Container(
                    padding: const EdgeInsets.all(12),
                    margin: const EdgeInsets.only(bottom: 16),
                    decoration: BoxDecoration(
                      color: AppColors.lossBg,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: AppColors.lossBorder),
                    ),
                    child: Text(
                      authState.errorMessage!,
                      style: const TextStyle(color: AppColors.loss, fontSize: 13),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],

                // Hero: Continue with Google (Gmail) Button
                ElevatedButton(
                  onPressed: authState.isLoading
                      ? null
                      : () => _onGoogleSignIn(context, ref),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.black87,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: authState.isLoading
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(
                            color: AppColors.primary,
                            strokeWidth: 2.5,
                          ),
                        )
                      : Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(2),
                              decoration: const BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.white,
                              ),
                              child: const Icon(
                                Icons.g_mobiledata,
                                size: 28,
                                color: Color(0xFF4285F4),
                              ),
                            ),
                            const SizedBox(width: 8),
                            const Text(
                              'Continue with Google (Gmail)',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                color: Colors.black87,
                              ),
                            ),
                          ],
                        ),
                ),

                const SizedBox(height: 14),

                // Secondary: Quick Demo Trader Login
                OutlinedButton.icon(
                  onPressed: authState.isLoading
                      ? null
                      : () => _onDemoLogin(context, ref),
                  icon: const Icon(
                    Icons.bolt,
                    color: Colors.amber,
                    size: 20,
                  ),
                  label: const Text(
                    'Quick Demo Trader Login',
                    style: TextStyle(
                      color: Colors.amber,
                      fontWeight: FontWeight.w700,
                      fontSize: 14,
                    ),
                  ),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    backgroundColor: Colors.amber.withValues(alpha: 0.08),
                    side: BorderSide(color: Colors.amber.withValues(alpha: 0.3)),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),

                const SizedBox(height: 32),

                // Supabase security footer
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.lock_outline,
                      size: 14,
                      color: AppColors.textMuted,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'Secured by Supabase Auth & Google OAuth',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.textMuted,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFeatureRow({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
  }) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: iconColor.withValues(alpha: 0.15),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, size: 20, color: iconColor),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
