import 'package:flutter/material.dart';

enum ButtonSize { small, medium, large }

class Button extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final IconData? icon;
  final ButtonSize size;

  const Button({
    super.key,
    required this.text,
    required this.onPressed,
    this.icon,
    this.size = ButtonSize.medium,
  });

  double _getHeight() {
    switch (size) {
      case ButtonSize.small:
        return 40;
      case ButtonSize.medium:
        return 50;
      case ButtonSize.large:
        return 60;
    }
  }

  double _getFontSize() {
    switch (size) {
      case ButtonSize.small:
        return 14;
      case ButtonSize.medium:
        return 16;
      case ButtonSize.large:
        return 18;
    }
  }

  EdgeInsets _getPadding() {
    switch (size) {
      case ButtonSize.small:
        return const EdgeInsets.symmetric(horizontal: 18, vertical: 2);
      case ButtonSize.medium:
        return const EdgeInsets.symmetric(horizontal: 20, vertical: 12);
      case ButtonSize.large:
        return const EdgeInsets.symmetric(horizontal: 24, vertical: 16);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return SizedBox(
      height: _getHeight(),
      width: size == ButtonSize.small ? null : double.infinity,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: colorScheme.primary,
          shape: RoundedRectangleBorder(
            borderRadius: size == ButtonSize.small
                ? BorderRadius.circular(200)
                : BorderRadius.circular(12),
          ),
          padding: _getPadding(),
          minimumSize: size == ButtonSize.small ? Size.zero : null,
          tapTargetSize: size == ButtonSize.small
              ? MaterialTapTargetSize.shrinkWrap
              : null,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.max,
          children: [
            if (icon != null) ...[
              Icon(icon, size: _getFontSize() + 2, color: Colors.white),
              const SizedBox(width: 10),
            ],
            Text(
              text,
              style: TextStyle(
                color: Colors.white,
                fontSize: _getFontSize(),
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
