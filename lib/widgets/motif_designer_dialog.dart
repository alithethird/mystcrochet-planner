import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../models/motif.dart';
import '../models/yarn_color.dart';
import '../services/image_cropper_service.dart';
import '../services/localization.dart';
import '../services/storage_service.dart';
import '../theme/app_theme.dart';
import 'motif_preview_widget.dart';
import 'photo_crop_dialog.dart';

class MotifDesignerDialog extends StatefulWidget {
  final Motif? initialMotif;

  const MotifDesignerDialog({super.key, this.initialMotif});

  @override
  State<MotifDesignerDialog> createState() => _MotifDesignerDialogState();
}

class _MotifDesignerDialogState extends State<MotifDesignerDialog> {
  late TextEditingController _nameController;
  late MotifType _selectedType;
  late MotifShape _selectedShape;
  late List<YarnColor> _rounds;
  int _activeRoundIndex = 0;

  @override
  void initState() {
    super.initState();
    final initial = widget.initialMotif;
    if (initial != null) {
      _nameController = TextEditingController(text: initial.name);
      _selectedType = initial.type;
      _selectedShape = initial.shape;
      _rounds = List.from(initial.rounds);
    } else {
      _nameController = TextEditingController(text: 'Özel Motif / Custom Motif');
      _selectedType = MotifType.classicGranny;
      _selectedShape = MotifShape.square;
      _rounds = [
        YarnColor.defaultPalette.firstWhere((c) => c.id == 'mustard'),
        YarnColor.defaultPalette.firstWhere((c) => c.id == 'terracotta'),
        YarnColor.defaultPalette.firstWhere((c) => c.id == 'sage'),
        YarnColor.defaultPalette.firstWhere((c) => c.id == 'cream'),
      ];
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _pickPhotoFromDesigner() async {
    final selectedSource = await showModalBottomSheet<ImageSource>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                t('upload_photo'),
                style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              ListTile(
                leading: const CircleAvatar(
                  backgroundColor: Color(0xFFFBE8E2),
                  child: Icon(Icons.camera_alt, color: AppColors.primary),
                ),
                title: Text(t('take_photo')),
                onTap: () => Navigator.of(ctx).pop(ImageSource.camera),
              ),
              ListTile(
                leading: const CircleAvatar(
                  backgroundColor: Color(0xFFE8EFE9),
                  child: Icon(Icons.photo_library, color: AppColors.secondary),
                ),
                title: Text(t('pick_gallery')),
                onTap: () => Navigator.of(ctx).pop(ImageSource.gallery),
              ),
            ],
          ),
        ),
      ),
    );

    if (selectedSource == null) return;

    final bytes = await ImageCropperService.pickImageBytes(source: selectedSource);
    if (bytes == null) return;

    if (!mounted) return;

    final result = await showDialog<Motif>(
      context: context,
      builder: (_) => PhotoCropDialog(
        imageBytes: bytes,
        initialName: _nameController.text.trim().isNotEmpty
            ? _nameController.text.trim()
            : null,
      ),
    );

    if (result != null && mounted) {
      Navigator.of(context).pop(result);
    }
  }

  Future<void> _pickFromPersonalLibrary() async {
    final list = await StorageService.loadPersonalMotifs();
    if (!mounted) return;

    if (list.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(t('empty_personal_library')),
          duration: const Duration(seconds: 2),
        ),
      );
      return;
    }

    final chosen = await showDialog<Motif>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(t('personal_library')),
        content: SizedBox(
          width: 400,
          height: 350,
          child: ListView.separated(
            itemCount: list.length,
            separatorBuilder: (_, _) => const Divider(),
            itemBuilder: (ctx, i) {
              final m = list[i];
              return ListTile(
                leading: MotifPreviewWidget(motif: m, size: 40, showShadow: false),
                title: Text(m.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                trailing: const Icon(Icons.arrow_forward_ios, size: 14),
                onTap: () => Navigator.of(ctx).pop(m),
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text(t('cancel_btn')),
          ),
        ],
      ),
    );

    if (chosen != null && mounted) {
      Navigator.of(context).pop(chosen);
    }
  }

  Motif get _previewMotif => Motif(
        id: widget.initialMotif?.id ?? 'temp_id',
        name: _nameController.text.trim(),
        type: _selectedType,
        shape: _selectedShape,
        rounds: _rounds,
      );

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      backgroundColor: Theme.of(context).colorScheme.surface,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 640, maxHeight: 720),
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    widget.initialMotif == null
                        ? t('new_motif')
                        : t('edit_motif'),
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Motif Name
                      TextField(
                        controller: _nameController,
                        decoration: InputDecoration(
                          labelText: t('motif_name'),
                          prefixIcon: const Icon(Icons.label_outline),
                        ),
                        onChanged: (_) => setState(() {}),
                      ),
                      const SizedBox(height: 16),

                      // Motif Type selector
                      Text(
                        t('motif_type'),
                        style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
                      ),
                      const SizedBox(height: 8),
                      SegmentedButton<MotifType>(
                        segments: const [
                          ButtonSegment(
                            value: MotifType.classicGranny,
                            label: Text('Klasik Granny'),
                            icon: Icon(Icons.grid_3x3, size: 18),
                          ),
                          ButtonSegment(
                            value: MotifType.solidGranny,
                            label: Text('Solid / Düz'),
                            icon: Icon(Icons.crop_square, size: 18),
                          ),
                          ButtonSegment(
                            value: MotifType.sunburst,
                            label: Text('Papatya / Sunburst'),
                            icon: Icon(Icons.wb_sunny_outlined, size: 18),
                          ),
                        ],
                        selected: {_selectedType},
                        onSelectionChanged: (newSelection) {
                          setState(() {
                            _selectedType = newSelection.first;
                          });
                        },
                      ),
                      const SizedBox(height: 16),

                      // Motif Shape Selector (Square, Hexagon, Pentagon, Triangle)
                      Text(
                        t('motif_shape'),
                        style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
                      ),
                      const SizedBox(height: 8),
                      SegmentedButton<MotifShape>(
                        segments: const [
                          ButtonSegment(
                            value: MotifShape.square,
                            label: Text('Kare'),
                            icon: Icon(Icons.crop_square, size: 18),
                          ),
                          ButtonSegment(
                            value: MotifShape.hexagon,
                            label: Text('Altıgen'),
                            icon: Icon(Icons.hexagon_outlined, size: 18),
                          ),
                          ButtonSegment(
                            value: MotifShape.pentagon,
                            label: Text('Beşgen'),
                            icon: Icon(Icons.pentagon_outlined, size: 18),
                          ),
                          ButtonSegment(
                            value: MotifShape.triangle,
                            label: Text('Üçgen'),
                            icon: Icon(Icons.change_history, size: 18),
                          ),
                        ],
                        selected: {_selectedShape},
                        onSelectionChanged: (newSelection) {
                          setState(() {
                            _selectedShape = newSelection.first;
                          });
                        },
                      ),
                      const SizedBox(height: 12),

                      // Option to upload/crop real photo
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                        decoration: BoxDecoration(
                          color: const Color(0xFFE8EFE9),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: const Color(0xFF7A9A83)),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.camera_alt_outlined, color: AppColors.secondary, size: 22),
                            const SizedBox(width: 10),
                            const Expanded(
                              child: Text(
                                'Kendi ördüğünüz gerçek motifin fotoğrafını kullanmak ister misiniz?',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF2C2523),
                                ),
                              ),
                            ),
                            Wrap(
                              spacing: 8,
                              runSpacing: 6,
                              children: [
                                OutlinedButton.icon(
                                  style: OutlinedButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                                    textStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                                  ),
                                  onPressed: _pickFromPersonalLibrary,
                                  icon: const Icon(Icons.photo_library_outlined, size: 15),
                                  label: Text(t('library_btn')),
                                ),
                                ElevatedButton.icon(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppColors.secondary,
                                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                    textStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                                  ),
                                  onPressed: _pickPhotoFromDesigner,
                                  icon: const Icon(Icons.upload, size: 15),
                                  label: Text(t('upload_photo')),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Live Preview & Round Selector Row
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Live Preview Box
                          Column(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(color: const Color(0xFFE2DCD5)),
                                ),
                                child: MotifPreviewWidget(
                                  motif: _previewMotif,
                                  size: 130,
                                  showShadow: true,
                                ),
                              ),
                              const SizedBox(height: 6),
                              const Text(
                                'Canlı Önizleme',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Color(0xFF756A63),
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(width: 16),

                          // Rounds Tab
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '${t('round')} Seçimi',
                                  style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
                                ),
                                const SizedBox(height: 8),
                                Wrap(
                                  spacing: 8,
                                  runSpacing: 8,
                                  children: List.generate(_rounds.length, (index) {
                                    final isSelected = _activeRoundIndex == index;
                                    final roundColor = _rounds[index].color;
                                    return ChoiceChip(
                                      label: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Container(
                                            width: 14,
                                            height: 14,
                                            decoration: BoxDecoration(
                                              color: roundColor,
                                              shape: BoxShape.circle,
                                              border: Border.all(color: Colors.black26),
                                            ),
                                          ),
                                          const SizedBox(width: 6),
                                          Text(
                                            index == 0
                                                ? t('round_center')
                                                : index == _rounds.length - 1
                                                    ? t('round_border')
                                                    : '${t('round')} ${index + 1}',
                                          ),
                                        ],
                                      ),
                                      selected: isSelected,
                                      onSelected: (selected) {
                                        if (selected) {
                                          setState(() {
                                            _activeRoundIndex = index;
                                          });
                                        }
                                      },
                                    );
                                  }),
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  '${t('selected_round_prefix')}: ${t('round')} ${_activeRoundIndex + 1} (${_rounds[_activeRoundIndex].name})',
                                  style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: Color(0xFFC86D51),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),

                      // Palette Color Grid
                      Text(
                        t('select_color'),
                        style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
                      ),
                      const SizedBox(height: 10),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: YarnColor.defaultPalette.map((yarn) {
                          final isCurrent = _rounds[_activeRoundIndex] == yarn;
                          return Tooltip(
                            message: yarn.name,
                            child: InkWell(
                              onTap: () {
                                setState(() {
                                  _rounds[_activeRoundIndex] = yarn;
                                });
                              },
                              borderRadius: BorderRadius.circular(20),
                              child: Container(
                                width: 34,
                                height: 34,
                                decoration: BoxDecoration(
                                  color: yarn.color,
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: isCurrent
                                        ? Theme.of(context).colorScheme.primary
                                        : Colors.black12,
                                    width: isCurrent ? 3 : 1,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withValues(alpha: 0.08),
                                      blurRadius: 2,
                                      offset: const Offset(0, 1),
                                    ),
                                  ],
                                ),
                                child: isCurrent
                                    ? Icon(
                                        Icons.check,
                                        size: 18,
                                        color: yarn.color.computeLuminance() > 0.5
                                            ? Colors.black87
                                            : Colors.white,
                                      )
                                    : null,
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Bottom Action Buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: Text(t('cancel_btn')),
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton(
                    onPressed: () {
                      final name = _nameController.text.trim();
                      final motif = Motif(
                        id: widget.initialMotif?.id ??
                            'motif_${DateTime.now().millisecondsSinceEpoch}',
                        name: name.isNotEmpty ? name : 'Granny Motif',
                        type: _selectedType,
                        rounds: _rounds,
                      );
                      Navigator.of(context).pop(motif);
                    },
                    child: Text(t('save_btn')),
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
