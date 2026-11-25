import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';

/// زر كرتوني ثلاثي الأبعاد مصمم لأصابع الأطفال وممتع في اللمس
class LuluButton extends StatefulWidget {
  final String label;
  final VoidCallback onPressed;
  final Color backgroundColor;
  final Color shadowColor;
  final IconData? icon;
  final double height;
  final double? width;
  final bool isSecondary;

  const LuluButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.backgroundColor = AppColors.playfulCoral,
    this.shadowColor = const Color(0xFFD63031),
    this.icon,
    this.height = 60,
    this.width,
    this.isSecondary = false,
  });

  @override
  State<LuluButton> createState() => _LuluButtonState();
}

class _LuluButtonState extends State<LuluButton> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final double depth = widget.isSecondary ? 3.0 : 6.0;

    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) {
        setState(() => _isPressed = false);
        widget.onPressed();
      },
      onTapCancel: () => setState(() => _isPressed = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 90),
        width: widget.width,
        height: widget.height,
        margin: EdgeInsets.only(top: _isPressed ? depth : 0),
        decoration: BoxDecoration(
          color: widget.backgroundColor,
          borderRadius: BorderRadius.circular(22),
          boxShadow: [
            if (!_isPressed)
              BoxShadow(
                color: widget.shadowColor,
                offset: Offset(0, depth),
                blurRadius: 0,
              ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14),
          child: Center(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (widget.icon != null) ...[
                  Icon(
                    widget.icon,
                    color: Colors.white,
                    size: 24,
                  ),
                  const SizedBox(width: 8),
                ],
                Flexible(
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      widget.label,
                      maxLines: 1,
                      style: AppTypography.buttonText,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
