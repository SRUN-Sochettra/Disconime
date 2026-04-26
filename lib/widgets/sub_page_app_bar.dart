import 'package:flutter/material.dart';
import 'app_chrome.dart';

class SubPageAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final List<Widget>? actions;
  final PreferredSizeWidget? bottom;

  const SubPageAppBar({
    super.key,
    required this.title,
    this.actions,
    this.bottom,
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
        title,
        style: theme.textTheme.titleLarge?.copyWith(
          fontSize: 22,
          letterSpacing: 0.5,
        ),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
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
        AppChrome.subPageAppBarHeight +
            (bottom?.preferredSize.height ?? 0),
      );
}
