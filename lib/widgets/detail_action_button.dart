import 'package:flutter/material.dart';
import 'app_chrome.dart';

class DetailActionButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onPressed;
  final Color? iconColor;

  const DetailActionButton({
    super.key,
    required this.icon,
    required this.onPressed,
    this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: AppChrome.actionButtonSize,
      height: AppChrome.actionButtonSize,
      margin: const EdgeInsets.symmetric(horizontal: 4),
      decoration: BoxDecoration(
        color: Colors.black.withAlpha(AppChrome.overlayFillAlpha),
        shape: BoxShape.circle,
        border: Border.all(
          color: Colors.white.withAlpha(AppChrome.overlayBorderAlpha),
        ),
      ),
      child: IconButton(
        padding: EdgeInsets.zero,
        iconSize: 20,
        splashRadius: 20,
        icon: Icon(
          icon,
          color: iconColor ?? Colors.white,
        ),
        onPressed: onPressed,
      ),
    );
  }
}
