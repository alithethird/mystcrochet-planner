import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../models/motif.dart';
import '../providers/project_provider.dart';
import '../services/image_cropper_service.dart';
import '../services/localization.dart';
import '../services/storage_service.dart';
import '../theme/app_theme.dart';
import 'photo_crop_dialog.dart';

class PersonalLibraryDialog extends StatefulWidget {
  final ProjectProvider? projectProvider;

  const PersonalLibraryDialog({
    super.key,
    this.projectProvider,
  });

  static Future<void> show(
    BuildContext context, {
    ProjectProvider? projectProvider,
  }) {
    return showDialog(
      context: context,
      builder: (_) => PersonalLibraryDialog(projectProvider: projectProvider),
    );
  }

  @override
  State<PersonalLibraryDialog> createState() => _PersonalLibraryDialogState();
}

class _PersonalLibraryDialogState extends State<PersonalLibraryDialog> {
  List<Motif> _motifs = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadMotifs();
  }

  Future<void> _loadMotifs() async {
    setState(() => _isLoading = true);
    final list = await StorageService.loadPersonalMotifs();
    if (mounted) {
      setState(() {
        _motifs = list;
        _isLoading = false;
      });
    }
  }

  Future<void> _addNewPhoto() async {
    final selectedSource = await showModalBottomSheet<ImageSource>(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
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
    if (bytes == null || !mounted) return;

    final result = await showDialog<Motif>(
      context: context,
      builder: (_) => PhotoCropDialog(imageBytes: bytes),
    );

    if (result != null) {
      // Refresh list
      await _loadMotifs();
    }
  }

  Future<void> _deleteMotif(Motif motif) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(t('delete')),
        content: Text(t('delete_motif_confirm')),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text(t('cancel_btn')),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red.shade700,
              foregroundColor: Colors.white,
            ),
            onPressed: () => Navigator.of(ctx).pop(true),
            child: Text(t('delete')),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await StorageService.deletePersonalMotif(motif.id);
      await _loadMotifs();
    }
  }

  void _addMotifToCurrentProject(Motif motif) {
    if (widget.projectProvider == null || widget.projectProvider!.project == null) {
      return;
    }

    final provider = widget.projectProvider!;
    final alreadyExists = provider.project!.motifs.any((m) => m.id == motif.id);

    if (alreadyExists) {
      provider.selectMotif(motif.id);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(t('already_in_project')),
          duration: const Duration(seconds: 2),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } else {
      provider.addMotif(motif);
      provider.selectMotif(motif.id);
      setState(() {});
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${motif.name}: ${t('added_to_project')}'),
          duration: const Duration(seconds: 2),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = widget.projectProvider;
    final projectMotifIds = provider?.project?.motifs.map((m) => m.id).toSet() ?? {};

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      backgroundColor: Theme.of(context).colorScheme.surface,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 680, maxHeight: 720),
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFBE8E2),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(Icons.photo_library, color: AppColors.primary),
                      ),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            t('personal_library'),
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            '${_motifs.length} ${t('square_count')}',
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      ElevatedButton.icon(
                        onPressed: _addNewPhoto,
                        icon: const Icon(Icons.add_a_photo, size: 16),
                        label: Text(
                          t('upload_new_to_library'),
                          style: const TextStyle(fontSize: 12),
                        ),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                    ],
                  ),
                ],
              ),
              const Divider(height: 24),

              // Body Content
              Expanded(
                child: _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : _motifs.isEmpty
                        ? _buildEmptyState()
                        : _buildMotifsGrid(projectMotifIds),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: const BoxDecoration(
                color: Color(0xFFF7F4EF),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.photo_album_outlined,
                size: 64,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              t('empty_personal_library'),
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              t('empty_personal_library_hint'),
              style: const TextStyle(
                fontSize: 13,
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: _addNewPhoto,
              icon: const Icon(Icons.add_a_photo),
              label: Text(t('upload_new_to_library')),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMotifsGrid(Set<String> projectMotifIds) {
    return GridView.builder(
      gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: 200,
        mainAxisExtent: 220,
        crossAxisSpacing: 14,
        mainAxisSpacing: 14,
      ),
      itemCount: _motifs.length,
      itemBuilder: (context, index) {
        final motif = _motifs[index];
        final isAlreadyInProject = projectMotifIds.contains(motif.id);

        return Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: isAlreadyInProject
                  ? AppColors.primary.withValues(alpha: 0.6)
                  : const Color(0xFFE2DCD5),
              width: isAlreadyInProject ? 2 : 1,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Photo Preview
              Expanded(
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    ClipRRect(
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(13),
                      ),
                      child: motif.photoBase64 != null
                          ? Image.memory(
                              base64Decode(motif.photoBase64!),
                              fit: BoxFit.cover,
                              filterQuality: FilterQuality.medium,
                            )
                          : Container(
                              color: const Color(0xFFF7F4EF),
                              child: const Icon(
                                Icons.image_outlined,
                                color: AppColors.textSecondary,
                              ),
                            ),
                    ),
                    // Delete button in top-right corner
                    Positioned(
                      top: 4,
                      right: 4,
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.5),
                          shape: BoxShape.circle,
                        ),
                        child: IconButton(
                          icon: const Icon(
                            Icons.delete_outline,
                            color: Colors.white,
                            size: 16,
                          ),
                          tooltip: t('delete'),
                          visualDensity: VisualDensity.compact,
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(
                            minWidth: 28,
                            minHeight: 28,
                          ),
                          onPressed: () => _deleteMotif(motif),
                        ),
                      ),
                    ),
                    // Already in project badge
                    if (isAlreadyInProject)
                      Positioned(
                        bottom: 4,
                        left: 4,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.primary,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.check,
                                size: 12,
                                color: Colors.white,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                t('active_motif'),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                  ],
                ),
              ),

              // Info & Action Bar
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      motif.name,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 6),
                    if (widget.projectProvider != null)
                      SizedBox(
                        width: double.infinity,
                        height: 28,
                        child: isAlreadyInProject
                            ? OutlinedButton(
                                style: OutlinedButton.styleFrom(
                                  padding: EdgeInsets.zero,
                                  foregroundColor: AppColors.primary,
                                ),
                                onPressed: () => _addMotifToCurrentProject(motif),
                                child: Text(
                                  t('select_color'),
                                  style: const TextStyle(fontSize: 11),
                                ),
                              )
                            : ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  padding: EdgeInsets.zero,
                                ),
                                onPressed: () => _addMotifToCurrentProject(motif),
                                child: Text(
                                  t('add_to_project'),
                                  style: const TextStyle(fontSize: 11),
                                ),
                              ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
