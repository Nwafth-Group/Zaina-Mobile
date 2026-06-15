import 'package:flutter/material.dart';
import '../../../../core/theme/theme.dart';
import '../../data/models/legal_model.dart';

class LegalAccordion extends StatelessWidget {
  final List<LegalSection> sections;
  final void Function(int index) onToggle;

  const LegalAccordion({
    super.key,
    required this.sections,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
      itemCount: sections.length,
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (_, i) => _AccordionItem(
        section: sections[i],
        onTap: () => onToggle(i),
      ),
    );
  }
}

class _AccordionItem extends StatelessWidget {
  final LegalSection section;
  final VoidCallback onTap;

  const _AccordionItem({
    required this.section,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeInOut,
      decoration: BoxDecoration(
        color: section.isExpanded
            ? ZienaColors.bg2
            : ZienaColors.bg2,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: section.isExpanded
              ? ZienaColors.primary.withOpacity(0.25)
              : ZienaColors.primary,
          width: section.isExpanded ? 1.2 : 0.6,
        ),
        boxShadow: section.isExpanded
            ? [
          BoxShadow(
            color: ZienaColors.primary.withOpacity(0.06),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ]
            : [],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(14),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            splashColor: ZienaColors.primary.withOpacity(0.06),
            highlightColor: Colors.transparent,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Header row ───────────────────────────────────────────
                Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 16),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          section.title,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: section.isExpanded
                                ? FontWeight.w600
                                : FontWeight.w500,
                            color: section.isExpanded
                                ? ZienaColors.textPrimary
                                : ZienaColors.textPrimary,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      // Animated chevron
                      AnimatedRotation(
                        turns: section.isExpanded ? 0.5 : 0,
                        duration: const Duration(milliseconds: 250),
                        curve: Curves.easeInOut,
                        child: Icon(
                          Icons.keyboard_arrow_down_rounded,
                          size: 22,
                          color: section.isExpanded
                              ? ZienaColors.primary
                              : ZienaColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),

                // ── Expanded content ─────────────────────────────────────
                AnimatedSize(
                  duration: const Duration(milliseconds: 250),
                  curve: Curves.easeInOut,
                  child: section.isExpanded
                      ? Column(
                    children: [
                      // Divider
                      Container(
                        height: 1,
                        margin: const EdgeInsets.symmetric(
                            horizontal: 0),
                        color: ZienaColors.primary.withOpacity(0.12),
                      ),
                      // Content
                      Padding(
                        padding: const EdgeInsets.fromLTRB(
                            16, 14, 16, 16),
                        child: Text(
                          section.content,
                          style: const TextStyle(
                            fontSize: 13,
                            color: ZienaColors.textSecondary,
                            height: 1.6,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ),
                    ],
                  )
                      : const SizedBox.shrink(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}