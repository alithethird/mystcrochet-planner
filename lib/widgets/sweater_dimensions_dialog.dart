import 'package:flutter/material.dart';
import '../services/localization.dart';
import '../theme/app_theme.dart';

class SweaterDimensionsResult {
  final String? name;
  final int bodyRows;
  final int bodyCols;
  final int sleeveRows;
  final int sleeveCols;
  final double squareSizeCm;

  const SweaterDimensionsResult({
    this.name,
    required this.bodyRows,
    required this.bodyCols,
    required this.sleeveRows,
    required this.sleeveCols,
    required this.squareSizeCm,
  });
}

class SweaterDimensionsDialog extends StatefulWidget {
  final bool isCreating;
  final String? initialName;
  final int initialBodyRows;
  final int initialBodyCols;
  final int initialSleeveRows;
  final int initialSleeveCols;
  final double initialSquareSizeCm;

  const SweaterDimensionsDialog({
    super.key,
    this.isCreating = false,
    this.initialName,
    this.initialBodyRows = 5,
    this.initialBodyCols = 4,
    this.initialSleeveRows = 4,
    this.initialSleeveCols = 3,
    this.initialSquareSizeCm = 10.0,
  });

  static Future<SweaterDimensionsResult?> show(
    BuildContext context, {
    bool isCreating = false,
    String? initialName,
    int initialBodyRows = 5,
    int initialBodyCols = 4,
    int initialSleeveRows = 4,
    int initialSleeveCols = 3,
    double initialSquareSizeCm = 10.0,
  }) {
    return showDialog<SweaterDimensionsResult>(
      context: context,
      builder: (ctx) => SweaterDimensionsDialog(
        isCreating: isCreating,
        initialName: initialName,
        initialBodyRows: initialBodyRows,
        initialBodyCols: initialBodyCols,
        initialSleeveRows: initialSleeveRows,
        initialSleeveCols: initialSleeveCols,
        initialSquareSizeCm: initialSquareSizeCm,
      ),
    );
  }

  @override
  State<SweaterDimensionsDialog> createState() => _SweaterDimensionsDialogState();
}

class _SweaterDimensionsDialogState extends State<SweaterDimensionsDialog> {
  late TextEditingController _nameController;
  late TextEditingController _sizeController;
  late int _bodyRows;
  late int _bodyCols;
  late int _sleeveRows;
  late int _sleeveCols;
  late double _squareSizeCm;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(
      text: widget.initialName ?? t('template_sweater_title'),
    );
    _bodyRows = widget.initialBodyRows;
    _bodyCols = widget.initialBodyCols;
    _sleeveRows = widget.initialSleeveRows;
    _sleeveCols = widget.initialSleeveCols;
    _squareSizeCm = widget.initialSquareSizeCm;
    _sizeController = TextEditingController(
      text: _squareSizeCm.toStringAsFixed(_squareSizeCm.truncateToDouble() == _squareSizeCm ? 0 : 1),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _sizeController.dispose();
    super.dispose();
  }

  void _applyPreset(int bRows, int bCols, int sRows, int sCols) {
    setState(() {
      _bodyRows = bRows;
      _bodyCols = bCols;
      _sleeveRows = sRows;
      _sleeveCols = sCols;
    });
  }

  void _updateSquareSize(double val) {
    final clamped = val.clamp(4.0, 30.0);
    setState(() {
      _squareSizeCm = clamped;
      _sizeController.text = clamped.toStringAsFixed(clamped.truncateToDouble() == clamped ? 0 : 1);
    });
  }

