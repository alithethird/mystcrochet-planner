import 'dart:convert';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import '../config/app_config.dart';
import '../models/motif.dart';
import '../services/localization.dart';
import '../services/storage_service.dart';
import '../theme/app_theme.dart';

class PhotoCropDialog extends StatefulWidget {
  final Uint8List imageBytes;
  final String? initialName;
  final String? motifIdToEdit;

  const PhotoCropDialog({
    super.key,
    required this.imageBytes,
    this.initialName,
    this.motifIdToEdit,
  });

  @override
  State<PhotoCropDialog> createState() => _PhotoCropDialogState();
}

class _PhotoCropDialogState extends State<PhotoCropDialog> {
  final GlobalKey _cropBoundaryKey = GlobalKey();
  late TextEditingController _nameController;

  int _rotationQuarterTurns = 0;
  double _zoom = 1.0;
  Offset _panOffset = Offset.zero;
  bool _isProcessing = false;
  bool _saveToLibrary = true;

  static const double _viewportSize = 280.0;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(
      text: widget.initialName ?? t('photo_motif_name_default'),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  void _rotateClockwise() {
    setState(() {
      _rotationQuarterTurns = (_rotationQuarterTurns + 1) % 4;
      // Reset pan when rotating to prevent getting lost
      _panOffset = Offset.zero;
    });
  }

  void _resetTransform() {
    setState(() {
      _rotationQuarterTurns = 0;
      _zoom = 1.0;
      _panOffset = Offset.zero;
    });
  }

  Future<void> _cropAndConfirm() async {
    if (_isProcessing) return;
    setState(() => _isProcessing = true);

    try {
      final boundary = _cropBoundaryKey.currentContext?.findRenderObject()
          as RenderRepaintBoundary?;

      if (boundary == null) {
        throw Exception('Render boundary not found');
      }

      final targetRes = AppConfig.activePhotoResolution.toDouble();
      final pixelRatio = targetRes / _viewportSize;

      final ui.Image image = await boundary.toImage(pixelRatio: pixelRatio);
      final byteData =
          await image.toByteData(format: ui.ImageByteFormat.png);

      if (byteData == null) {
        throw Exception('Failed to encode image to PNG');
      }

      final pngBytes = byteData.buffer.asUint8List();
      final base64String = base64Encode(pngBytes);

      final name = _nameController.text.trim().isNotEmpty
          ? _nameController.text.trim()
          : t('photo_motif_name_default');

      final motif = Motif(
        id: widget.motifIdToEdit ??
            'photo_motif_${DateTime.now().millisecondsSinceEpoch}',
        name: name,
        type: MotifType.photo,
        rounds: const [],
        photoBase64: base64String,
      );

      if (_saveToLibrary) {
        await StorageService.savePersonalMotif(motif);
      }

      if (mounted) {
        Navigator.of(context).pop(motif);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Kırpma hatası: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isProcessing = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final targetRes = AppConfig.activePhotoResolution;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      backgroundColor: Theme.of(context).colorScheme.surface,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 580, maxHeight: 720),
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.crop, color: AppColors.primary),
                      const SizedBox(width: 8),
                      Text(
                        t('crop_title'),
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Instructions
              Text(
                t('crop_instructions'),
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 12),

              // Motif Name Input
              TextField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: t('motif_name'),
                  prefixIcon: const Icon(Icons.photo_album_outlined),
                  isDense: true,
                ),
              ),
              const SizedBox(height: 8),

              // Save to library toggle
              InkWell(
                onTap: () => setState(() => _saveToLibrary = !_saveToLibrary),
                borderRadius: BorderRadius.circular(8),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 2.0),
                  child: Row(
                    children: [
                      SizedBox(
                        height: 24,
                        width: 24,
                        child: Checkbox(
                          value: _saveToLibrary,
                          onChanged: (val) =>
                              setState(() => _saveToLibrary = val ?? true),
                          activeColor: AppColors.primary,
                          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        t('save_to_personal_library'),
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),

              // Interactive 1:1 Crop Viewport
              Expanded(
                child: Center(
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.gridBorder),
                    ),
                    padding: const EdgeInsets.all(12),
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        // The actual cropped square
                        ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: RepaintBoundary(
                            key: _cropBoundaryKey,
                            child: Container(
                              width: _viewportSize,
                              height: _viewportSize,
                              color: Colors.white,
                              child: GestureDetector(
                                onPanUpdate: (details) {
                                  setState(() {
                                    _panOffset += details.delta;
                                  });
                                },
                                child: ClipRect(
                                  child: Stack(
                                    fit: StackFit.expand,
                                    children: [
                                      Transform.translate(
                                        offset: _panOffset,
                                        child: Transform.scale(
                                          scale: _zoom,
                                          child: RotatedBox(
                                            quarterTurns: _rotationQuarterTurns,
                                            child: Image.memory(
                                              widget.imageBytes,
                                              fit: BoxFit.cover,
                                              filterQuality: FilterQuality.medium,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),

                        // Subtle guide frame overlay
                        IgnorePointer(
                          child: Container(
                            width: _viewportSize,
                            height: _viewportSize,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: AppColors.primary.withValues(alpha: 0.6),
                                width: 2,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),

              // Controls Bar: Rotate 90, Reset, Zoom Slider
              Row(
                children: [
                  // Rotate 90° button
                  OutlinedButton.icon(
                    onPressed: _rotateClockwise,
                    icon: const Icon(Icons.rotate_right, size: 18),
                    label: Text(t('rotate_btn')),
                  ),
                  const SizedBox(width: 8),

                  // Reset button
                  IconButton(
                    tooltip: 'Sıfırla / Reset',
                    icon: const Icon(Icons.refresh, size: 20),
                    onPressed: _resetTransform,
                  ),
                  const SizedBox(width: 12),

                  // Zoom Slider
                  const Icon(Icons.zoom_in, size: 18, color: AppColors.textSecondary),
                  Expanded(
                    child: Slider(
                      value: _zoom,
                      min: 0.8,
                      max: 3.5,
                      divisions: 27,
                      label: '${(_zoom * 100).toInt()}%',
                      onChanged: (val) {
                        setState(() => _zoom = val);
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),

              // Resolution info badge
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFBE8E2),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      'Çözünürlük: ${targetRes}x$targetRes px',
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                  Text(
                    'Kaydırmak için sürükleyin',
                    style: TextStyle(
                      fontSize: 11,
                      color: AppColors.textSecondary.withValues(alpha: 0.8),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Action Buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: Text(t('cancel_btn')),
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton.icon(
                    onPressed: _isProcessing ? null : _cropAndConfirm,
                    icon: _isProcessing
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Icon(Icons.check, size: 18),
                    label: Text(t('crop_confirm')),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
