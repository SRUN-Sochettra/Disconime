import 'package:flutter/material.dart';
import 'app_chrome.dart';

class SubPageAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final List<Widget>? actions;
  final PreferredSizeWidget? bottom;
  final bool uppercase;

  const SubPageAppBar({
    super.key,
    required this.title,
    this.actions,
    this.bottom,
    this.uppercase = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AppBar(
      toolbarHeight: AppChrome.subPageAppBarHeight,
      centerTitle: false,
      titleSpacing: 0,
      elevation: 0,
      scrolledUnderElevation: 0,
      surfaceTintColor: Colors.transparent,
      title: Text(
        uppercase ? title.toUpperCase() : title,
        style: theme.textTheme.titleLarge?.copyWith(fontSize: 24),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
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
        AppChrome.subPageAppBarHeight +
            (bottom?.preferredSize.height ?? 0),
      );
}
