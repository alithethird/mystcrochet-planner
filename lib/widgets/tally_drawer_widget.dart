import 'package:flutter/material.dart';
import '../models/motif.dart';
import '../models/project.dart';
import '../services/localization.dart';
import 'motif_preview_widget.dart';

class TallyDrawerWidget extends StatelessWidget {
  final CrochetProject project;

  const TallyDrawerWidget({super.key, required this.project});

  @override
  Widget build(BuildContext context) {
    final totalSquares = project.totalActiveSquares;
    final filledSquares = project.totalFilledSquares;
    final emptySquares = totalSquares - filledSquares;
    final completion = totalSquares > 0 ? (filledSquares / totalSquares) : 0.0;
    final counts = project.getMotifCounts();

    return Container(
      width: 380,
      color: Theme.of(context).colorScheme.surface,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
            decoration: const BoxDecoration(
              border: Border(bottom: BorderSide(color: Color(0xFFE2DCD5))),
            ),
            child: Row(
              children: [
                const Icon(Icons.analytics_outlined, color: Color(0xFFC86D51)),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    t('tally_summary'),
                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close, size: 20),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
          ),

          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(20),
              children: [
                // Progress Card
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFFE2DCD5)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            t('completion_rate'),
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 13,
                              color: Color(0xFF756A63),
                            ),
                          ),
                          Text(
                            '%${(completion * 100).toInt()}',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              color: Color(0xFFC86D51),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: LinearProgressIndicator(
                          value: completion,
                          minHeight: 10,
                          backgroundColor: const Color(0xFFF0EAE2),
                          valueColor: const AlwaysStoppedAnimation<Color>(
                            Color(0xFFC86D51),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _StatItem(
                            label: t('total_squares'),
                            value: '$totalSquares',
                            color: const Color(0xFF2C2523),
                          ),
                          Container(width: 1, height: 28, color: const Color(0xFFE2DCD5)),
                          _StatItem(
                            label: t('filled_squares'),
                            value: '$filledSquares',
                            color: const Color(0xFF7A9A83),
                          ),
                          Container(width: 1, height: 28, color: const Color(0xFFE2DCD5)),
                          _StatItem(
                            label: t('empty_squares'),
                            value: '$emptySquares',
                            color: const Color(0xFFD36B50),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Motif Count Breakdown List
                Text(
                  t('motif_tally_breakdown'),
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2C2523),
                  ),
                ),
                const SizedBox(height: 12),

                ...project.motifs.map((motif) {
                  final count = counts[motif.id] ?? 0;
                  return Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: const Color(0xFFE2DCD5)),
                    ),
                    child: Row(
                      children: [
                        MotifPreviewWidget(
                          motif: motif,
                          size: 52,
                          showShadow: false,
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                motif.name,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                              ),
                              const SizedBox(height: 3),
                              Text(
                                motif.type.displayName.split(' / ').first,
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Color(0xFF756A63),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: count > 0
                                ? const Color(0xFFFBE8E2)
                                : const Color(0xFFF5F1EB),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            '$count ${t('units')}',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                              color: count > 0
                                  ? const Color(0xFFC86D51)
                                  : const Color(0xFFA89F99),
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                }),

                const SizedBox(height: 20),

                // Section Breakdown (if more than 1 section)
                if (project.sections.length > 1) ...[
                  const Text(
                    'Parça Bazında Dağılım',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2C2523),
                    ),
                  ),
                  const SizedBox(height: 12),
                  ...project.sections.map((sec) {
                    final secTotal = sec.activeSlotCount;
                    final secFilled = sec.filledSlotCount;
                    return Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: const Color(0xFFE2DCD5)),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            sec.name,
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 13,
                            ),
                          ),
                          Text(
                            '$secFilled / $secTotal ${t('units')}',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                              color: secFilled == secTotal
                                  ? const Color(0xFF7A9A83)
                                  : const Color(0xFFC86D51),
                            ),
                          ),
                        ],
                      ),
                    );
                  }),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _StatItem({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: const TextStyle(
            fontSize: 11,
            color: Color(0xFF756A63),
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
