import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import '../models/motif.dart';
import '../models/project.dart';
import '../providers/project_provider.dart';
import '../services/localization.dart';
import '../services/storage_service.dart';
import '../theme/app_theme.dart';
import '../widgets/canvas_grid_widget.dart';
import '../widgets/motif_designer_dialog.dart';
import '../widgets/motif_preview_widget.dart';
import '../widgets/tally_drawer_widget.dart';
import 'package:image_picker/image_picker.dart';
import '../services/image_cropper_service.dart';
import '../widgets/photo_crop_dialog.dart';
import '../widgets/language_selector.dart';

class EditorScreen extends StatefulWidget {
  final ProjectProvider projectProvider;
  final VoidCallback onBack;

  const EditorScreen({
    super.key,
    required this.projectProvider,
    required this.onBack,
  });

  @override
  State<EditorScreen> createState() => _EditorScreenState();
}

class _EditorScreenState extends State<EditorScreen> {
  final GlobalKey _canvasKey = GlobalKey();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    widget.projectProvider.addListener(_onProviderUpdate);
    LocalizationService().addListener(_onProviderUpdate);
  }

  @override
  void dispose() {
    LocalizationService().removeListener(_onProviderUpdate);
    widget.projectProvider.removeListener(_onProviderUpdate);
    super.dispose();
  }

  void _onProviderUpdate() {
    if (mounted) {
      setState(() {});
    }
  }

  Future<void> _exportPng() async {
    try {
      final boundary =
          _canvasKey.currentContext?.findRenderObject() as RenderRepaintBoundary?;
      if (boundary == null) return;

      final image = await boundary.toImage(pixelRatio: 3.0);
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      if (byteData == null) return;

      final pngBytes = byteData.buffer.asUint8List();
      final proj = widget.projectProvider.project;
      final fileName = '${proj?.name ?? "mystcrochet"}_schema.png';
      StorageService.exportPngImage(pngBytes, fileName);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${t('export_png')} ($fileName)'),
            backgroundColor: AppColors.secondary,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('PNG dışa aktarılırken hata: $e')),
        );
      }
    }
  }

  void _openMotifDesigner({Motif? motifToEdit}) async {
    if (motifToEdit != null && motifToEdit.type == MotifType.photo) {
      _editPhotoMotif(motifToEdit);
      return;
    }

    final result = await showDialog<Motif>(
      context: context,
      builder: (_) => MotifDesignerDialog(initialMotif: motifToEdit),
    );

    if (result != null) {
      if (motifToEdit != null) {
        widget.projectProvider.updateMotif(result);
      } else {
        widget.projectProvider.addMotif(result);
      }
    }
  }

  void _editPhotoMotif(Motif motif) async {
    final nameController = TextEditingController(text: motif.name);
    final updated = await showDialog<Motif>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(t('edit_motif')),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            MotifPreviewWidget(motif: motif, size: 90, showShadow: false),
            const SizedBox(height: 16),
            TextField(
              controller: nameController,
              decoration: InputDecoration(labelText: t('motif_name')),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text(t('cancel_btn')),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(ctx).pop(motif.copyWith(name: nameController.text.trim()));
            },
            child: Text(t('save_btn')),
          ),
        ],
      ),
    );

    if (updated != null) {
      widget.projectProvider.updateMotif(updated);
    }
  }

  void _openPhotoUploadFlow({ImageSource? source}) async {
    ImageSource? selectedSource = source;
    selectedSource ??= await showModalBottomSheet<ImageSource>(
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
      builder: (_) => PhotoCropDialog(imageBytes: bytes),
    );

    if (result != null) {
      widget.projectProvider.addMotif(result);
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = widget.projectProvider;
    final project = provider.project;

    if (project == null) {
      return const Scaffold(
        body: Center(child: Text('Proje yüklenemedi.')),
      );
    }

    final currentSection = provider.currentSection;
    final sectionCounts = provider.getCurrentSectionMotifCounts();

    return Scaffold(
      key: _scaffoldKey,
      endDrawer: Drawer(
        child: TallyDrawerWidget(project: project),
      ),
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            widget.onBack();
            Navigator.of(context).pop();
          },
        ),
        title: Row(
          children: [
            Text(
              project.name,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 17),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: const Color(0xFFFBE8E2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                project.type.displayName.split(' / ').first,
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
            ),
          ],
        ),
        actions: [
          // Save Button
          TextButton.icon(
            onPressed: provider.isSaving
                ? null
                : () async {
                    await provider.saveProject();
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(t('saved_success')),
                          backgroundColor: AppColors.secondary,
                          duration: const Duration(seconds: 2),
                        ),
                      );
                    }
                  },
            icon: provider.isSaving
                ? const SizedBox(
                    width: 14,
                    height: 14,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.save_outlined, size: 18),
            label: Text(t('save_btn')),
          ),
          const SizedBox(width: 4),

          // Export Menu
          PopupMenuButton<String>(
            tooltip: t('export_btn'),
            icon: const Icon(Icons.ios_share_outlined, size: 20),
            onSelected: (value) {
              if (value == 'png') {
                _exportPng();
              } else if (value == 'json') {
                StorageService.exportProjectAsJson(project);
              }
            },
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 'png',
                child: Row(
                  children: [
                    const Icon(Icons.image_outlined, size: 18),
                    const SizedBox(width: 10),
                    Text(t('export_png')),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'json',
                child: Row(
                  children: [
                    const Icon(Icons.data_object_outlined, size: 18),
                    const SizedBox(width: 10),
                    Text(t('export_json')),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(width: 4),

          // Tally Drawer Button
          IconButton(
            tooltip: t('tally_summary'),
            icon: const Icon(Icons.analytics_outlined),
            onPressed: () => _scaffoldKey.currentState?.openEndDrawer(),
          ),

          // Language Switch
          const Padding(
            padding: EdgeInsets.only(right: 12, left: 4),
            child: Center(
              child: LanguageSelector(compact: true),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // Section Tabs (if project has multiple sections like sweater)
          if (project.sections.length > 1)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
              decoration: const BoxDecoration(
                color: Colors.white,
                border: Border(bottom: BorderSide(color: Color(0xFFE2DCD5))),
              ),
              child: Center(
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: List.generate(project.sections.length, (idx) {
                      final sec = project.sections[idx];
                      final isSelected = provider.currentSectionIndex == idx;
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4.0),
                        child: ChoiceChip(
                          selected: isSelected,
                          label: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(sec.localizedName),
                              const SizedBox(width: 6),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 6,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: isSelected
                                      ? Colors.white.withValues(alpha: 0.25)
                                      : const Color(0xFFEFE8DE),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Text(
                                  '${sec.filledSlotCount}/${sec.activeSlotCount}',
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                    color: isSelected ? Colors.white : AppColors.primary,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          onSelected: (val) {
                            if (val) provider.selectSection(idx);
                          },
                        ),
                      );
                    }),
                  ),
                ),
              ),
            ),

          // Main Canvas Area
          Expanded(
            child: currentSection != null
                ? RepaintBoundary(
                    key: _canvasKey,
                    child: CanvasGridWidget(
                      section: currentSection,
                      motifs: project.motifs,
                      onSlotTap: (r, c) => provider.updateSlot(r, c),
                    ),
                  )
                : const SizedBox.shrink(),
          ),

          // Bottom Control Panel: Motif Palette & Canvas Tools
          _buildBottomControlBar(context, provider, project, sectionCounts),
        ],
      ),
    );
  }

  Widget _buildBottomControlBar(
    BuildContext context,
    ProjectProvider provider,
    CrochetProject project,
    Map<String, int> sectionCounts,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
        border: const Border(top: BorderSide(color: Color(0xFFE2DCD5))),
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Row 1: Action Tool Buttons (Brush, Eraser, Fill, Shuffle, Clear)
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Eraser Toggle
                  OutlinedButton.icon(
                    onPressed: () => provider.toggleEraser(),
                    icon: Icon(
                      provider.isEraserMode
                          ? Icons.cleaning_services
                          : Icons.cleaning_services_outlined,
                      size: 16,
                      color: provider.isEraserMode ? Colors.white : null,
                    ),
                    label: Text(
                      'Silgi / Eraser',
                      style: TextStyle(
                        color: provider.isEraserMode ? Colors.white : null,
                      ),
                    ),
                    style: provider.isEraserMode
                        ? OutlinedButton.styleFrom(
                            backgroundColor: const Color(0xFFD36B50),
                            side: const BorderSide(color: Color(0xFFD36B50)),
                          )
                        : null,
                  ),
                  const SizedBox(width: 8),

                  // Shuffle / Randomize
                  OutlinedButton.icon(
                    onPressed: () => provider.shuffleSection(),
                    icon: const Icon(Icons.shuffle, size: 16),
                    label: Text(t('shuffle_random')),
                  ),
                  const SizedBox(width: 8),

                  // Fill All
                  OutlinedButton.icon(
                    onPressed: () => provider.fillAll(),
                    icon: const Icon(Icons.format_color_fill, size: 16),
                    label: Text(t('fill_all')),
                  ),
                  const SizedBox(width: 8),

                  // Fill Empty
                  OutlinedButton.icon(
                    onPressed: () => provider.fillAll(onlyEmpty: true),
                    icon: const Icon(Icons.format_paint_outlined, size: 16),
                    label: Text(t('fill_empty')),
                  ),
                  const SizedBox(width: 8),

                  // Clear Section
                  OutlinedButton.icon(
                    onPressed: () => provider.clearSection(),
                    icon: const Icon(Icons.delete_sweep_outlined, size: 16),
                    label: Text(t('clear_section')),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),

            // Row 2: Motif Palette
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  // Add New Motif Button
                  InkWell(
                    onTap: () => _openMotifDesigner(),
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      height: 56,
                      padding: const EdgeInsets.symmetric(horizontal: 14),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF7F3EE),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: const Color(0xFFD8D0C5),
                          style: BorderStyle.solid,
                        ),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.add, color: AppColors.primary),
                          const SizedBox(width: 6),
                          Text(
                            t('new_motif'),
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                              color: AppColors.primary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),

                  // Upload / Take Photo Motif Button
                  InkWell(
                    onTap: () => _openPhotoUploadFlow(),
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      height: 56,
                      padding: const EdgeInsets.symmetric(horizontal: 14),
                      decoration: BoxDecoration(
                        color: const Color(0xFFE8EFE9),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: const Color(0xFF7A9A83),
                          style: BorderStyle.solid,
                        ),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.add_a_photo_outlined, color: AppColors.secondary),
                          const SizedBox(width: 6),
                          Text(
                            t('upload_photo'),
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                              color: AppColors.secondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),

                  // List of Motifs
                  ...project.motifs.map((m) {
                    final isSelected =
                        !provider.isEraserMode && provider.activeMotifId == m.id;
                    final count = sectionCounts[m.id] ?? 0;

                    return Padding(
                      padding: const EdgeInsets.only(right: 10.0),
                      child: InkWell(
                        onTap: () => provider.selectMotif(m.id),
                        borderRadius: BorderRadius.circular(12),
                        child: Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: isSelected ? const Color(0xFFFBE8E2) : Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: isSelected
                                  ? AppColors.primary
                                  : const Color(0xFFE2DCD5),
                              width: isSelected ? 2 : 1,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              MotifPreviewWidget(
                                motif: m,
                                size: 44,
                                showShadow: false,
                              ),
                              const SizedBox(width: 8),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    m.name,
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12,
                                      color: isSelected
                                          ? AppColors.primaryDark
                                          : AppColors.textPrimary,
                                    ),
                                  ),
                                  Text(
                                    '$count ${t('units')}',
                                    style: const TextStyle(
                                      fontSize: 11,
                                      color: Color(0xFF756A63),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(width: 4),
                              // Edit motif mini button
                              IconButton(
                                icon: const Icon(Icons.edit_outlined, size: 14),
                                visualDensity: VisualDensity.compact,
                                padding: EdgeInsets.zero,
                                constraints: const BoxConstraints(
                                  minWidth: 24,
                                  minHeight: 24,
                                ),
                                onPressed: () => _openMotifDesigner(motifToEdit: m),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  }),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
