import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:mystcrochet_planner/config/app_config.dart';
import 'package:mystcrochet_planner/models/motif.dart';
import 'package:mystcrochet_planner/models/project.dart';
import 'package:mystcrochet_planner/models/yarn_color.dart';
import 'package:mystcrochet_planner/providers/project_provider.dart';
import 'package:mystcrochet_planner/services/image_cropper_service.dart';
import 'package:mystcrochet_planner/services/localization.dart';

void main() {
  group('MystCrochet Models & Logic Tests', () {
    test('YarnColor serialization and equality', () {
      const color = YarnColor(id: 'sage', name: 'Adaçayı', colorValue: 0xFF9CAF88);
      final json = color.toJson();
      final fromJson = YarnColor.fromJson(json);

      expect(fromJson.id, 'sage');
      expect(fromJson.name, 'Adaçayı');
      expect(fromJson.colorValue, 0xFF9CAF88);
      expect(fromJson, equals(color));
    });

    test('Motif serialization and copyWith', () {
      final defaultMotifs = Motif.defaultMotifs();
      expect(defaultMotifs.length, greaterThanOrEqualTo(4));

      final motif = defaultMotifs.first;
      final json = motif.toJson();
      final restored = Motif.fromJson(json);

      expect(restored.id, motif.id);
      expect(restored.name, motif.name);
      expect(restored.type, motif.type);
      expect(restored.rounds.length, motif.rounds.length);

      final modified = motif.copyWith(name: 'Updated Motif');
      expect(modified.name, 'Updated Motif');
      expect(modified.id, motif.id);
    });

    test('Blanket template creates correct NxM grid', () {
      final blanket = CrochetProject.createBlanket(rows: 6, cols: 8);
      expect(blanket.type, ProjectType.blanket);
      expect(blanket.sections.length, 1);
      expect(blanket.sections.first.rows, 6);
      expect(blanket.sections.first.cols, 8);
      expect(blanket.totalActiveSquares, 48);
      expect(blanket.totalFilledSquares, 0);
    });

    test('Sweater template creates 4 distinct garment sections', () {
      final sweater = CrochetProject.createSweater(
        bodyRows: 5,
        bodyCols: 4,
        sleeveRows: 4,
        sleeveCols: 3,
      );
      expect(sweater.type, ProjectType.sweater);
      expect(sweater.sections.length, 4);

      // Front: 20, Back: 20, Left Sleeve: 12, Right Sleeve: 12 -> Total 64
      expect(sweater.sections[0].activeSlotCount, 20);
      expect(sweater.sections[1].activeSlotCount, 20);
      expect(sweater.sections[2].activeSlotCount, 12);
      expect(sweater.sections[3].activeSlotCount, 12);
      expect(sweater.totalActiveSquares, 64);
    });

    test('Tote Bag origami template has exactly 13 active squares', () {
      final tote = CrochetProject.createToteBag();
      expect(tote.type, ProjectType.toteBag);
      expect(tote.totalActiveSquares, 13);
    });

    test('ProjectProvider painting, tally calculation, and eraser mode', () {
      final provider = ProjectProvider();
      final blanket = CrochetProject.createBlanket(rows: 3, cols: 3);
      provider.setProject(blanket);

      expect(provider.project?.totalActiveSquares, 9);
      expect(provider.project?.totalFilledSquares, 0);

      final motifA = provider.project!.motifs[0].id;
      final motifB = provider.project!.motifs[1].id;

      // Select motif A and paint slot (0, 0)
      provider.selectMotif(motifA);
      provider.updateSlot(0, 0);

      // Select motif B and paint slot (0, 1)
      provider.selectMotif(motifB);
      provider.updateSlot(0, 1);

      expect(provider.project?.totalFilledSquares, 2);
      final tally = provider.getMotifCounts();
      expect(tally[motifA], 1);
      expect(tally[motifB], 1);

      // Test Eraser mode
      provider.toggleEraser();
      expect(provider.isEraserMode, isTrue);
      provider.updateSlot(0, 0); // Erase slot (0,0)

      expect(provider.project?.totalFilledSquares, 1);
      expect(provider.getMotifCounts()[motifA], isNull);
      expect(provider.getMotifCounts()[motifB], 1);
    });

    test('ProjectProvider fillAll and fillEmpty', () {
      final provider = ProjectProvider();
      final blanket = CrochetProject.createBlanket(rows: 2, cols: 2);
      provider.setProject(blanket);

      final motifA = provider.project!.motifs[0].id;
      final motifB = provider.project!.motifs[1].id;

      // Fill one square with motif A
      provider.selectMotif(motifA);
      provider.updateSlot(0, 0);

      // Fill remaining empty with motif B
      provider.selectMotif(motifB);
      provider.fillAll(onlyEmpty: true);

      expect(provider.project?.totalFilledSquares, 4);
      final tally = provider.getMotifCounts();
      expect(tally[motifA], 1);
      expect(tally[motifB], 3);

      // Clear section
      provider.clearSection();
      expect(provider.project?.totalFilledSquares, 0);
    });

    test('ProjectProvider shuffleSection distributes motifs', () {
      final provider = ProjectProvider();
      final blanket = CrochetProject.createBlanket(rows: 4, cols: 4);
      provider.setProject(blanket);

      provider.shuffleSection();

      expect(provider.project?.totalFilledSquares, 16);
      final tally = provider.getMotifCounts();
      expect(tally.values.fold(0, (a, b) => a + b), 16);
      // All slots should have assigned motifs
      for (final s in provider.currentSection!.slots) {
        expect(s.motifId, isNotNull);
      }
    });

    test('Full project JSON serialization round-trip', () {
      final sweater = CrochetProject.createSweater();
      final jsonMap = sweater.toJson();
      final encoded = jsonEncode(jsonMap);

      final decodedMap = jsonDecode(encoded) as Map<String, dynamic>;
      final restored = CrochetProject.fromJson(decodedMap);

      expect(restored.id, sweater.id);
      expect(restored.name, sweater.name);
      expect(restored.type, sweater.type);
      expect(restored.sections.length, sweater.sections.length);
      expect(restored.motifs.length, sweater.motifs.length);
    });

    test('Photo motif serialization, deserialization, and copyWith', () {
      const sampleBase64 = 'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42mP8z8BQDwAEhQGAhKmMIQAAAABJRU5ErkJggg==';
      const photoMotif = Motif(
        id: 'photo_1',
        name: 'Gerçek Motifim',
        type: MotifType.photo,
        rounds: [],
        photoBase64: sampleBase64,
      );

      final json = photoMotif.toJson();
      expect(json['type'], 'photo');
      expect(json['photoBase64'], sampleBase64);

      final restored = Motif.fromJson(json);
      expect(restored.id, 'photo_1');
      expect(restored.type, MotifType.photo);
      expect(restored.photoBase64, sampleBase64);
      expect(restored.rounds, isEmpty);

      final updated = photoMotif.copyWith(name: 'Gül Motifim');
      expect(updated.name, 'Gül Motifim');
      expect(updated.photoBase64, sampleBase64);
    });

    test('AppConfig resolution tiers and custom overrides', () {
      // Standard resolution
      AppConfig.isPremiumUser = false;
      AppConfig.setCustomResolution(null);
      expect(AppConfig.activePhotoResolution, 512);

      // Premium resolution
      AppConfig.isPremiumUser = true;
      expect(AppConfig.activePhotoResolution, 1024);

      // Custom resolution override
      AppConfig.setCustomResolution(768);
      expect(AppConfig.activePhotoResolution, 768);

      // Reset
      AppConfig.setCustomResolution(null);
      AppConfig.isPremiumUser = false;
      expect(AppConfig.activePhotoResolution, 512);
    });

    test('ImageCropperService getAutoCenterSquare calculations', () {
      // Landscape: 1600x1200 -> 1200x1200 centered at (200, 0)
      final rectLandscape = ImageCropperService.getAutoCenterSquare(1600, 1200);
      expect(rectLandscape.left, 200.0);
      expect(rectLandscape.top, 0.0);
      expect(rectLandscape.width, 1200.0);
      expect(rectLandscape.height, 1200.0);

      // Portrait: 1080x1920 -> 1080x1080 centered at (0, 420)
      final rectPortrait = ImageCropperService.getAutoCenterSquare(1080, 1920);
      expect(rectPortrait.left, 0.0);
      expect(rectPortrait.top, 420.0);
      expect(rectPortrait.width, 1080.0);
      expect(rectPortrait.height, 1080.0);
    });

    test('Project with Photo motif painting, tally, and JSON export', () {
      final provider = ProjectProvider();
      final blanket = CrochetProject.createBlanket(rows: 2, cols: 2);
      provider.setProject(blanket);

      const sampleBase64 = 'dGVzdF9waG90b19kYXRh';
      const photoMotif = Motif(
        id: 'photo_test_1',
        name: 'El Emeği Motif',
        type: MotifType.photo,
        photoBase64: sampleBase64,
      );

      provider.addMotif(photoMotif);
      expect(provider.project?.motifs.any((m) => m.id == 'photo_test_1'), isTrue);

      // Select and paint with photo motif
      provider.selectMotif('photo_test_1');
      provider.updateSlot(0, 0);
      provider.updateSlot(1, 1);

      expect(provider.project?.totalFilledSquares, 2);
      final tally = provider.getMotifCounts();
      expect(tally['photo_test_1'], 2);

      // Verify JSON round-trip retains photoBase64
      final json = provider.project!.toJson();
      final restored = CrochetProject.fromJson(json);
      final restoredPhotoMotif = restored.motifs.firstWhere((m) => m.id == 'photo_test_1');
      expect(restoredPhotoMotif.photoBase64, sampleBase64);
      expect(restoredPhotoMotif.type, MotifType.photo);
    });

    test('LocalizationService supports TR, EN, DE, and ES', () {
      final loc = LocalizationService();

      loc.setLanguage(AppLanguage.tr);
      expect(loc.currentLanguage, AppLanguage.tr);
      expect(loc.tr('template_sweater_title'), 'Kazak & Hırka');
      expect(loc.tr('section_breakdown'), 'Parça Bazında Dağılım');

      loc.setLanguage(AppLanguage.en);
      expect(loc.currentLanguage, AppLanguage.en);
      expect(loc.tr('template_sweater_title'), 'Sweater & Cardigan');
      expect(loc.tr('section_breakdown'), 'Section Breakdown');

      loc.setLanguage(AppLanguage.de);
      expect(loc.currentLanguage, AppLanguage.de);
      expect(loc.tr('template_sweater_title'), 'Pullover & Strickjacke');
      expect(loc.tr('section_breakdown'), 'Aufteilung nach Teilen');
      expect(AppLanguage.de.label, 'Deutsch');
      expect(AppLanguage.de.flag, '🇩🇪');

      loc.setLanguage(AppLanguage.es);
      expect(loc.currentLanguage, AppLanguage.es);
      expect(loc.tr('template_sweater_title'), 'Suéter y Cárdigan');
      expect(loc.tr('section_breakdown'), 'Distribución por Secciones');
      expect(AppLanguage.es.label, 'Español');
      expect(AppLanguage.es.flag, '🇪🇸');

      // Reset
      loc.setLanguage(AppLanguage.tr);
    });

    test('Sweater garment sections dynamically change with language', () {
      final loc = LocalizationService();
      final sweater = CrochetProject.createSweater();
      final front = sweater.sections.firstWhere((s) => s.id == 'front');
      final back = sweater.sections.firstWhere((s) => s.id == 'back');
      final leftSleeve = sweater.sections.firstWhere((s) => s.id == 'left_sleeve');
      final rightSleeve = sweater.sections.firstWhere((s) => s.id == 'right_sleeve');

      // Turkish
      loc.setLanguage(AppLanguage.tr);
      expect(front.localizedName, 'Ön Gövde');
      expect(back.localizedName, 'Arka Gövde');
      expect(leftSleeve.localizedName, 'Sol Kol');
      expect(rightSleeve.localizedName, 'Sağ Kol');

      // English
      loc.setLanguage(AppLanguage.en);
      expect(front.localizedName, 'Front Body');
      expect(back.localizedName, 'Back Body');
      expect(leftSleeve.localizedName, 'Left Sleeve');
      expect(rightSleeve.localizedName, 'Right Sleeve');

      // German
      loc.setLanguage(AppLanguage.de);
      expect(front.localizedName, 'Vorderteil');
      expect(back.localizedName, 'Rückenteil');
      expect(leftSleeve.localizedName, 'Linker Ärmel');
      expect(rightSleeve.localizedName, 'Rechter Ärmel');

      // Spanish
      loc.setLanguage(AppLanguage.es);
      expect(front.localizedName, 'Delantero');
      expect(back.localizedName, 'Espalda');
      expect(leftSleeve.localizedName, 'Manga Izquierda');
      expect(rightSleeve.localizedName, 'Manga Derecha');

      // Reset
      loc.setLanguage(AppLanguage.tr);
    });

    test('ProjectSection.resize preserves existing motifs and adjusts slot bounds', () {
      final section = ProjectSection(
        id: 'test_sec',
        name: 'Test Section',
        rows: 2,
        cols: 2,
        slots: const [
          GridSlot(row: 0, col: 0, motifId: 'motif_a'),
          GridSlot(row: 0, col: 1, motifId: 'motif_b'),
          GridSlot(row: 1, col: 0, motifId: 'motif_c'),
          GridSlot(row: 1, col: 1, motifId: null),
        ],
      );

      // Expand to 3x3
      final expanded = section.resize(newRows: 3, newCols: 3);
      expect(expanded.rows, 3);
      expect(expanded.cols, 3);
      expect(expanded.slots.length, 9);
      expect(expanded.slotAt(0, 0)?.motifId, 'motif_a');
      expect(expanded.slotAt(0, 1)?.motifId, 'motif_b');
      expect(expanded.slotAt(1, 0)?.motifId, 'motif_c');
      expect(expanded.slotAt(2, 2)?.motifId, isNull);

      // Shrink to 1x2
      final shrunk = section.resize(newRows: 1, newCols: 2);
      expect(shrunk.rows, 1);
      expect(shrunk.cols, 2);
      expect(shrunk.slots.length, 2);
      expect(shrunk.slotAt(0, 0)?.motifId, 'motif_a');
      expect(shrunk.slotAt(0, 1)?.motifId, 'motif_b');
      expect(shrunk.slotAt(1, 0), isNull);
    });

    test('Sweater customizable dimensions and physical size calculation', () {
      const squareSize = 12.0; // 12 cm per granny square
      final sweater = CrochetProject.createSweater(
        name: 'Oversize Kazak',
        bodyRows: 5,
        bodyCols: 5,
        sleeveRows: 4,
        sleeveCols: 3,
        squareSizeCm: squareSize,
      );

      expect(sweater.squareSizeCm, 12.0);
      final front = sweater.sections.firstWhere((s) => s.id == 'front');
      final sleeve = sweater.sections.firstWhere((s) => s.id == 'left_sleeve');

      // Dimensions math:
      final bodyWidthCm = front.cols * squareSize;
      final chestCircumferenceCm = front.cols * 2 * squareSize;
      final bodyLengthCm = front.rows * squareSize;
      final sleeveLengthCm = sleeve.rows * squareSize;
      final sleeveWidthCm = sleeve.cols * squareSize;

      expect(bodyWidthCm, 60.0);
      expect(chestCircumferenceCm, 120.0);
      expect(bodyLengthCm, 60.0);
      expect(sleeveLengthCm, 48.0);
      expect(sleeveWidthCm, 36.0);

      // Total squares: (5*5)*2 + (4*3)*2 = 50 + 24 = 74
      expect(sweater.totalActiveSquares, 74);
    });

    test('ProjectProvider updateSweaterDimensions modifies sections dynamically', () {
      final provider = ProjectProvider();
      final sweater = CrochetProject.createSweater(
        bodyRows: 4,
        bodyCols: 4,
        sleeveRows: 3,
        sleeveCols: 3,
        squareSizeCm: 10.0,
      );
      provider.setProject(sweater);

      // Paint a slot on front body
      provider.selectSection(0);
      provider.selectMotif(provider.project!.motifs.first.id);
      provider.updateSlot(0, 0);

      // Now dynamically update dimensions to 6x5 body and 5x4 sleeves with 11.5 cm squares
      provider.updateSweaterDimensions(
        bodyRows: 6,
        bodyCols: 5,
        sleeveRows: 5,
        sleeveCols: 4,
        squareSizeCm: 11.5,
      );

      final updatedProject = provider.project!;
      expect(updatedProject.squareSizeCm, 11.5);
      final front = updatedProject.sections.firstWhere((s) => s.id == 'front');
      final back = updatedProject.sections.firstWhere((s) => s.id == 'back');
      final leftSleeve = updatedProject.sections.firstWhere((s) => s.id == 'left_sleeve');
      final rightSleeve = updatedProject.sections.firstWhere((s) => s.id == 'right_sleeve');

      expect(front.rows, 6);
      expect(front.cols, 5);
      expect(back.rows, 6);
      expect(back.cols, 5);
      expect(leftSleeve.rows, 5);
      expect(leftSleeve.cols, 4);
      expect(rightSleeve.rows, 5);
      expect(rightSleeve.cols, 4);

      // Verify painted slot (0,0) was preserved
      expect(front.slotAt(0, 0)?.motifId, provider.project!.motifs.first.id);

      // Total active squares: (6*5)*2 + (5*4)*2 = 60 + 40 = 100
      expect(updatedProject.totalActiveSquares, 100);

      // JSON serialization retains squareSizeCm
      final json = updatedProject.toJson();
      expect(json['squareSizeCm'], 11.5);
      final restored = CrochetProject.fromJson(json);
      expect(restored.squareSizeCm, 11.5);
    });
  });
}
