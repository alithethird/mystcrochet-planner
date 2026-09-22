import 'dart:math';
import 'package:flutter/foundation.dart';
import '../models/motif.dart';
import '../models/project.dart';
import '../services/storage_service.dart';

class ProjectProvider extends ChangeNotifier {
  CrochetProject? _project;
  int _currentSectionIndex = 0;
  String? _activeMotifId;
  bool _isEraserMode = false;
  bool _isSaving = false;

  CrochetProject? get project => _project;
  int get currentSectionIndex => _currentSectionIndex;
  String? get activeMotifId => _activeMotifId;
  bool get isEraserMode => _isEraserMode;
  bool get isSaving => _isSaving;

  ProjectSection? get currentSection {
    if (_project == null ||
        _currentSectionIndex < 0 ||
        _currentSectionIndex >= _project!.sections.length) {
      return null;
    }
    return _project!.sections[_currentSectionIndex];
  }

  Motif? get activeMotif {
    if (_project == null || _activeMotifId == null) return null;
    try {
      return _project!.motifs.firstWhere((m) => m.id == _activeMotifId);
    } catch (_) {
      return null;
    }
  }

  void setProject(CrochetProject proj) {
    _project = proj;
    _currentSectionIndex = 0;
    if (proj.motifs.isNotEmpty) {
      _activeMotifId = proj.motifs.first.id;
    } else {
      _activeMotifId = null;
    }
    _isEraserMode = false;
    notifyListeners();
  }

  void selectSection(int index) {
    if (_project != null && index >= 0 && index < _project!.sections.length) {
      _currentSectionIndex = index;
      notifyListeners();
    }
  }

  void selectMotif(String? motifId) {
    _activeMotifId = motifId;
    _isEraserMode = false;
    notifyListeners();
  }

  void toggleEraser() {
    _isEraserMode = !_isEraserMode;
    notifyListeners();
  }

  void updateSlot(int row, int col) {
    if (_project == null || currentSection == null) return;

    final targetMotifId = _isEraserMode ? null : _activeMotifId;
    final sec = currentSection!;
    final updatedSlots = sec.slots.map((s) {
      if (s.row == row && s.col == col && s.isActive) {
        return s.copyWith(motifId: targetMotifId, clearMotif: targetMotifId == null);
      }
      return s;
    }).toList();

    _updateCurrentSection(sec.copyWith(slots: updatedSlots));
  }

  void fillAll({bool onlyEmpty = false}) {
    if (_project == null || currentSection == null || _activeMotifId == null) return;

    final sec = currentSection!;
    final updatedSlots = sec.slots.map((s) {
      if (!s.isActive) return s;
      if (onlyEmpty && s.motifId != null) return s;
      return s.copyWith(motifId: _activeMotifId);
    }).toList();

    _updateCurrentSection(sec.copyWith(slots: updatedSlots));
  }

  void clearSection() {
    if (_project == null || currentSection == null) return;

    final sec = currentSection!;
    final updatedSlots = sec.slots.map((s) {
      if (!s.isActive) return s;
      return s.copyWith(clearMotif: true);
    }).toList();

    _updateCurrentSection(sec.copyWith(slots: updatedSlots));
  }

  /// Randomly distributes available motifs, minimizing adjacent duplicates
  void shuffleSection() {
    if (_project == null || currentSection == null || _project!.motifs.isEmpty) {
      return;
    }

    final sec = currentSection!;
    final motifIds = _project!.motifs.map((m) => m.id).toList();
    final random = Random();

    // Map existing slot layout
    final slotMatrix = <(int, int), GridSlot>{};
    for (final s in sec.slots) {
      slotMatrix[(s.row, s.col)] = s;
    }

    final updatedSlots = <GridSlot>[];

    for (int r = 0; r < sec.rows; r++) {
      for (int c = 0; c < sec.cols; c++) {
        final slot = slotMatrix[(r, c)];
        if (slot == null || !slot.isActive) {
          if (slot != null) updatedSlots.add(slot);
          continue;
        }

        // Check left and top neighbor motif IDs to prevent adjacent clustering
        final leftMotif = updatedSlots
            .where((s) => s.row == r && s.col == c - 1 && s.isActive)
            .firstOrNull
            ?.motifId;
        final topMotif = updatedSlots
            .where((s) => s.row == r - 1 && s.col == c && s.isActive)
            .firstOrNull
            ?.motifId;

        final candidates = motifIds.where((id) => id != leftMotif && id != topMotif).toList();
        final chosenId = candidates.isNotEmpty
            ? candidates[random.nextInt(candidates.length)]
            : motifIds[random.nextInt(motifIds.length)];

        updatedSlots.add(slot.copyWith(motifId: chosenId));
      }
    }

    _updateCurrentSection(sec.copyWith(slots: updatedSlots));
  }

  void addMotif(Motif motif) {
    if (_project == null) return;
    final list = List<Motif>.from(_project!.motifs)..add(motif);
    _project = _project!.copyWith(motifs: list, updatedAt: DateTime.now());
    _activeMotifId = motif.id;
    notifyListeners();
  }

  void updateMotif(Motif motif) {
    if (_project == null) return;
    final list = _project!.motifs.map((m) => m.id == motif.id ? motif : m).toList();
    _project = _project!.copyWith(motifs: list, updatedAt: DateTime.now());
    notifyListeners();
  }

