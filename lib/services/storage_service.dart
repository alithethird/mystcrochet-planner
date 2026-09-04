import 'dart:convert';
import 'dart:typed_data';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/project.dart';
import 'download_helper.dart';

class StorageService {
  static const String _projectsKey = 'mystcrochet_projects_list';

  static Future<List<CrochetProject>> loadProjects() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_projectsKey);
      if (raw == null || raw.isEmpty) return [];

      final list = jsonDecode(raw) as List<dynamic>;
      return list
          .map((item) => CrochetProject.fromJson(item as Map<String, dynamic>))
          .toList();
    } catch (e) {
      return [];
    }
  }

  static Future<void> saveProject(CrochetProject project) async {
    final prefs = await SharedPreferences.getInstance();
    final projects = await loadProjects();

    final existingIndex = projects.indexWhere((p) => p.id == project.id);
    if (existingIndex >= 0) {
      projects[existingIndex] = project.copyWith(updatedAt: DateTime.now());
    } else {
      projects.insert(0, project);
    }

    final encoded = jsonEncode(projects.map((p) => p.toJson()).toList());
    await prefs.setString(_projectsKey, encoded);
  }

  static Future<void> deleteProject(String id) async {
    final prefs = await SharedPreferences.getInstance();
    final projects = await loadProjects();
    projects.removeWhere((p) => p.id == id);

    final encoded = jsonEncode(projects.map((p) => p.toJson()).toList());
    await prefs.setString(_projectsKey, encoded);
  }

  static void exportProjectAsJson(CrochetProject project) {
    final jsonStr = const JsonEncoder.withIndent('  ').convert(project.toJson());
    final cleanName = project.name
        .toLowerCase()
        .replaceAll(RegExp(r'[^a-z0-9_]+'), '_');
    downloadText(jsonStr, '$cleanName.mystcrochet.json', 'application/json');
  }

  static CrochetProject? importProjectFromJson(String rawJson) {
    try {
      final map = jsonDecode(rawJson) as Map<String, dynamic>;
      return CrochetProject.fromJson(map);
    } catch (_) {
      return null;
    }
  }

  static void exportPngImage(Uint8List pngBytes, String fileName) {
    downloadBytes(pngBytes, fileName, 'image/png');
  }
}
