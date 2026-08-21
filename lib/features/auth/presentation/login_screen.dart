import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
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

  void _showInfoSnackbar(String message) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: const Color(0xFF0E1621),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authControllerProvider);
    final isLoading = authState.isLoading;

    final cleanMobile = _cleanMobile(_mobileController.text);
    final isMobileValid = cleanMobile.length == 10;
    final isButtonEnabled = !isLoading && (_mobileError == null && (isMobileValid || !_hasAttemptedSubmit));

    const accentBlue = Color(0xFF1F4FD8);
    const textDark = Color(0xFF0E1621);
    const textGrey = Color(0xFF65707D);
    const borderGrey = Color(0xFFE3E7ED);
    const errorRed = Color(0xFFD93025);
    const footerGrey = Color(0xFF9AA4B0);

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
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
                      const SizedBox(height: 64),

                      // Brand block (left-aligned)
                      Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: accentBlue,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Center(
                          child: Icon(
                            Icons.trending_up,
                            color: Colors.white,
                            size: 24,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        '021 Trade',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w700,
                          color: textDark,
                          letterSpacing: -0.5,
                        ),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'Sign in to continue trading',
                        style: TextStyle(
                          fontSize: 14,
                          color: textGrey,
                        ),
                      ),

                      // ~40pt gap
                      const SizedBox(height: 40),

                      // Form Fields (Dimmed if loading)
                      Opacity(
                        opacity: isLoading ? 0.5 : 1.0,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Micro-label: MOBILE NUMBER
                            const Text(
                              'MOBILE NUMBER',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: textGrey,
                                letterSpacing: 0.4,
                              ),
                            ),
                            const SizedBox(height: 6),

                            // Mobile field: 56pt, 8pt radius
                            Container(
                              height: 56,
                              decoration: BoxDecoration(
                                color: Colors.white,
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
                              padding: const EdgeInsets.symmetric(horizontal: 14),
                              child: Row(
                                children: [
                                  // Fixed non-editable "+91" prefix
                                  const Text(
                                    '+91',
                                    style: TextStyle(
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
                                      keyboardType: TextInputType.phone,
                                      onChanged: (val) {
                                        if (_hasAttemptedSubmit) {
                                          _validateMobile(val);
                                        } else {
                                          setState(() {});
                                        }
                                      },
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                        color: textDark,
                                        fontFeatures: [
                                          FontFeature.tabularFigures()
                                        ],
                                      ),
                                      decoration: const InputDecoration(
                                        border: InputBorder.none,
                                        focusedBorder: InputBorder.none,
                                        enabledBorder: InputBorder.none,
                                        disabledBorder: InputBorder.none,
                                        contentPadding: EdgeInsets.zero,
                                        isDense: true,
                                        hintText: '98765 43210',
                                        hintStyle: TextStyle(
                                          color: Color(0xFFC4C8D0),
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
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: errorRed,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],

                            // 16pt gap
                            const SizedBox(height: 16),

                            // Micro-label: PASSWORD
                            const Text(
                              'PASSWORD',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: textGrey,
                                letterSpacing: 0.4,
                              ),
                            ),
                            const SizedBox(height: 6),

                            // Password field: 56pt, 8pt radius
                            Container(
                              height: 56,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: _passwordFocusNode.hasFocus
                                      ? accentBlue
                                      : borderGrey,
                                  width: 1,
                                ),
                              ),
                              padding: const EdgeInsets.only(left: 14, right: 6),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: TextField(
                                      controller: _passwordController,
                                      focusNode: _passwordFocusNode,
                                      enabled: !isLoading,
                                      obscureText: _isPasswordObscured,
                                      obscuringCharacter: '•',
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                        color: textDark,
                                        letterSpacing: 2.0,
                                      ),
                                      decoration: const InputDecoration(
                                        border: InputBorder.none,
                                        focusedBorder: InputBorder.none,
                                        enabledBorder: InputBorder.none,
                                        disabledBorder: InputBorder.none,
                                        contentPadding: EdgeInsets.zero,
                                        isDense: true,
                                        hintText: '••••••',
                                        hintStyle: TextStyle(
                                          color: Color(0xFFC4C8D0),
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
                                child: const Text(
                                  'Forgot password?',
                                  style: TextStyle(
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

                      // 24pt gap
                      const SizedBox(height: 24),

                      // Full-width 52pt filled button
                      SizedBox(
                        width: double.infinity,
                        height: 52,
                        child: ElevatedButton(
                          onPressed: isButtonEnabled ? _handleSignIn : null,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: accentBlue,
                            disabledBackgroundColor: borderGrey,
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
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                        Colors.white),
                                  ),
                                )
                              : Text(
                                  'Sign In',
                                  style: TextStyle(
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

                      // Centered "New here? Create account"
                      Center(
                        child: GestureDetector(
                          onTap: () => _showInfoSnackbar(
                              'Instant paper trading account created on sign in.'),
                          child: RichText(
                            text: const TextSpan(
                              text: 'New here? ',
                              style: TextStyle(
                                fontSize: 13,
                                color: textGrey,
                              ),
                              children: [
                                TextSpan(
                                  text: 'Create account',
                                  style: TextStyle(
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

                      // Pinned near bottom safe area: 11pt #9AA4B0 line
                      const Center(
                        child: Padding(
                          padding: EdgeInsets.only(bottom: 12.0, top: 24.0),
                          child: Text(
                            'Simulated trading. No real money involved.',
                            style: TextStyle(
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
    );
  }
}
