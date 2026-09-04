import 'package:flutter/material.dart';
import '../models/project.dart';
import '../providers/project_provider.dart';
import '../services/localization.dart';
import '../services/storage_service.dart';
import '../theme/app_theme.dart';
import 'editor_screen.dart';

class HomeScreen extends StatefulWidget {
  final ProjectProvider projectProvider;

  const HomeScreen({super.key, required this.projectProvider});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<CrochetProject> _savedProjects = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadProjects();
  }

  Future<void> _loadProjects() async {
    setState(() => _isLoading = true);
    final list = await StorageService.loadProjects();
    setState(() {
      _savedProjects = list;
      _isLoading = false;
    });
  }

  void _openProject(CrochetProject project) {
    widget.projectProvider.setProject(project);
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => EditorScreen(
          projectProvider: widget.projectProvider,
          onBack: _loadProjects,
        ),
      ),
    );
  }

  void _startBlanketDialog() {
    int rows = 6;
    int cols = 8;
    final nameController = TextEditingController(text: 'Battaniye Projem');

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Text(t('template_blanket_title')),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextField(
                controller: nameController,
                decoration: InputDecoration(labelText: t('project_name')),
              ),
              const SizedBox(height: 16),
              Text(
                'Hazır Boyutlar:',
                style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  ActionChip(
                    label: Text(t('quick_size_baby')),
                    onPressed: () => setDialogState(() {
                      rows = 5;
                      cols = 6;
                    }),
                  ),
                  ActionChip(
                    label: Text(t('quick_size_throw')),
                    onPressed: () => setDialogState(() {
                      rows = 6;
                      cols = 8;
                    }),
                  ),
                  ActionChip(
                    label: Text(t('quick_size_queen')),
                    onPressed: () => setDialogState(() {
                      rows = 8;
                      cols = 10;
                    }),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: Text('Boyut: $rows Satır x $cols Sütun (${rows * cols} Kare)'),
                  ),
                ],
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
                Navigator.of(ctx).pop();
                final proj = CrochetProject.createBlanket(
                  name: nameController.text.trim().isNotEmpty
                      ? nameController.text.trim()
                      : null,
                  rows: rows,
                  cols: cols,
                );
                _openProject(proj);
              },
              child: Text(t('create_btn')),
            ),
          ],
        ),
      ),
    );
  }

  void _startSweaterDialog() {
    final nameController = TextEditingController(text: 'Granny Hırka & Kazak');

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(t('template_sweater_title')),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: nameController,
              decoration: InputDecoration(labelText: t('project_name')),
            ),
            const SizedBox(height: 16),
            const Text(
              'Parça Dağılımı:\n• Ön Gövde: 4x5 (20 Kare)\n• Arka Gövde: 4x5 (20 Kare)\n• Kollar (Sol & Sağ): 3x4 (12 + 12 = 24 Kare)\nToplam: 64 Motif',
              style: TextStyle(height: 1.5, color: Color(0xFF756A63)),
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
              Navigator.of(ctx).pop();
              final proj = CrochetProject.createSweater(
                name: nameController.text.trim().isNotEmpty
                    ? nameController.text.trim()
                    : null,
              );
              _openProject(proj);
            },
            child: Text(t('create_btn')),
          ),
        ],
      ),
    );
  }

  void _startToteBag() {
    final proj = CrochetProject.createToteBag();
    _openProject(proj);
  }

  void _startCustomDialog() {
    int rows = 5;
    int cols = 5;
    final nameController = TextEditingController(text: 'Özel Projem');

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Text(t('template_custom_title')),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: InputDecoration(labelText: t('project_name')),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('${t('rows')}: $rows'),
                        Slider(
                          value: rows.toDouble(),
                          min: 2,
                          max: 15,
                          divisions: 13,
                          onChanged: (v) => setDialogState(() => rows = v.toInt()),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('${t('cols')}: $cols'),
                        Slider(
                          value: cols.toDouble(),
                          min: 2,
                          max: 15,
                          divisions: 13,
                          onChanged: (v) => setDialogState(() => cols = v.toInt()),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              Text(
                'Toplam: ${rows * cols} Kare',
                style: const TextStyle(fontWeight: FontWeight.bold),
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
                Navigator.of(ctx).pop();
                final proj = CrochetProject.createCustom(
                  name: nameController.text.trim().isNotEmpty
                      ? nameController.text.trim()
                      : null,
                  rows: rows,
                  cols: cols,
                );
                _openProject(proj);
              },
              child: Text(t('create_btn')),
            ),
          ],
        ),
      ),
    );
  }

  void _showImportDialog() {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(t('import_json')),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'İndirdiğiniz .mystcrochet.json dosyasının içeriğini buraya yapıştırın:',
              style: TextStyle(fontSize: 13, color: Color(0xFF756A63)),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: controller,
              maxLines: 8,
              decoration: const InputDecoration(
                hintText: '{"id": "...", "name": "...", ...}',
              ),
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
              final raw = controller.text.trim();
              final proj = StorageService.importProjectFromJson(raw);
              if (proj != null) {
                Navigator.of(ctx).pop();
                _openProject(proj);
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Geçersiz JSON formatı!')),
                );
              }
            },
            child: const Text('Yükle & Aç'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final loc = LocalizationService();

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFFFBE8E2),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.palette_outlined, color: AppColors.primary),
            ),
            const SizedBox(width: 10),
            Flexible(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    t('app_title'),
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 17),
                  ),
                  Text(
                    t('app_subtitle'),
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          // Language Switcher Button
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: OutlinedButton.icon(
              onPressed: () {
                loc.toggleLanguage();
                setState(() {});
              },
              icon: const Icon(Icons.language, size: 18),
              label: Text(loc.isTr ? 'TR ➔ EN' : 'EN ➔ TR'),
            ),
          ),
          // Import JSON button
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: TextButton.icon(
              onPressed: _showImportDialog,
              icon: const Icon(Icons.file_upload_outlined, size: 18),
              label: Text(t('import_json')),
            ),
          ),
        ],
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1100),
          child: ListView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
            children: [
              // Hero / Templates Section
              Text(
                t('new_project'),
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 16),

              LayoutBuilder(
                builder: (context, constraints) {
                  final isWide = constraints.maxWidth > 700;
                  return GridView.count(
                    crossAxisCount: isWide ? 4 : 2,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    childAspectRatio: isWide ? 1.05 : 0.95,
                    children: [
                      _TemplateCard(
                        icon: Icons.checkroom,
                        title: t('template_sweater_title'),
                        desc: t('template_sweater_desc'),
                        badge: '4 Parça',
                        color: const Color(0xFFC86D51),
                        onTap: _startSweaterDialog,
                      ),
                      _TemplateCard(
                        icon: Icons.bed,
                        title: t('template_blanket_title'),
                        desc: t('template_blanket_desc'),
                        badge: 'NxM Izgara',
                        color: const Color(0xFF7A9A83),
                        onTap: _startBlanketDialog,
                      ),
                      _TemplateCard(
                        icon: Icons.shopping_bag_outlined,
                        title: t('template_tote_title'),
                        desc: t('template_tote_desc'),
                        badge: '13 Kare',
                        color: const Color(0xFFE9B34C),
                        onTap: _startToteBag,
                      ),
                      _TemplateCard(
                        icon: Icons.grid_on,
                        title: t('template_custom_title'),
                        desc: t('template_custom_desc'),
                        badge: 'Serbest',
                        color: const Color(0xFF4A708B),
                        onTap: _startCustomDialog,
                      ),
                    ],
                  );
                },
              ),

              const SizedBox(height: 48),

              // Saved Projects Section
              Text(
                t('recent_projects'),
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 16),

              if (_isLoading)
                const Center(child: CircularProgressIndicator())
              else if (_savedProjects.isEmpty)
                Container(
                  padding: const EdgeInsets.all(32),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.gridBorder),
                  ),
                  child: Column(
                    children: [
                      const Icon(
                        Icons.dashboard_customize_outlined,
                        size: 48,
                        color: AppColors.textMuted,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        t('no_recent_projects'),
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 14,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                )
              else
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: _savedProjects.length,
                  itemBuilder: (context, index) {
                    final p = _savedProjects[index];
                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppColors.gridBorder),
                      ),
                      child: ListTile(
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 8,
                        ),
                        leading: CircleAvatar(
                          backgroundColor: const Color(0xFFFBE8E2),
                          child: Icon(
                            _iconForType(p.type),
                            color: AppColors.primary,
                          ),
                        ),
                        title: Text(
                          p.name,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        subtitle: Text(
                          '${p.type.displayName.split(' / ').first} • ${p.totalFilledSquares}/${p.totalActiveSquares} ${t('units')} • ${_formatDate(p.updatedAt)}',
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppColors.textSecondary,
                          ),
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.download_outlined, size: 20),
                              tooltip: t('export_json'),
                              onPressed: () => StorageService.exportProjectAsJson(p),
                            ),
                            IconButton(
                              icon: const Icon(
                                Icons.delete_outline,
                                size: 20,
                                color: Color(0xFFD36B50),
                              ),
                              tooltip: t('delete'),
                              onPressed: () async {
                                final confirm = await showDialog<bool>(
                                  context: context,
                                  builder: (ctx) => AlertDialog(
                                    title: Text(t('delete_project')),
                                    content: Text(t('delete_confirm')),
                                    actions: [
                                      TextButton(
                                        onPressed: () => Navigator.of(ctx).pop(false),
                                        child: Text(t('cancel_btn')),
                                      ),
                                      ElevatedButton(
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: const Color(0xFFD36B50),
                                        ),
                                        onPressed: () => Navigator.of(ctx).pop(true),
                                        child: Text(t('delete')),
                                      ),
                                    ],
                                  ),
                                );
                                if (confirm == true) {
                                  await StorageService.deleteProject(p.id);
                                  _loadProjects();
                                }
                              },
                            ),
                            const SizedBox(width: 8),
                            ElevatedButton(
                              onPressed: () => _openProject(p),
                              child: const Text('Aç / Open'),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
            ],
          ),
        ),
      ),
    );
  }

  IconData _iconForType(ProjectType type) {
    switch (type) {
      case ProjectType.blanket:
        return Icons.bed;
      case ProjectType.sweater:
        return Icons.checkroom;
      case ProjectType.toteBag:
        return Icons.shopping_bag;
      case ProjectType.custom:
        return Icons.grid_on;
    }
  }

  String _formatDate(DateTime dt) {
    return '${dt.day.toString().padLeft(2, '0')}.${dt.month.toString().padLeft(2, '0')}.${dt.year} ${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
  }
}

class _TemplateCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String desc;
  final String badge;
  final Color color;
  final VoidCallback onTap;

  const _TemplateCard({
    required this.icon,
    required this.title,
    required this.desc,
    required this.badge,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        hoverColor: color.withValues(alpha: 0.04),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(icon, color: color, size: 24),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF2ECE4),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      badge,
                      style: const TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF756A63),
                      ),
                    ),
                  ),
                ],
              ),
              const Spacer(),
              Text(
                title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                desc,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 11,
                  color: AppColors.textSecondary,
                  height: 1.3,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
