import 'package:flutter/material.dart';
import '../models/motif.dart';
import '../models/project.dart';
import '../services/localization.dart';
import 'motif_preview_widget.dart';

class FreeformCanvasWidget extends StatefulWidget {
  final ProjectSection section;
  final List<Motif> motifs;
  final String? activeMotifId;
  final Function(int index) onSlotTap;
  final Function(int index, double newX, double newY) onSlotMove;
  final Function(double posX, double posY) onAddSquare;
  final Function(int index) onDuplicateSquare;
  final Function(int index) onDeleteSquare;

  const FreeformCanvasWidget({
    super.key,
    required this.section,
    required this.motifs,
    this.activeMotifId,
    required this.onSlotTap,
    required this.onSlotMove,
    required this.onAddSquare,
    required this.onDuplicateSquare,
    required this.onDeleteSquare,
  });

  @override
  State<FreeformCanvasWidget> createState() => _FreeformCanvasWidgetState();
}

class _FreeformCanvasWidgetState extends State<FreeformCanvasWidget> {
  int? _selectedIndex;
  bool _snapToGrid = true;
  static const double _gridStep = 80.0;
  static const double _tileSize = 72.0;
  final TransformationController _transformationController = TransformationController();

  @override
  void dispose() {
    _transformationController.dispose();
    super.dispose();
  }

  Motif? _findMotif(String? id) {
    if (id == null) return null;
    try {
      return widget.motifs.firstWhere((m) => m.id == id);
    } catch (_) {
      return null;
    }
  }

  double _snap(double val) {
    if (!_snapToGrid) return val;
    return (val / 20.0).roundToDouble() * 20.0;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Controls Bar
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border(
              bottom: BorderSide(color: Colors.grey.withValues(alpha: 0.2)),
            ),
          ),
          child: Row(
            children: [
              Icon(Icons.design_services, size: 20, color: Theme.of(context).primaryColor),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  t('freeform_canvas_hint'),
                  style: const TextStyle(fontSize: 12, color: Color(0xFF666666)),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 8),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    t('snap_to_grid'),
                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(width: 4),
                  Switch(
                    value: _snapToGrid,
                    activeTrackColor: Theme.of(context).primaryColor,
                    onChanged: (val) => setState(() => _snapToGrid = val),
                  ),
                ],
              ),
              const SizedBox(width: 8),
              ElevatedButton.icon(
                onPressed: () {
                  widget.onAddSquare(120.0, 120.0);
                },
                icon: const Icon(Icons.add, size: 18),
                label: Text(t('add_square')),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  textStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ),

        // Interactive 2D Canvas Area
        Expanded(
          child: GestureDetector(
            onTapDown: (details) {
              setState(() => _selectedIndex = null);
            },
            onDoubleTapDown: (details) {
              final localPos = details.localPosition;
              widget.onAddSquare(_snap(localPos.dx - _tileSize / 2), _snap(localPos.dy - _tileSize / 2));
            },
            child: Container(
              color: const Color(0xFFFAF7F2),
              child: InteractiveViewer(
                transformationController: _transformationController,
                boundaryMargin: const EdgeInsets.all(500),
                minScale: 0.4,
                maxScale: 3.0,
                child: Center(
                  child: Container(
                    width: 1600,
                    height: 1200,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.04),
                          blurRadius: 20,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: CustomPaint(
                      painter: _GridPatternPainter(showGrid: _snapToGrid, step: _gridStep),
                      child: Stack(
                        clipBehavior: Clip.none,
                        children: [
                          for (int i = 0; i < widget.section.slots.length; i++) ...[
                            _buildDraggableSquare(i),
                          ],
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDraggableSquare(int index) {
    final slot = widget.section.slots[index];
    final left = slot.posX ?? (100.0 + (index % 5) * (_tileSize + 16));
    final top = slot.posY ?? (100.0 + (index ~/ 5) * (_tileSize + 16));
    final isSelected = _selectedIndex == index;
    final assignedMotif = _findMotif(slot.motifId);

    return Positioned(
      left: left,
      top: top,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          GestureDetector(
            onTap: () {
              setState(() => _selectedIndex = index);
              widget.onSlotTap(index);
            },
            onPanUpdate: (details) {
              final newX = _snap(left + details.delta.dx);
              final newY = _snap(top + details.delta.dy);
              widget.onSlotMove(index, newX, newY);
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 60),
              width: _tileSize,
              height: _tileSize,
              decoration: BoxDecoration(
                color: assignedMotif == null ? const Color(0xFFF7F3EE) : Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isSelected
                      ? Theme.of(context).primaryColor
                      : (assignedMotif == null ? const Color(0xFFDACFC4) : Colors.black12),
                  width: isSelected ? 3.0 : 1.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: isSelected
                        ? Theme.of(context).primaryColor.withValues(alpha: 0.25)
                        : Colors.black.withValues(alpha: 0.08),
                    blurRadius: isSelected ? 10 : 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: assignedMotif != null
                  ? MotifPreviewWidget(
                      motif: assignedMotif,
                      size: _tileSize,
                      showShadow: false,
                    )
                  : const Center(
                      child: Icon(
                        Icons.add_rounded,
                        size: 24,
                        color: Color(0xFFB5A99F),
                      ),
                    ),
            ),
          ),

          // Context Overlay Menu when Selected
          if (isSelected)
            Positioned(
              top: -44,
              left: -20,
              child: Material(
                elevation: 6,
                borderRadius: BorderRadius.circular(20),
                color: const Color(0xFF2C2523),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.palette_outlined, size: 16, color: Colors.white),
                        tooltip: t('active_motif'),
                        padding: const EdgeInsets.all(4),
                        constraints: const BoxConstraints(),
                        onPressed: () => widget.onSlotTap(index),
                      ),
                      IconButton(
                        icon: const Icon(Icons.copy_rounded, size: 16, color: Colors.white),
                        tooltip: t('duplicate_square'),
                        padding: const EdgeInsets.all(4),
                        constraints: const BoxConstraints(),
                        onPressed: () => widget.onDuplicateSquare(index),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete_outline, size: 16, color: Colors.redAccent),
                        tooltip: t('delete_square'),
                        padding: const EdgeInsets.all(4),
                        constraints: const BoxConstraints(),
                        onPressed: () {
                          setState(() => _selectedIndex = null);
                          widget.onDeleteSquare(index);
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _GridPatternPainter extends CustomPainter {
  final bool showGrid;
  final double step;

  _GridPatternPainter({required this.showGrid, required this.step});

  @override
  void paint(Canvas canvas, Size size) {
    if (!showGrid) return;

    final dotPaint = Paint()
      ..color = const Color(0xFFE5DDD3)
      ..strokeWidth = 2.0
      ..strokeCap = StrokeCap.round;

    for (double x = 40; x < size.width; x += 40) {
      for (double y = 40; y < size.height; y += 40) {
        canvas.drawCircle(Offset(x, y), 1.2, dotPaint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant _GridPatternPainter oldDelegate) {
    return oldDelegate.showGrid != showGrid || oldDelegate.step != step;
  }
}
