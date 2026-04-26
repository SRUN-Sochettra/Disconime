import 'package:flutter/material.dart';
import 'app_chrome.dart';

class SectionAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final Widget? leading;
  final List<Widget>? actions;
  final PreferredSizeWidget? bottom;
  final bool uppercase;
  final double fontSize;
  final double toolbarHeight;

  const SectionAppBar({
    super.key,
    required this.title,
    this.leading,
    this.actions,
    this.bottom,
    this.uppercase = true,
    this.fontSize = 24,
    this.toolbarHeight = AppChrome.sectionAppBarHeight,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AppBar(
      leading: leading,
      leadingWidth: leading != null ? 56 : null,
      toolbarHeight: toolbarHeight,
      centerTitle: false,
      titleSpacing: 20,
      elevation: 0,
      scrolledUnderElevation: 0,
      surfaceTintColor: Colors.transparent,
      title: Text(
        uppercase ? title.toUpperCase() : title,
        style: theme.textTheme.displayLarge?.copyWith(fontSize: fontSize),
      ),
      actions: actions != null
          ? [
              const SizedBox(width: 4),
              ...actions!,
              const SizedBox(width: 8),
            ]
          : null,
      bottom: bottom,
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(
        toolbarHeight + (bottom?.preferredSize.height ?? 0),
      );
}