  @override
  Widget build(BuildContext context) {
    final bodyWidthCm = (_bodyCols * _squareSizeCm).toStringAsFixed(1);
    final chestCircumferenceCm = (_bodyCols * 2 * _squareSizeCm).toStringAsFixed(1);
    final bodyLengthCm = (_bodyRows * _squareSizeCm).toStringAsFixed(1);
    final sleeveLengthCm = (_sleeveRows * _squareSizeCm).toStringAsFixed(1);
    final sleeveWidthCm = (_sleeveCols * _squareSizeCm).toStringAsFixed(1);

    final bodySquaresEach = _bodyRows * _bodyCols;
    final sleeveSquaresEach = _sleeveRows * _sleeveCols;
    final totalSquares = (bodySquaresEach * 2) + (sleeveSquaresEach * 2);

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 540, maxHeight: 720),
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.straighten, color: AppColors.primary, size: 24),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      t('sweater_dimensions_title'),
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF2C2523),
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
              const Divider(height: 24),

              // Scrollable content
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Optional Project Name (if creating)
                      if (widget.isCreating) ...[
                        TextField(
                          controller: _nameController,
                          decoration: InputDecoration(
                            labelText: t('project_name'),
                            prefixIcon: const Icon(Icons.edit_outlined),
                          ),
                        ),
                        const SizedBox(height: 18),
                      ],

                      // Square Size CM Setting
                      Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF9F6F0),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: const Color(0xFFE5DFD7)),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    const Icon(Icons.crop_square, size: 20, color: AppColors.primary),
                                    const SizedBox(width: 8),
                                    Text(
                                      t('square_size_cm'),
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 14,
                                        color: Color(0xFF2C2523),
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(
                                  width: 70,
                                  height: 36,
                                  child: TextField(
                                    controller: _sizeController,
                                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                                    decoration: InputDecoration(
                                      contentPadding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                                    ),
                                    onSubmitted: (val) {
                                      final parsed = double.tryParse(val);
                                      if (parsed != null && parsed > 0) {
                                        _updateSquareSize(parsed);
                                      }
                                    },
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Slider(
                              value: _squareSizeCm.clamp(5.0, 25.0),
                              min: 5.0,
                              max: 25.0,
                              divisions: 40,
                              label: '$_squareSizeCm cm',
                              onChanged: (val) => _updateSquareSize(val),
                            ),
                            Wrap(
                              spacing: 8,
                              children: [8.0, 10.0, 12.0, 14.0, 15.0].map((size) {
                                final isSelected = (_squareSizeCm - size).abs() < 0.1;
                                return ChoiceChip(
                                  selected: isSelected,
                                  label: Text('${size.toInt()} cm'),
                                  onSelected: (_) => _updateSquareSize(size),
                                );
                              }).toList(),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 18),

                      // Presets (Beden Şablonları)
                      Text(
                        t('preset_size'),
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF756A63)),
                      ),
                      const SizedBox(height: 6),
                      Wrap(
                        spacing: 8,
                        runSpacing: 6,
                        children: [
                          _buildPresetChip('Çocuk / Kids', 3, 4, 2, 3),
                          _buildPresetChip('S Beden (4x5 / 3x4)', 5, 4, 4, 3),
                          _buildPresetChip('M / L Beden (5x5 / 3x5)', 5, 5, 5, 3),
                          _buildPresetChip('Oversize / XL (5x6 / 4x5)', 5, 6, 5, 4),
                        ],
                      ),
                      const SizedBox(height: 18),

                      // Steppers for Body & Sleeves
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Body section steppers
                          Expanded(
                            child: _buildSectionCounterBox(
                              title: t('body_section_title'),
                              subtitle: '$bodySquaresEach ${t('squares_count')} (${t('each_section')})',
                              rows: _bodyRows,
                              cols: _bodyCols,
                              onRowsChanged: (v) => setState(() => _bodyRows = v),
                              onColsChanged: (v) => setState(() => _bodyCols = v),
                            ),
                          ),
                          const SizedBox(width: 12),
                          // Sleeve section steppers
                          Expanded(
                            child: _buildSectionCounterBox(
                              title: t('sleeve_section_title'),
                              subtitle: '$sleeveSquaresEach ${t('squares_count')} (${t('each_section')})',
                              rows: _sleeveRows,
                              cols: _sleeveCols,
                              onRowsChanged: (v) => setState(() => _sleeveRows = v),
                              onColsChanged: (v) => setState(() => _sleeveCols = v),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 18),

                      // Live Calculated Dimensions Card
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              AppColors.primary.withValues(alpha: 0.08),
                              const Color(0xFF7A9A83).withValues(alpha: 0.08),
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppColors.primary.withValues(alpha: 0.2)),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                const Icon(Icons.calculate, size: 18, color: AppColors.primary),
                                const SizedBox(width: 6),
                                Text(
                                  t('calculated_measurements'),
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                    color: Color(0xFF2C2523),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            _buildMeasurementRow(
                              icon: Icons.swap_horiz,
                              label: t('body_width'),
                              value: '$bodyWidthCm cm',
                              extra: '${t('chest_circumference')}: $chestCircumferenceCm cm',
                            ),
                            const SizedBox(height: 6),
                            _buildMeasurementRow(
                              icon: Icons.height,
                              label: t('body_length'),
                              value: '$bodyLengthCm cm',
                            ),
                            const SizedBox(height: 6),
                            _buildMeasurementRow(
                              icon: Icons.trending_flat,
                              label: t('sleeve_length'),
                              value: '$sleeveLengthCm cm',
                              extra: '${t('sleeve_width')}: $sleeveWidthCm cm',
                            ),
                            const Divider(height: 16),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  '${t('total_motifs_needed')}:',
                                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: AppColors.primary,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    '$totalSquares ${t('units')}',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const Divider(height: 24),

              // Action buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: Text(t('cancel_btn')),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton.icon(
                    onPressed: () {
                      final name = _nameController.text.trim();
                      final result = SweaterDimensionsResult(
                        name: name.isNotEmpty ? name : null,
                        bodyRows: _bodyRows,
                        bodyCols: _bodyCols,
                        sleeveRows: _sleeveRows,
                        sleeveCols: _sleeveCols,
                        squareSizeCm: _squareSizeCm,
                      );
                      Navigator.of(context).pop(result);
                    },
                    icon: Icon(widget.isCreating ? Icons.check : Icons.save_outlined),
                    label: Text(widget.isCreating ? t('create_btn') : t('apply_changes')),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPresetChip(String label, int bRows, int bCols, int sRows, int sCols) {
    final isSelected =
        _bodyRows == bRows && _bodyCols == bCols && _sleeveRows == sRows && _sleeveCols == sCols;
    return ChoiceChip(
      selected: isSelected,
      label: Text(label, style: const TextStyle(fontSize: 12)),
      onSelected: (_) => _applyPreset(bRows, bCols, sRows, sCols),
    );
  }

  Widget _buildSectionCounterBox({
    required String title,
    required String subtitle,
    required int rows,
    required int cols,
    required ValueChanged<int> onRowsChanged,
    required ValueChanged<int> onColsChanged,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE5DFD7)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF2C2523))),
          Text(subtitle, style: const TextStyle(fontSize: 11, color: Color(0xFF756A63))),
          const SizedBox(height: 10),
          _buildStepperRow(t('rows'), rows, 2, 12, onRowsChanged),
          const SizedBox(height: 6),
          _buildStepperRow(t('cols'), cols, 2, 10, onColsChanged),
        ],
      ),
    );
  }

  Widget _buildStepperRow(
    String label,
    int value,
    int min,
    int max,
    ValueChanged<int> onChanged,
  ) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(fontSize: 12, color: Color(0xFF5A524C))),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            InkWell(
              onTap: value > min ? () => onChanged(value - 1) : null,
              borderRadius: BorderRadius.circular(6),
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: value > min ? const Color(0xFFF2ECE4) : const Color(0xFFF5F3EF),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Icon(Icons.remove, size: 14, color: value > min ? const Color(0xFF2C2523) : Colors.grey),
              ),
            ),
            SizedBox(
              width: 28,
              child: Text(
                '$value',
                textAlign: TextAlign.center,
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
              ),
            ),
            InkWell(
              onTap: value < max ? () => onChanged(value + 1) : null,
              borderRadius: BorderRadius.circular(6),
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: value < max ? const Color(0xFFF2ECE4) : const Color(0xFFF5F3EF),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Icon(Icons.add, size: 14, color: value < max ? const Color(0xFF2C2523) : Colors.grey),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildMeasurementRow({
    required IconData icon,
    required String label,
    required String value,
    String? extra,
  }) {
    return Row(
      children: [
        Icon(icon, size: 16, color: const Color(0xFF756A63)),
        const SizedBox(width: 6),
        Text('$label: ', style: const TextStyle(fontSize: 12, color: Color(0xFF5A524C))),
        Text(value, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF2C2523))),
        if (extra != null) ...[
          const SizedBox(width: 8),
          Text('($extra)', style: const TextStyle(fontSize: 11, color: Color(0xFF8C7F77))),
        ],
      ],
    );
  }
}
