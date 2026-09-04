import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:mystcrochet_planner/models/motif.dart';
import 'package:mystcrochet_planner/models/project.dart';
import 'package:mystcrochet_planner/models/yarn_color.dart';
import 'package:mystcrochet_planner/providers/project_provider.dart';

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
  });
}
