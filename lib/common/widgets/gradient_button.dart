import 'package:flutter/material.dart';
import '../constants/theme.dart';

class GradientButton extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;
  final double? height;
  final double? width;
  final Widget? leading;

  const GradientButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.height,
    this.width,
    this.leading,
  });

  @override
  Widget build(BuildContext context) {
    final gradient = AppPalette.brandGradient;

    return SizedBox(
      width: width ?? double.infinity,
      height: height ?? 52,
      child: Material(
        // ⭐ REQUIRED
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(12),
          child: Ink(
            decoration: BoxDecoration(
              gradient: gradient,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.12),
                  blurRadius: 18,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Center(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (leading != null) ...[leading!, const SizedBox(width: 10)],
                  Text(
                    label,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
