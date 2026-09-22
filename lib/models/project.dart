import 'motif.dart';
import '../services/localization.dart';

enum ProjectType {
  blanket,
  sweater,
  toteBag,
  custom,
  freeform,
}

extension ProjectTypeExtension on ProjectType {
  String get displayName {
    switch (this) {
      case ProjectType.blanket:
        return t('template_blanket_title');
      case ProjectType.sweater:
        return t('template_sweater_title');
      case ProjectType.toteBag:
        return t('template_tote_title');
      case ProjectType.custom:
        return t('template_custom_title');
      case ProjectType.freeform:
        return t('template_freeform_title');
    }
  }

  String get iconName {
    switch (this) {
      case ProjectType.blanket:
        return 'bed';
      case ProjectType.sweater:
        return 'checkroom';
      case ProjectType.toteBag:
        return 'shopping_bag';
      case ProjectType.custom:
        return 'grid_on';
      case ProjectType.freeform:
        return 'design_services';
    }
  }
}

class GridSlot {
  final int row;
  final int col;
  final String? motifId;
  final bool isActive;
  final double? posX;
  final double? posY;

  const GridSlot({
    required this.row,
    required this.col,
    this.motifId,
    this.isActive = true,
    this.posX,
    this.posY,
  });

  GridSlot copyWith({
    int? row,
    int? col,
    String? motifId,
    bool? isActive,
    double? posX,
    double? posY,
    bool clearMotif = false,
  }) {
    return GridSlot(
      row: row ?? this.row,
      col: col ?? this.col,
      motifId: clearMotif ? null : (motifId ?? this.motifId),
      isActive: isActive ?? this.isActive,
      posX: posX ?? this.posX,
      posY: posY ?? this.posY,
    );
  }

  Map<String, dynamic> toJson() => {
        'row': row,
        'col': col,
        'motifId': motifId,
        'isActive': isActive,
        'posX': posX,
        'posY': posY,
      };

  factory GridSlot.fromJson(Map<String, dynamic> json) => GridSlot(
        row: (json['row'] as num).toInt(),
        col: (json['col'] as num).toInt(),
        motifId: json['motifId'] as String?,
        isActive: json['isActive'] as bool? ?? true,
        posX: (json['posX'] as num?)?.toDouble(),
        posY: (json['posY'] as num?)?.toDouble(),
      );
}

class ProjectSection {
  final String id;
  final String name;
  final int rows;
  final int cols;
  final List<GridSlot> slots;
  final bool isFreeform;

  const ProjectSection({
    required this.id,
    required this.name,
    required this.rows,
    required this.cols,
    required this.slots,
    this.isFreeform = false,
  });

  ProjectSection copyWith({
    String? id,
    String? name,
    int? rows,
    int? cols,
    List<GridSlot>? slots,
    bool? isFreeform,
  }) {
    return ProjectSection(
      id: id ?? this.id,
      name: name ?? this.name,
      rows: rows ?? this.rows,
      cols: cols ?? this.cols,
      slots: slots ?? this.slots,
      isFreeform: isFreeform ?? this.isFreeform,
    );
  }

  String get localizedName {
    final key = switch (id) {
      'front' => 'section_front',
      'back' => 'section_back',
      'left_sleeve' => 'section_left_sleeve',
      'right_sleeve' => 'section_right_sleeve',
      'blanket' || 'main_grid' => 'section_blanket',
      'tote' || 'tote_layout' => 'section_tote',
      'custom' || 'custom_grid' => 'section_custom',
      'freeform_canvas' || 'freeform' => 'template_freeform_title',
      _ => 'section_$id',
    };
    final translated = LocalizationService().tr(key);
    if (translated != key) return translated;
    return name;
  }

  int get activeSlotCount => slots.where((s) => s.isActive).length;
  int get filledSlotCount => slots.where((s) => s.isActive && s.motifId != null).length;

  GridSlot? slotAt(int r, int c) {
    try {
      return slots.firstWhere((s) => s.row == r && s.col == c);
    } catch (_) {
      return null;
    }
  }

  ProjectSection resize({required int newRows, required int newCols}) {
    final newSlots = <GridSlot>[];
    for (int r = 0; r < newRows; r++) {
      for (int c = 0; c < newCols; c++) {
        final existing = slotAt(r, c);
        if (existing != null) {
          newSlots.add(existing);
        } else {
          newSlots.add(GridSlot(row: r, col: c));
        }
      }
    }
    return copyWith(rows: newRows, cols: newCols, slots: newSlots);
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'rows': rows,
        'cols': cols,
        'isFreeform': isFreeform,
        'slots': slots.map((s) => s.toJson()).toList(),
      };