  void deleteMotif(String motifId) {
    if (_project == null) return;
    if (_project!.motifs.length <= 1) {
      // Keep at least one motif
      return;
    }

    final list = _project!.motifs.where((m) => m.id != motifId).toList();

    // Clear removed motif from all section slots
    final updatedSections = _project!.sections.map((sec) {
      final updatedSlots = sec.slots.map((s) {
        if (s.motifId == motifId) {
          return s.copyWith(clearMotif: true);
        }
        return s;
      }).toList();
      return sec.copyWith(slots: updatedSlots);
    }).toList();

    _project = _project!.copyWith(
      motifs: list,
      sections: updatedSections,
      updatedAt: DateTime.now(),
    );

    if (_activeMotifId == motifId) {
      _activeMotifId = list.first.id;
    }
    notifyListeners();
  }

  Future<void> saveProject() async {
    if (_project == null) return;
    _isSaving = true;
    notifyListeners();

    _project = _project!.copyWith(updatedAt: DateTime.now());
    await StorageService.saveProject(_project!);

    _isSaving = false;
    notifyListeners();
  }

  void _updateCurrentSection(ProjectSection updatedSection) {
    if (_project == null) return;
    final list = List<ProjectSection>.from(_project!.sections);
    list[_currentSectionIndex] = updatedSection;
    _project = _project!.copyWith(
      sections: list,
      updatedAt: DateTime.now(),
    );
    notifyListeners();
  }

  Map<String, int> getMotifCounts() {
    return _project?.getMotifCounts() ?? {};
  }

  Map<String, int> getCurrentSectionMotifCounts() {
    final counts = <String, int>{};
    if (currentSection == null) return counts;
    for (final s in currentSection!.slots) {
      if (s.isActive && s.motifId != null) {
        counts[s.motifId!] = (counts[s.motifId!] ?? 0) + 1;
      }
    }
    return counts;
  }

  void updateSquareSize(double sizeCm) {
    if (_project == null) return;
    _project = _project!.copyWith(
      squareSizeCm: sizeCm,
      updatedAt: DateTime.now(),
    );
    notifyListeners();
  }

  void updateSweaterDimensions({
    required int bodyRows,
    required int bodyCols,
    required int sleeveRows,
    required int sleeveCols,
    double? squareSizeCm,
  }) {
    if (_project == null || _project!.type != ProjectType.sweater) return;

    final updatedSections = _project!.sections.map((sec) {
      if (sec.id == 'front' || sec.id == 'back') {
        return sec.resize(newRows: bodyRows, newCols: bodyCols);
      } else if (sec.id == 'left_sleeve' || sec.id == 'right_sleeve') {
        return sec.resize(newRows: sleeveRows, newCols: sleeveCols);
      }
      return sec;
    }).toList();

    _project = _project!.copyWith(
      sections: updatedSections,
      squareSizeCm: squareSizeCm ?? _project!.squareSizeCm,
      updatedAt: DateTime.now(),
    );
    notifyListeners();
  }

  void resizeSection(String sectionId, int newRows, int newCols) {
    if (_project == null) return;
    final updatedSections = _project!.sections.map((sec) {
      if (sec.id == sectionId) {
        return sec.resize(newRows: newRows, newCols: newCols);
      }
      return sec;
    }).toList();

    _project = _project!.copyWith(
      sections: updatedSections,
      updatedAt: DateTime.now(),
    );
    notifyListeners();
  }

  // --- Freeform Slot Management ---

  void addFreeformSlot(double posX, double posY) {
    if (_project == null || currentSection == null) return;
    final sec = currentSection!;
    final slots = List<GridSlot>.from(sec.slots);
    slots.add(GridSlot(
      row: slots.length,
      col: 0,
      motifId: _activeMotifId,
      posX: posX,
      posY: posY,
    ));
    _updateCurrentSection(sec.copyWith(slots: slots));
  }

  void moveFreeformSlot(int index, double posX, double posY) {
    if (_project == null || currentSection == null) return;
    final sec = currentSection!;
    if (index < 0 || index >= sec.slots.length) return;
    final slots = List<GridSlot>.from(sec.slots);
    slots[index] = slots[index].copyWith(posX: posX, posY: posY);
    _updateCurrentSection(sec.copyWith(slots: slots));
  }

  void updateFreeformSlotMotif(int index, String? motifId) {
    if (_project == null || currentSection == null) return;
    final sec = currentSection!;
    if (index < 0 || index >= sec.slots.length) return;
    final slots = List<GridSlot>.from(sec.slots);
    slots[index] = slots[index].copyWith(motifId: motifId, clearMotif: motifId == null);
    _updateCurrentSection(sec.copyWith(slots: slots));
  }

  void duplicateFreeformSlot(int index) {
    if (_project == null || currentSection == null) return;
    final sec = currentSection!;
    if (index < 0 || index >= sec.slots.length) return;
    final source = sec.slots[index];
    final slots = List<GridSlot>.from(sec.slots);
    slots.add(GridSlot(
      row: slots.length,
      col: 0,
      motifId: source.motifId,
      posX: (source.posX ?? 100.0) + 30.0,
      posY: (source.posY ?? 100.0) + 30.0,
    ));
    _updateCurrentSection(sec.copyWith(slots: slots));
  }

  void deleteFreeformSlot(int index) {
    if (_project == null || currentSection == null) return;
    final sec = currentSection!;
    if (index < 0 || index >= sec.slots.length) return;
    final slots = List<GridSlot>.from(sec.slots)..removeAt(index);
    _updateCurrentSection(sec.copyWith(slots: slots));
  }
}

