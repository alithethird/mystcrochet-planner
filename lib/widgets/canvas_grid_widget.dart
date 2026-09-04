import 'package:flutter/material.dart';
import '../models/motif.dart';
import '../models/project.dart';
import 'motif_preview_widget.dart';

class CanvasGridWidget extends StatelessWidget {
  final ProjectSection section;
  final List<Motif> motifs;
  final Function(int row, int col) onSlotTap;

  const CanvasGridWidget({
    super.key,
    required this.section,
    required this.motifs,
    required this.onSlotTap,
  });

  Motif? _findMotif(String? id) {
    if (id == null) return null;
    try {
      return motifs.firstWhere((m) => m.id == id);
    } catch (_) {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // Calculate optimal cell size to fit nicely with zoom capability
        final availableW = constraints.maxWidth - 48;
        final availableH = constraints.maxHeight - 48;

        final rawCellW = availableW / section.cols;
        final rawCellH = availableH / section.rows;
        final optimalCellSize = rawCellW < rawCellH ? rawCellW : rawCellH;
        final cellSize = optimalCellSize.clamp(54.0, 96.0);

        return InteractiveViewer(
          boundaryMargin: const EdgeInsets.all(80),
          minScale: 0.5,
          maxScale: 2.5,
          child: Center(
            child: Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.85),
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.04),
                    blurRadius: 16,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: List.generate(section.rows, (r) {
                  return Row(
                    mainAxisSize: MainAxisSize.min,
                    children: List.generate(section.cols, (c) {
                      final slot = section.slotAt(r, c);
                      if (slot == null || !slot.isActive) {
                        // Invisible placeholder for cutout shapes
                        return SizedBox(
                          width: cellSize + 8,
                          height: cellSize + 8,
                        );
                      }

                      final assignedMotif = _findMotif(slot.motifId);

                      return Padding(
                        padding: const EdgeInsets.all(4.0),
                        child: _GridCell(
                          size: cellSize,
                          motif: assignedMotif,
                          onTap: () => onSlotTap(r, c),
                        ),
                      );
                    }),
                  );
                }),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _GridCell extends StatelessWidget {
  final double size;
  final Motif? motif;
  final VoidCallback onTap;

  const _GridCell({
    required this.size,
    required this.motif,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          width: size,
          height: size,
          decoration: BoxDecoration(
            color: motif == null ? const Color(0xFFF7F3EE) : Colors.white,
            borderRadius: BorderRadius.circular(size * 0.12),
            border: Border.all(
              color: motif == null
                  ? const Color(0xFFDACFC4)
                  : Colors.transparent,
              width: 1.5,
            ),
            boxShadow: motif != null
                ? [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.06),
                      blurRadius: 3,
                      offset: const Offset(0, 1.5),
                    ),
                  ]
                : null,
          ),
          child: motif != null
              ? MotifPreviewWidget(
                  motif: motif!,
                  size: size,
                  showShadow: false,
                )
              : Center(
                  child: Icon(
                    Icons.add,
                    size: size * 0.28,
                    color: const Color(0xFFB5A99F),
                  ),
                ),
        ),
      ),
    );
  }
}
