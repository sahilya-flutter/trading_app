import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../app/theme/app_colors.dart';
import 'auth_providers.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final TextEditingController _mobileController =
      TextEditingController(text: '98765 43210');
  final TextEditingController _passwordController =
      TextEditingController(text: 'password');

  final FocusNode _mobileFocusNode = FocusNode();
  final FocusNode _passwordFocusNode = FocusNode();

  bool _isPasswordObscured = true;
  String? _mobileError;
  bool _hasAttemptedSubmit = false;

  @override
  void initState() {
    super.initState();
    _mobileFocusNode.addListener(() => setState(() {}));
    _passwordFocusNode.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _mobileController.dispose();
    _passwordController.dispose();
    _mobileFocusNode.dispose();
    _passwordFocusNode.dispose();
    super.dispose();
  }

  String _cleanMobile(String raw) {
    return raw.replaceAll(RegExp(r'\D'), '');
  }

  void _validateMobile(String raw) {
    final clean = _cleanMobile(raw);
    setState(() {
      if (clean.length != 10) {
        _mobileError = 'Enter a valid 10-digit mobile number';
      } else {
        _mobileError = null;
      }
    });
  }

  void _handleSignIn() async {
    setState(() {
      _hasAttemptedSubmit = true;
    });

    final clean = _cleanMobile(_mobileController.text);
    if (clean.length != 10) {
      setState(() {
        _mobileError = 'Enter a valid 10-digit mobile number';
      });
      return;
    }

    setState(() {
      _mobileError = null;
    });

    final success = await ref
        .read(authControllerProvider.notifier)
        .signInWithMobile(
          mobile: clean,
          password: _passwordController.text,
        );

    if (success && mounted) {
      context.go('/market');
    }
  }

  void _handleGoogleSignIn() async {
    final success = await ref
        .read(authControllerProvider.notifier)
        .signInWithGoogle();

    if (success && mounted) {
      context.go('/market');
    }
  }

  void _showInfoSnackbar(String message) {
    final colors = context.colors;
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: TextStyle(color: colors.textPrimary),
        ),
        backgroundColor: colors.surfaceElevated,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _showErrorSnackbar(String message) {
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

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authControllerProvider);
    final isLoading = authState.isLoading;
    final colors = context.colors;

    ref.listen<AuthControllerState>(authControllerProvider, (prev, next) {
      if (next.errorMessage != null && next.errorMessage!.isNotEmpty) {
        _showErrorSnackbar(next.errorMessage!);
      }
    });

    final cleanMobile = _cleanMobile(_mobileController.text);
    final isMobileValid = cleanMobile.length == 10;
    final isButtonEnabled = !isLoading &&
        (_mobileError == null && (isMobileValid || !_hasAttemptedSubmit));

    final accentBlue = colors.primary;
    final textDark = colors.textPrimary;
    final textGrey = colors.textSecondary;
    final borderGrey = colors.border;
    final errorRed = colors.loss;
    final footerGrey = colors.textMuted;
    final inputBg = colors.inputFill;

    return Scaffold(
      backgroundColor: colors.background,
      body: SafeArea(
        child: Theme(
          // Override input decoration theme so no dark theme background leaks into inputs
          data: Theme.of(context).copyWith(
            inputDecorationTheme: const InputDecorationTheme(
              filled: false,
              fillColor: Colors.transparent,
            ),
          ),
          child: LayoutBuilder(
            builder: (context, constraints) {
              return SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    minHeight: constraints.maxHeight,
                  ),
                  child: IntrinsicHeight(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Generous top spacing (~80pt)
                        const SizedBox(height: 48),

                        // Brand block (left-aligned)
                        Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: accentBlue.withValues(alpha: 0.25),
                                blurRadius: 8,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Image.asset(
                              'assets/icon/app_icon.png',
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          '021 Trade',
                          style: TextStyle(
                            fontFamily: 'Hanken Grotesk',
                            fontSize: 24,
                            fontWeight: FontWeight.w700,
                            color: textDark,
                            letterSpacing: -0.5,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Sign in to continue trading',
                          style: TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 14,
                            color: textGrey,
                          ),
                        ),

                        // ~32pt gap
                        const SizedBox(height: 32),

                        // Form Fields (Dimmed if loading)
                        Opacity(
                          opacity: isLoading ? 0.5 : 1.0,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Micro-label: MOBILE NUMBER
                              Text(
                                'MOBILE NUMBER',
                                style: TextStyle(
                                  fontFamily: 'Inter',
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  color: textGrey,
                                  letterSpacing: 0.4,
                                ),
                              ),
                              const SizedBox(height: 6),

                              // Mobile field: 56pt, 8pt radius, background
                              Container(
                                height: 56,
                                decoration: BoxDecoration(
                                  color: inputBg,
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(
                                    color: _mobileError != null
                                        ? errorRed
                                        : (_mobileFocusNode.hasFocus
                                            ? accentBlue
                                            : borderGrey),
                                    width: 1,
                                  ),
                                ),
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 14),
                                child: Row(
                                  children: [
                                    // Fixed non-editable "+91" prefix
                                    Text(
                                      '+91',
                                      style: TextStyle(
                                        fontFamily: 'Inter',
                                        fontSize: 16,
                                        fontWeight: FontWeight.w500,
                                        color: textGrey,
                                      ),
                                    ),
                                    const SizedBox(width: 10),

                                    // Thin 1px vertical divider
                                    Container(
                                      width: 1,
                                      height: 24,
                                      color: borderGrey,
                                    ),
                                    const SizedBox(width: 12),

                                    // Number input in 16 semibold tabular figures
                                    Expanded(
                                      child: TextField(
                                        controller: _mobileController,
                                        focusNode: _mobileFocusNode,
                                        enabled: !isLoading,
                                        cursorColor: accentBlue,
                                        keyboardType: TextInputType.phone,
                                        onChanged: (val) {
                                          if (_hasAttemptedSubmit) {
                                            _validateMobile(val);
                                          } else {
                                            setState(() {});
                                          }
                                        },
                                        style: TextStyle(
                                          fontFamily: 'JetBrains Mono',
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600,
                                          color: textDark,
                                          backgroundColor: Colors.transparent,
                                          fontFeatures: const [
                                            FontFeature.tabularFigures()
                                          ],
                                        ),
                                        decoration: InputDecoration(
                                          filled: false,
                                          fillColor: Colors.transparent,
                                          border: InputBorder.none,
                                          focusedBorder: InputBorder.none,
                                          enabledBorder: InputBorder.none,
                                          disabledBorder: InputBorder.none,
                                          contentPadding: EdgeInsets.zero,
                                          isDense: true,
                                          hintText: '98765 43210',
                                          hintStyle: TextStyle(
                                            fontFamily: 'JetBrains Mono',
                                            color: colors.textMuted,
                                            fontSize: 16,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              // Error state helper line
                              if (_mobileError != null) ...[
                                const SizedBox(height: 6),
                                Text(
                                  _mobileError!,
                                  style: TextStyle(
                                    fontFamily: 'Inter',
                                    fontSize: 12,
                                    color: errorRed,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],

                              // 16pt gap
                              const SizedBox(height: 16),

                              // Micro-label: PASSWORD
                              Text(
                                'PASSWORD',
                                style: TextStyle(
                                  fontFamily: 'Inter',
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  color: textGrey,
                                  letterSpacing: 0.4,
                                ),
                              ),
                              const SizedBox(height: 6),

                              // Password field: 56pt, 8pt radius, background
                              Container(
                                height: 56,
                                decoration: BoxDecoration(
                                  color: inputBg,
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(
                                    color: _passwordFocusNode.hasFocus
                                        ? accentBlue
                                        : borderGrey,
                                    width: 1,
                                  ),
                                ),
                                padding:
                                    const EdgeInsets.only(left: 14, right: 6),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: TextField(
                                        controller: _passwordController,
                                        focusNode: _passwordFocusNode,
                                        enabled: !isLoading,
                                        cursorColor: accentBlue,
                                        obscureText: _isPasswordObscured,
                                        obscuringCharacter: '•',
                                        style: TextStyle(
                                          fontFamily: 'Inter',
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600,
                                          color: textDark,
                                          backgroundColor: Colors.transparent,
                                          letterSpacing: 2.0,
                                        ),
                                        decoration: InputDecoration(
                                          filled: false,
                                          fillColor: Colors.transparent,
                                          border: InputBorder.none,
                                          focusedBorder: InputBorder.none,
                                          enabledBorder: InputBorder.none,
                                          disabledBorder: InputBorder.none,
                                          contentPadding: EdgeInsets.zero,
                                          isDense: true,
                                          hintText: '••••••',
                                          hintStyle: TextStyle(
                                            fontFamily: 'Inter',
                                            color: colors.textMuted,
                                            fontSize: 16,
                                            letterSpacing: 2.0,
                                          ),
                                        ),
                                      ),
                                    ),
                                    IconButton(
                                      icon: Icon(
                                        _isPasswordObscured
                                            ? Icons.visibility_outlined
                                            : Icons.visibility_off_outlined,
                                        size: 20,
                                        color: textGrey,
                                      ),
                                      onPressed: () {
                                        setState(() {
                                          _isPasswordObscured =
                                              !_isPasswordObscured;
                                        });
                                      },
                                    ),
                                  ],
                                ),
                              ),

                              // 8pt gap
                              const SizedBox(height: 8),

                              // Right-aligned "Forgot password?"
                              Align(
                                alignment: Alignment.centerRight,
                                child: GestureDetector(
                                  onTap: () => _showInfoSnackbar(
                                      'Password reset instructions sent to registered mobile.'),
                                  child: Text(
                                    'Forgot password?',
                                    style: TextStyle(
                                      fontFamily: 'Inter',
                                      fontSize: 13,
                                      fontWeight: FontWeight.w500,
                                      color: accentBlue,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

                        // 20pt gap
                        const SizedBox(height: 20),

                        // Full-width 52pt filled Sign In button
                        SizedBox(
                          width: double.infinity,
                          height: 52,
                          child: ElevatedButton(
                            onPressed: isButtonEnabled ? _handleSignIn : null,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: accentBlue,
                              disabledBackgroundColor: colors.chipBackground,
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            child: isLoading
                                ? const SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      valueColor:
                                          AlwaysStoppedAnimation<Color>(
                                              Colors.white),
                                    ),
                                  )
                                : Text(
                                    'Sign In',
                                    style: TextStyle(
                                      fontFamily: 'Inter',
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      color: isButtonEnabled
                                          ? Colors.white
                                          : footerGrey,
                                    ),
                                  ),
                          ),
                        ),

                        // 16pt gap
                        const SizedBox(height: 16),

                        // Clean "OR" Divider
                        Row(
                          children: [
                            Expanded(
                              child: Divider(
                                color: borderGrey,
                                thickness: 1,
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 14),
                              child: Text(
                                'OR',
                                style: TextStyle(
                                  fontFamily: 'Inter',
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  color: footerGrey,
                                  letterSpacing: 0.8,
                                ),
                              ),
                            ),
                            Expanded(
                              child: Divider(
                                color: borderGrey,
                                thickness: 1,
                              ),
                            ),
                          ],
                        ),

                        // 16pt gap
                        const SizedBox(height: 16),

                        // Full-width 52pt "Continue with Google" button
                        SizedBox(
                          width: double.infinity,
                          height: 52,
                          child: OutlinedButton(
                            onPressed: isLoading ? null : _handleGoogleSignIn,
                            style: OutlinedButton.styleFrom(
                              backgroundColor: colors.surface,
                              side: BorderSide(color: borderGrey, width: 1),
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const _GoogleGIcon(size: 20),
                                const SizedBox(width: 12),
                                Text(
                                  'Continue with Google',
                                  style: TextStyle(
                                    fontFamily: 'Inter',
                                    fontSize: 15,
                                    fontWeight: FontWeight.w600,
                                    color: textDark,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),

                        // 16pt gap
                        const SizedBox(height: 16),

                        // Centered "New here? Create account"
                        Center(
                          child: GestureDetector(
                            onTap: () => _showInfoSnackbar(
                                'Instant paper trading account created on sign in.'),
                            child: RichText(
                              text: TextSpan(
                                text: 'New here? ',
                                style: TextStyle(
                                  fontFamily: 'Inter',
                                  fontSize: 13,
                                  color: textGrey,
                                ),
                                children: [
                                  TextSpan(
                                    text: 'Create account',
                                    style: TextStyle(
                                      fontFamily: 'Inter',
                                      fontSize: 13,
                                      fontWeight: FontWeight.w500,
                                      color: accentBlue,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),

                        const Spacer(),

                        // Pinned near bottom safe area: 11pt footer line
                        Center(
                          child: Padding(
                            padding: const EdgeInsets.only(bottom: 12.0, top: 20.0),
                            child: Text(
                              'Simulated trading. No real money involved.',
                              style: TextStyle(
                                fontFamily: 'Inter',
                                fontSize: 11,
                                color: footerGrey,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

/// A crisp Google 4-color 'G' icon matching the official Google brand specification
class _GoogleGIcon extends StatelessWidget {
  final double size;

  const _GoogleGIcon({this.size = 20});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _GoogleGLogoPainter(),
      ),
    );
  }
}

class _GoogleGLogoPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final double w = size.width;
    final double h = size.height;
    final Offset center = Offset(w / 2, h / 2);
    final double radius = w / 2;

    // Paint configuration
    final Paint bluePaint = Paint()
      ..color = const Color(0xFF4285F4)
      ..style = PaintingStyle.fill;
    final Paint redPaint = Paint()
      ..color = const Color(0xFFEA4335)
      ..style = PaintingStyle.fill;
    final Paint yellowPaint = Paint()
      ..color = const Color(0xFFFBBC05)
      ..style = PaintingStyle.fill;
    final Paint greenPaint = Paint()
      ..color = const Color(0xFF34A853)
      ..style = PaintingStyle.fill;

    // Outer and inner paths for standard Google 4-color segmented arc
    final Path bluePath = Path()
      ..moveTo(center.dx, center.dy - radius * 0.2)
      ..lineTo(center.dx + radius, center.dy - radius * 0.2)
      ..arcTo(
        Rect.fromCircle(center: center, radius: radius),
        -0.3,
        1.1,
        false,
      )
      ..lineTo(center.dx + radius * 0.4, center.dy + radius * 0.4)
      ..arcTo(
        Rect.fromCircle(center: center, radius: radius * 0.55),
        0.8,
        -0.8,
        false,
      )
      ..close();

    final Path greenPath = Path()
      ..moveTo(center.dx + radius * 0.7, center.dy + radius * 0.7)
      ..arcTo(
        Rect.fromCircle(center: center, radius: radius),
        0.8,
        1.3,
        false,
      )
      ..lineTo(center.dx - radius * 0.35, center.dy + radius * 0.35)
      ..arcTo(
        Rect.fromCircle(center: center, radius: radius * 0.55),
        2.1,
        -1.3,
        false,
      )
      ..close();

    final Path yellowPath = Path()
      ..moveTo(center.dx - radius * 0.7, center.dy + radius * 0.7)
      ..arcTo(
        Rect.fromCircle(center: center, radius: radius),
        2.1,
        1.1,
        false,
      )
      ..lineTo(center.dx - radius * 0.35, center.dy - radius * 0.35)
      ..arcTo(
        Rect.fromCircle(center: center, radius: radius * 0.55),
        3.2,
        -1.1,
        false,
      )
      ..close();

    final Path redPath = Path()
      ..moveTo(center.dx - radius * 0.7, center.dy - radius * 0.7)
      ..arcTo(
        Rect.fromCircle(center: center, radius: radius),
        3.2,
        1.3,
        false,
      )
      ..lineTo(center.dx + radius * 0.35, center.dy - radius * 0.35)
      ..arcTo(
        Rect.fromCircle(center: center, radius: radius * 0.55),
        4.5,
        -1.3,
        false,
      )
      ..close();

    // Central crossbar for the G
    final Rect barRect = Rect.fromLTRB(
      center.dx - radius * 0.05,
      center.dy - radius * 0.22,
      center.dx + radius,
      center.dy + radius * 0.22,
    );

    canvas.drawPath(redPath, redPaint);
    canvas.drawPath(yellowPath, yellowPaint);
    canvas.drawPath(greenPath, greenPaint);
    canvas.drawPath(bluePath, bluePaint);
    canvas.drawRRect(
      RRect.fromRectAndRadius(barRect, const Radius.circular(2)),
      bluePaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
