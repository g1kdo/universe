// lib/ui/components/custom_elevated_button.dart
import 'package:flutter/material.dart';

class CustomElevatedButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final Color? backgroundColor;
  final Color? textColor;
  final IconData? icon; // Optional IconData icon
  final ImageProvider? imageIcon; // Optional ImageProvider for custom image icons
  final Color? iconColor;
  final double? iconSize;

  const CustomElevatedButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.backgroundColor,
    this.textColor,
    this.icon,
    this.imageIcon, // Initialize imageIcon
    this.iconColor,
    this.iconSize,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: backgroundColor ?? const Color(0xFF957DAD),
        foregroundColor: textColor ?? Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        elevation: 5,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(
              icon,
              color: iconColor ?? textColor ?? Colors.white,
              size: iconSize,
            ),
            const SizedBox(width: 10),
          ] else if (imageIcon != null) ...[ // Render Image if imageIcon is provided
            Image(
              image: imageIcon!,
              width: iconSize ?? 24.0, // Use iconSize or a default
              height: iconSize ?? 24.0,
              color: iconColor, // Apply color tint if provided (useful for monochrome logos)
            ),
            const SizedBox(width: 10),
          ],
          Text(
            text,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: textColor ?? Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}
