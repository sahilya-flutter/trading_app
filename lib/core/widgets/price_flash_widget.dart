import 'package:flutter/material.dart';
import '../../app/theme/app_colors.dart';
import '../../features/market/domain/price_tick.dart';

class PriceFlashWidget extends StatefulWidget {
  final PriceTick? tick;
  final Widget child;
  final BorderRadius? borderRadius;
  final EdgeInsetsGeometry? padding;

  const PriceFlashWidget({
    super.key,
    required this.tick,
    required this.child,
    this.borderRadius,
    this.padding,
  });

  @override
  State<PriceFlashWidget> createState() => _PriceFlashWidgetState();
}

class _PriceFlashWidgetState extends State<PriceFlashWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Color?> _colorAnimation;
  int _lastLtp = 0;
  TickDirection _direction = TickDirection.unchanged;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _lastLtp = widget.tick?.ltpPaise ?? 0;
    _colorAnimation = AlwaysStoppedAnimation<Color?>(Colors.transparent);
  }

  void _triggerFlashAnimation(BuildContext context) {
    final colors = context.colors;
    Color targetColor = Colors.transparent;
    if (_direction == TickDirection.up) {
      targetColor = colors.gainBg.withValues(alpha: 0.85);
    } else if (_direction == TickDirection.down) {
      targetColor = colors.lossBg.withValues(alpha: 0.85);
    }

    _colorAnimation = ColorTween(
      begin: targetColor,
      end: Colors.transparent,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));

    _controller.forward(from: 0.0);
  }

  @override
  void didUpdateWidget(PriceFlashWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    final newLtp = widget.tick?.ltpPaise ?? 0;

    if (newLtp != _lastLtp && newLtp > 0 && _lastLtp > 0) {
      _direction = newLtp > _lastLtp ? TickDirection.up : TickDirection.down;
      _lastLtp = newLtp;
      if (mounted) {
        _triggerFlashAnimation(context);
      }
    } else {
      _lastLtp = newLtp;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _colorAnimation,
      builder: (context, child) {
        return Container(
          padding: widget.padding,
          decoration: BoxDecoration(
            color: _colorAnimation.value ?? Colors.transparent,
            borderRadius: widget.borderRadius ?? BorderRadius.circular(8),
          ),
          child: child,
        );
      },
      child: widget.child,
    );
  }
}