  factory ProjectSection.fromJson(Map<String, dynamic> json) => ProjectSection(
        id: json['id'] as String,
        name: json['name'] as String,
        rows: (json['rows'] as num).toInt(),
        cols: (json['cols'] as num).toInt(),
        isFreeform: json['isFreeform'] as bool? ?? false,
        slots: (json['slots'] as List<dynamic>)
            .map((s) => GridSlot.fromJson(s as Map<String, dynamic>))
            .toList(),
      );
}

class CrochetProject {
  final String id;
  final String name;
  final ProjectType type;
  final List<ProjectSection> sections;
  final List<Motif> motifs;
  final DateTime createdAt;
  final DateTime updatedAt;
  final double? squareSizeCm;

  const CrochetProject({
    required this.id,
    required this.name,
    required this.type,
    required this.sections,
    required this.motifs,
    required this.createdAt,
    required this.updatedAt,
    this.squareSizeCm = 10.0,
  });

  CrochetProject copyWith({
    String? id,
    String? name,
    ProjectType? type,
    List<ProjectSection>? sections,
    List<Motif>? motifs,
    DateTime? createdAt,
    DateTime? updatedAt,
    double? squareSizeCm,
  }) {
    return CrochetProject(
      id: id ?? this.id,
      name: name ?? this.name,
      type: type ?? this.type,
      sections: sections ?? this.sections,
      motifs: motifs ?? this.motifs,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      squareSizeCm: squareSizeCm ?? this.squareSizeCm,
    );
  }

  int get totalActiveSquares =>
      sections.fold(0, (sum, sec) => sum + sec.activeSlotCount);

  int get totalFilledSquares =>
      sections.fold(0, (sum, sec) => sum + sec.filledSlotCount);

  Map<String, int> getMotifCounts() {
    final counts = <String, int>{};
    for (final sec in sections) {
      for (final slot in sec.slots) {
        if (slot.isActive && slot.motifId != null) {
          counts[slot.motifId!] = (counts[slot.motifId!] ?? 0) + 1;
        }
      }
    }
    return counts;
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'type': type.name,
        'sections': sections.map((s) => s.toJson()).toList(),
        'motifs': motifs.map((m) => m.toJson()).toList(),
        'createdAt': createdAt.toIso8601String(),
        'updatedAt': updatedAt.toIso8601String(),
        'squareSizeCm': squareSizeCm,
      };

  factory CrochetProject.fromJson(Map<String, dynamic> json) => CrochetProject(
        id: json['id'] as String,
        name: json['name'] as String,
        type: ProjectType.values.firstWhere(
          (t) => t.name == json['type'],
          orElse: () => ProjectType.blanket,
        ),
        sections: (json['sections'] as List<dynamic>)
            .map((s) => ProjectSection.fromJson(s as Map<String, dynamic>))
            .toList(),
        motifs: (json['motifs'] as List<dynamic>)
            .map((m) => Motif.fromJson(m as Map<String, dynamic>))
            .toList(),
        createdAt: DateTime.tryParse(json['createdAt'] as String? ?? '') ??
            DateTime.now(),
        updatedAt: DateTime.tryParse(json['updatedAt'] as String? ?? '') ??
            DateTime.now(),
        squareSizeCm: (json['squareSizeCm'] as num?)?.toDouble() ?? 10.0,
      );

  // --- Factory Templates ---

  static CrochetProject createBlanket({
    String? name,
    int rows = 6,
    int cols = 8,
    List<Motif>? customMotifs,
  }) {
    final now = DateTime.now();
    final slots = <GridSlot>[];
    for (int r = 0; r < rows; r++) {
      for (int c = 0; c < cols; c++) {
        slots.add(GridSlot(row: r, col: c));
      }
    }

    return CrochetProject(
      id: 'blanket_${now.millisecondsSinceEpoch}',
      name: name ?? 'Battaniye Projem',
      type: ProjectType.blanket,
      sections: [
        ProjectSection(
          id: 'main_grid',
          name: 'Battaniye Izgarası',
          rows: rows,
          cols: cols,
          slots: slots,
        ),
      ],
      motifs: customMotifs ?? Motif.defaultMotifs(),
      createdAt: now,
      updatedAt: now,
    );
  }

