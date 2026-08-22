import 'package:flutter/material.dart';
import '../../app/theme/app_colors.dart';

class TradingNavItem {
  final IconData outlinedIcon;
  final IconData activeIcon;
  final String label;

  const TradingNavItem({
    required this.outlinedIcon,
    required this.activeIcon,
    required this.label,
  });
}

class TradingBottomNav extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  static const List<TradingNavItem> items = [
    TradingNavItem(
      outlinedIcon: Icons.home_outlined,
      activeIcon: Icons.home_rounded,
      label: 'Home',
    ),
    TradingNavItem(
      outlinedIcon: Icons.featured_play_list_outlined,
      activeIcon: Icons.featured_play_list_rounded,
      label: 'Watchlist',
    ),
    TradingNavItem(
      outlinedIcon: Icons.trending_up_rounded,
      activeIcon: Icons.trending_up_rounded,
      label: 'Market',
    ),
    TradingNavItem(
      outlinedIcon: Icons.account_balance_wallet_outlined,
      activeIcon: Icons.account_balance_wallet_rounded,
      label: 'Holdings',
    ),
  ];

  const TradingBottomNav({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final bottomPadding = MediaQuery.viewPaddingOf(context).bottom;

    return SafeArea(
      top: false,
      child: Padding(
        padding: EdgeInsets.fromLTRB(16, 0, 16, bottomPadding > 0 ? 4 : 10),
        child: Container(
          height: 64,
          decoration: BoxDecoration(
            color: colors.surfaceElevated,
            borderRadius: BorderRadius.circular(22),
            border: Border.all(
              color: colors.border.withValues(alpha: 0.9),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: colors.cardShadow.withValues(alpha: 0.08),
                blurRadius: 16,
                offset: const Offset(0, 4),
                spreadRadius: 0,
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: List.generate(items.length, (index) {
              final item = items[index];
              final isSelected = index == currentIndex;

              return Expanded(
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () => onTap(index),
                    borderRadius: BorderRadius.circular(16),
                    splashColor: colors.primary.withValues(alpha: 0.1),
                    highlightColor: Colors.transparent,
                    child: Center(
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 180),
                        curve: Curves.easeInOut,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? colors.primary.withValues(alpha: 0.12)
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              isSelected ? item.activeIcon : item.outlinedIcon,
                              size: 22,
                              color: isSelected
                                  ? colors.primary
                                  : colors.textSecondary,
                            ),
                            const SizedBox(height: 3),
                            Text(
                              item.label,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontFamily: 'Inter',
                                fontSize: 11,
                                fontWeight: isSelected
                                    ? FontWeight.w700
                                    : FontWeight.w500,
                                color: isSelected
                                    ? colors.primary
                                    : colors.textSecondary,
                                letterSpacing: -0.1,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}
