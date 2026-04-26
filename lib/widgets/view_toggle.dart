import 'package:flutter/material.dart';

class ViewToggleButton extends StatelessWidget {
  final bool isGridView;
  final VoidCallback onToggle;

  const ViewToggleButton({
    super.key,
    required this.isGridView,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: Icon(
        isGridView
            ? Icons.view_list_rounded
            : Icons.grid_view_rounded,
      ),
      tooltip: isGridView ? 'List view' : 'Grid view',
      onPressed: onToggle,
    );
  }
}