import 'package:flutter/material.dart';
import 'app_chrome.dart';

class SectionAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final Widget? leading;
  final List<Widget>? actions;
  final PreferredSizeWidget? bottom;
  final bool uppercase;
  final double fontSize;

  const SectionAppBar({
    super.key,
    required this.title,
    this.leading,
    this.actions,
    this.bottom,
    this.uppercase = true,
    this.fontSize = 22,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primary = theme.colorScheme.primary;

    return AppBar(
      leading: leading,
      leadingWidth: leading != null ? 56 : null,
      toolbarHeight: AppChrome.sectionAppBarHeight,
      centerTitle: false,
      titleSpacing: 24,
      elevation: 0,
      scrolledUnderElevation: 0,
      surfaceTintColor: Colors.transparent,
      title: Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Gold accent bar before title
          Container(
            width: 3,
            height: 20,
            decoration: BoxDecoration(
              color: primary,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 12),
          Text(
            uppercase ? title.toUpperCase() : title,
            style: theme.textTheme.displayLarge?.copyWith(
              fontSize: fontSize,
              letterSpacing: 2.0,
            ),
          ),
        ],
      ),
      actions: actions != null
          ? [
              ...actions!,
              const SizedBox(width: 12),
            ]
          : null,
      bottom: bottom,
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(
        AppChrome.sectionAppBarHeight +
            (bottom?.preferredSize.height ?? 0),
      );
}
