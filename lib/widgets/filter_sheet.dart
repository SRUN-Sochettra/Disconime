import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
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
    final primary = Theme.of(context).colorScheme.primary;

    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        border: Border(top: BorderSide(color: primary, width: 2)),
      ),
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Handle bar ──────────────────────────────────────────
          Center(
            child: Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: primary.withAlpha(128),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),

          // ── Header ─────────────────────────────────────────────
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '> FILTERS',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              if (_filter.isActive)
                TextButton(
                  onPressed: () {
                    widget.onClear();
                    Navigator.pop(context);
                  },
                  child: Text(
                    'CLEAR_ALL',
                    style: GoogleFonts.spaceMono(
                      color: Theme.of(context).colorScheme.secondary,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 16),

          // ── Scrollable filter options ───────────────────────────
          Flexible(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildFilterSection(
                    context,
                    label: 'TYPE',
                    options: AnimeFilter.typeOptions,
                    selectedValue: _filter.type,
                    onSelected: (value) {
                      setState(() {
                        _filter = _filter.copyWith(
                          type: () => _filter.type == value ? null : value,
                        );
                      });
                    },
                  ),
                  const SizedBox(height: 16),
                  _buildFilterSection(
                    context,
                    label: 'STATUS',
                    options: AnimeFilter.filterOptions,
                    selectedValue: _filter.filter,
                    onSelected: (value) {
                      setState(() {
                        _filter = _filter.copyWith(
                          filter: () =>
                              _filter.filter == value ? null : value,
                        );
                      });
                    },
                  ),
                  const SizedBox(height: 16),
                  _buildFilterSection(
                    context,
                    label: 'RATING',
                    options: AnimeFilter.ratingOptions,
                    selectedValue: _filter.rating,
                    onSelected: (value) {
                      setState(() {
                        _filter = _filter.copyWith(
                          rating: () =>
                              _filter.rating == value ? null : value,
                        );
                      });
                    },
                  ),
                  const SizedBox(height: 16),
                  _buildFilterSection(
                    context,
                    label: 'ORDER_BY',
                    options: AnimeFilter.orderByOptions,
                    selectedValue: _filter.orderBy,
                    onSelected: (value) {
                      setState(() {
                        _filter = _filter.copyWith(
                          orderBy: () =>
                              _filter.orderBy == value ? null : value,
                        );
                      });
                    },
                  ),
                  const SizedBox(height: 16),
                  _buildFilterSection(
                    context,
                    label: 'SORT',
                    options: AnimeFilter.sortOptions,
                    selectedValue: _filter.sort,
                    onSelected: (value) {
                      setState(() {
                        _filter = _filter.copyWith(
                          sort: () => _filter.sort == value ? null : value,
                        );
                      });
                    },
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),

          // ── Apply button ───────────────────────────────────────
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () {
                widget.onApply(_filter);
                Navigator.pop(context);
              },
              icon: Icon(Icons.check, color: primary, size: 18),
              label: Text(
                'APPLY_FILTERS',
                style: GoogleFonts.spaceMono(
                  color: primary,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 2,
                ),
              ),
              style: OutlinedButton.styleFrom(
                side: BorderSide(color: primary, width: 1),
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.zero,
                ),
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterSection(
    BuildContext context, {
    required String label,
    required Map<String, String> options,
    required String? selectedValue,
    required ValueChanged<String> onSelected,
  }) {
    final primary = Theme.of(context).colorScheme.primary;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '[$label]',
          style: GoogleFonts.spaceMono(
            color: primary,
            fontSize: 12,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: options.entries.map((entry) {
            final isSelected = selectedValue == entry.value;
            return GestureDetector(
              onTap: () => onSelected(entry.value),
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: isSelected ? primary.withAlpha(40) : Colors.transparent,
                  border: Border.all(
                    color: isSelected ? primary : primary.withAlpha(80),
                    width: isSelected ? 2 : 1,
                  ),
                ),
                child: Text(
                  entry.key,
                  style: GoogleFonts.spaceMono(
                    fontSize: 11,
                    color: isSelected
                        ? primary
                        : Theme.of(context).colorScheme.onSurface,
                    fontWeight:
                        isSelected ? FontWeight.bold : FontWeight.normal,
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