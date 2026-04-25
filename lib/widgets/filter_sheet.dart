import 'package:flutter/material.dart';
import '../models/filter_model.dart';

class FilterSheet extends StatefulWidget {
  final AnimeFilter currentFilter;
  final ValueChanged<AnimeFilter> onApply;
  final VoidCallback onClear;

  const FilterSheet({
    super.key,
    required this.currentFilter,
    required this.onApply,
    required this.onClear,
  });

  @override
  State<FilterSheet> createState() => _FilterSheetState();
}

class _FilterSheetState extends State<FilterSheet> {
  late AnimeFilter _filter;

  @override
  void initState() {
    super.initState();
    _filter = widget.currentFilter;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primary = theme.colorScheme.primary;

    return Container(
      decoration: BoxDecoration(
        color: theme.scaffoldBackgroundColor,
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(24),
        ),
      ),
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Handle ───────────────────────────────────────────
          Center(
            child: Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(bottom: 20),
              decoration: BoxDecoration(
                color: theme.dividerColor,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),

          // ── Header ───────────────────────────────────────────
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Filters', style: theme.textTheme.titleMedium),
              if (_filter.isActive)
                TextButton(
                  onPressed: () {
                    widget.onClear();
                    Navigator.pop(context);
                  },
                  // FIX: Replaced direct GoogleFonts.inter() call
                  // with theme text style so it responds to theme
                  // changes and stays consistent with the rest of
                  // the app typography.
                  child: Text(
                    'Clear all',
                    style: theme.textTheme.labelMedium?.copyWith(
                      color: primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 20),

          // ── Scrollable filter sections ────────────────────────
          Flexible(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSection(
                    context,
                    label: 'Type',
                    options: AnimeFilter.typeOptions,
                    selectedValue: _filter.type,
                    onSelected: (value) => setState(() {
                      _filter = _filter.copyWith(
                        type: () => _filter.type == value ? null : value,
                      );
                    }),
                  ),
                  const SizedBox(height: 20),
                  _buildSection(
                    context,
                    label: 'Status',
                    options: AnimeFilter.filterOptions,
                    selectedValue: _filter.filter,
                    onSelected: (value) => setState(() {
                      _filter = _filter.copyWith(
                        filter: () =>
                            _filter.filter == value ? null : value,
                      );
                    }),
                  ),
                  const SizedBox(height: 20),
                  _buildSection(
                    context,
                    label: 'Rating',
                    options: AnimeFilter.ratingOptions,
                    selectedValue: _filter.rating,
                    onSelected: (value) => setState(() {
                      _filter = _filter.copyWith(
                        rating: () =>
                            _filter.rating == value ? null : value,
                      );
                    }),
                  ),
                  const SizedBox(height: 20),
                  _buildSection(
                    context,
                    label: 'Order By',
                    options: AnimeFilter.orderByOptions,
                    selectedValue: _filter.orderBy,
                    onSelected: (value) => setState(() {
                      _filter = _filter.copyWith(
                        orderBy: () =>
                            _filter.orderBy == value ? null : value,
                      );
                    }),
                  ),
                  const SizedBox(height: 20),
                  _buildSection(
                    context,
                    label: 'Sort',
                    options: AnimeFilter.sortOptions,
                    selectedValue: _filter.sort,
                    onSelected: (value) => setState(() {
                      _filter = _filter.copyWith(
                        sort: () =>
                            _filter.sort == value ? null : value,
                      );
                    }),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),

          // ── Apply button ──────────────────────────────────────
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              // FIX: AnimeFilter now has == operator so we can
              // skip the API call if nothing actually changed.
              onPressed: _filter == widget.currentFilter
                  ? null
                  : () {
                      widget.onApply(_filter);
                      Navigator.pop(context);
                    },
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              // FIX: Replaced direct GoogleFonts.inter() call with
              // theme text style.
              child: Text(
                'Apply Filters',
                style: theme.textTheme.labelMedium?.copyWith(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSection(
    BuildContext context, {
    required String label,
    required Map<String, String> options,
    required String? selectedValue,
    required ValueChanged<String> onSelected,
  }) {
    final theme = Theme.of(context);
    final primary = theme.colorScheme.primary;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label.toUpperCase(),
          style: theme.textTheme.labelSmall,
        ),
        const SizedBox(height: 10),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: options.entries.map((entry) {
            final isSelected = selectedValue == entry.value;
            return GestureDetector(
              onTap: () => onSelected(entry.value),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: isSelected
                      ? primary.withAlpha(20)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isSelected ? primary : theme.dividerColor,
                    width: isSelected ? 1.5 : 1,
                  ),
                ),
                // FIX: Replaced direct GoogleFonts.inter() call
                // with theme text style for consistency.
                child: Text(
                  entry.key,
                  style: theme.textTheme.labelSmall?.copyWith(
                    fontWeight: isSelected
                        ? FontWeight.w600
                        : FontWeight.normal,
                    color: isSelected
                        ? primary
                        : theme.colorScheme.onSurface,
                    letterSpacing: 0.3,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}