  static CrochetProject createSweater({
    String? name,
    int bodyRows = 5,
    int bodyCols = 4,
    int sleeveRows = 4,
    int sleeveCols = 3,
    double? squareSizeCm = 10.0,
    List<Motif>? customMotifs,
  }) {
    final now = DateTime.now();

    List<GridSlot> makeSlots(int rCount, int cCount) {
      final list = <GridSlot>[];
      for (int r = 0; r < rCount; r++) {
        for (int c = 0; c < cCount; c++) {
          list.add(GridSlot(row: r, col: c));
        }
      }
      return list;
    }

    return CrochetProject(
      id: 'sweater_${now.millisecondsSinceEpoch}',
      name: name ?? 'Granny Kazak / Hırka',
      type: ProjectType.sweater,
      squareSizeCm: squareSizeCm ?? 10.0,
      sections: [
        ProjectSection(
          id: 'front',
          name: 'Ön Gövde',
          rows: bodyRows,
          cols: bodyCols,
          slots: makeSlots(bodyRows, bodyCols),
        ),
        ProjectSection(
          id: 'back',
          name: 'Arka Gövde',
          rows: bodyRows,
          cols: bodyCols,
          slots: makeSlots(bodyRows, bodyCols),
        ),
        ProjectSection(
          id: 'left_sleeve',
          name: 'Sol Kol',
          rows: sleeveRows,
          cols: sleeveCols,
          slots: makeSlots(sleeveRows, sleeveCols),
        ),
        ProjectSection(
          id: 'right_sleeve',
          name: 'Sağ Kol',
          rows: sleeveRows,
          cols: sleeveCols,
          slots: makeSlots(sleeveRows, sleeveCols),
        ),
      ],
      motifs: customMotifs ?? Motif.defaultMotifs(),
      createdAt: now,
      updatedAt: now,
    );
  }

  static CrochetProject createToteBag({
    String? name,
    List<Motif>? customMotifs,
  }) {
    final now = DateTime.now();
    // 13-square classic granny tote flat pattern:
    // 5 rows x 5 cols grid with active squares placed diagonally:
    // (0,1), (0,3)
    // (1,0), (1,1), (1,2), (1,3), (1,4)
    // (2,1), (2,2), (2,3)
    // (3,1), (3,2), (3,3) -> total 13 active squares
    final activeCoords = <(int, int)>{
      (0, 1), (0, 3),
      (1, 0), (1, 1), (1, 2), (1, 3), (1, 4),
      (2, 1), (2, 2), (2, 3),
      (3, 1), (3, 2), (3, 3),
    };

    final slots = <GridSlot>[];
    for (int r = 0; r < 4; r++) {
      for (int c = 0; c < 5; c++) {
        slots.add(GridSlot(
          row: r,
          col: c,
          isActive: activeCoords.contains((r, c)),
        ));
      }
    }

    return CrochetProject(
      id: 'tote_${now.millisecondsSinceEpoch}',
      name: name ?? '13 Kareli Tote Çanta',
      type: ProjectType.toteBag,
      sections: [
        ProjectSection(
          id: 'tote_layout',
          name: 'Çanta Açılımı (13 Kare)',
          rows: 4,
          cols: 5,
          slots: slots,
        ),
      ],
      motifs: customMotifs ?? Motif.defaultMotifs(),
      createdAt: now,
      updatedAt: now,
    );
  }

  static CrochetProject createCustom({
    String? name,
    required int rows,
    required int cols,
    List<Motif>? customMotifs,
  }) {
    final now = DateTime.now();
    final slots = <GridSlot>[];
    for (int r = 0; r < rows; r++) {
      for (int c = 0; c < cols; c++) {
        slots.add(GridSlot(row: r, col: c));
      }
    }

    return CrochetProject(
      id: 'custom_${now.millisecondsSinceEpoch}',
      name: name ?? 'Özel Izgara Projem',
      type: ProjectType.custom,
      sections: [
        ProjectSection(
          id: 'custom_grid',
          name: 'Çalışma Izgarası',
          rows: rows,
          cols: cols,
          slots: slots,
        ),
      ],
      motifs: customMotifs ?? Motif.defaultMotifs(),
      createdAt: now,
      updatedAt: now,
    );
  }

  static CrochetProject createFreeform({
    String? name,
    List<Motif>? customMotifs,
  }) {
    final now = DateTime.now();
    return CrochetProject(
      id: 'freeform_${now.millisecondsSinceEpoch}',
      name: name ?? 'Serbest Form Projem',
      type: ProjectType.freeform,
      sections: [
        ProjectSection(
          id: 'freeform_canvas',
          name: 'Serbest Tuval',
          rows: 1,
          cols: 1,
          slots: const [],
          isFreeform: true,
        ),
      ],
      motifs: customMotifs ?? Motif.defaultMotifs(),
      createdAt: now,
      updatedAt: now,
    );
  }
}
