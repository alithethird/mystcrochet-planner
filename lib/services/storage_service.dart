import 'dart:convert';
import 'dart:typed_data';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/motif.dart';
import '../models/project.dart';
import 'download_helper.dart';

class StorageService {
  static const String _projectsKey = 'mystcrochet_projects_list';
  static const String _personalMotifsKey = 'mystcrochet_personal_motifs';
  static const String _customTemplatesKey = 'mystcrochet_custom_templates';

  static Future<List<CrochetProject>> loadCustomTemplates() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_customTemplatesKey);
      if (raw == null || raw.isEmpty) return [];

      final list = jsonDecode(raw) as List<dynamic>;
      return list
          .map((item) => CrochetProject.fromJson(item as Map<String, dynamic>))
          .toList();
    } catch (e) {
      return [];
    }
  }

  static Future<void> saveCustomTemplate(CrochetProject project) async {
    final prefs = await SharedPreferences.getInstance();
    final list = await loadCustomTemplates();

    final existingIndex = list.indexWhere((p) => p.id == project.id);
    if (existingIndex >= 0) {
      list[existingIndex] = project.copyWith(updatedAt: DateTime.now());
    } else {
      list.insert(0, project);
    }

    final encoded = jsonEncode(list.map((p) => p.toJson()).toList());
    await prefs.setString(_customTemplatesKey, encoded);
  }

  static Future<void> deleteCustomTemplate(String id) async {
    final prefs = await SharedPreferences.getInstance();
    final list = await loadCustomTemplates();
    list.removeWhere((p) => p.id == id);

    final encoded = jsonEncode(list.map((p) => p.toJson()).toList());
    await prefs.setString(_customTemplatesKey, encoded);
  }

  static Future<List<Motif>> loadPersonalMotifs() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_personalMotifsKey);
      if (raw == null || raw.isEmpty) return [];

      final list = jsonDecode(raw) as List<dynamic>;
      return list
          .map((item) => Motif.fromJson(item as Map<String, dynamic>))
          .toList();
    } catch (e) {
      return [];
    }
  }

  static Future<void> savePersonalMotif(Motif motif) async {
    final prefs = await SharedPreferences.getInstance();
    final list = await loadPersonalMotifs();

    final existingIndex = list.indexWhere((m) => m.id == motif.id);
    if (existingIndex >= 0) {
      list[existingIndex] = motif;
    } else {
      list.insert(0, motif);
    }

    final encoded = jsonEncode(list.map((m) => m.toJson()).toList());
    await prefs.setString(_personalMotifsKey, encoded);
  }

  static Future<void> deletePersonalMotif(String motifId) async {
    final prefs = await SharedPreferences.getInstance();
    final list = await loadPersonalMotifs();
    list.removeWhere((m) => m.id == motifId);

    final encoded = jsonEncode(list.map((m) => m.toJson()).toList());
    await prefs.setString(_personalMotifsKey, encoded);
  }

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
