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
        color: Colors.black.withAlpha(130),
        shape: BoxShape.circle,
        border: Border.all(
          color: Colors.white.withAlpha(20),
          width: 0.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(40),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: IconButton(
        padding: EdgeInsets.zero,
        iconSize: 20,
        icon: Icon(
          icon,
          color: iconColor ?? Colors.white,
        ),
        onPressed: onPressed,
      ),
    );
  }
}
