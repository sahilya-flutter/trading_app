import 'package:flutter/material.dart';
import '../../../../app/theme/app_colors.dart';

class NotificationSheet extends StatelessWidget {
  const NotificationSheet({super.key});

  static Future<void> show(BuildContext context) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const NotificationSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final sheetBg = isDark ? AppColors.darkSurface : AppColors.lightSurface;
    final onSurface = isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary;
    final onSurfaceVariant = isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;
    final outlineVariant = isDark ? AppColors.darkBorder : AppColors.lightBorder;
    final primaryColor = isDark ? AppColors.darkPrimary : AppColors.lightPrimary;
    final secondaryColor = isDark ? AppColors.darkGain : AppColors.lightGain;

    final notifications = [
      {
        'title': 'Market Opening Pulse',
        'time': '09:15 AM',
        'body': 'NSE Market open. Top active: RELIANCE, TCS, HDFCBANK.',
        'icon': Icons.insights,
        'color': primaryColor,
      },
      {
        'title': 'Order Executed',
        'time': '11:30 AM',
        'body': 'BUY 10 RELIANCE @ ₹2,845.20 executed successfully.',
        'icon': Icons.check_circle,
        'color': secondaryColor,
      },
      {
        'title': 'Price Alert Triggered',
        'time': '01:45 PM',
        'body': 'TCS crossed above ₹3,950 (+1.24%).',
        'icon': Icons.trending_up,
        'color': secondaryColor,
      },
    ];

    return Container(
      decoration: BoxDecoration(
        color: sheetBg,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        border: Border.all(color: outlineVariant, width: 1),
      ),
      padding: const EdgeInsets.only(left: 20, right: 20, top: 16, bottom: 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Drag handle
          Center(
            child: Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: outlineVariant,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Title Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Notifications',
                style: TextStyle(
                  fontFamily: 'Hanken Grotesk',
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: onSurface,
                ),
              ),
              IconButton(
                onPressed: () => Navigator.of(context).pop(),
                icon: Icon(Icons.close, color: onSurfaceVariant, size: 20),
              ),
            ],
          ),
          const SizedBox(height: 12),

          ...notifications.map((item) {
            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isDark ? AppColors.stitchSurface : const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: outlineVariant, width: 1),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: (item['color'] as Color).withValues(alpha: 0.15),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      item['icon'] as IconData,
                      size: 18,
                      color: item['color'] as Color,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              item['title'] as String,
                              style: TextStyle(
                                fontFamily: 'Inter',
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: onSurface,
                              ),
                            ),
                            Text(
                              item['time'] as String,
                              style: TextStyle(
                                fontFamily: 'Inter',
                                fontSize: 11,
                                color: onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          item['body'] as String,
                          style: TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 12,
                            color: onSurfaceVariant,
                            height: 1.3,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}
