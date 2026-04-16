import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/theme/app_colors.dart';

/// A 3x3 pattern grid that supports drag gestures to connect dots.
class PatternGrid extends StatefulWidget {
  final List<int> pattern;
  final ValueChanged<List<int>> onPatternUpdate;
  final ValueChanged<List<int>> onPatternComplete;
  final bool hasError;

  const PatternGrid({
    super.key,
    required this.pattern,
    required this.onPatternUpdate,
    required this.onPatternComplete,
    this.hasError = false,
  });

  @override
  State<PatternGrid> createState() => _PatternGridState();
}

class _PatternGridState extends State<PatternGrid> {
  final List<GlobalKey> _dotKeys = List.generate(9, (_) => GlobalKey());
  List<int> _currentPattern = [];
  bool _isDragging = false;
  Offset? _currentTouch;

  @override
  void didUpdateWidget(PatternGrid oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.pattern.isEmpty && _currentPattern.isNotEmpty) {
      _currentPattern = [];
    }
  }

  void _onPanStart(DragStartDetails details) {
    _currentPattern = [];
    _isDragging = true;
    _checkHit(details.localPosition);
  }

  void _onPanUpdate(DragUpdateDetails details) {
    if (!_isDragging) return;
    setState(() => _currentTouch = details.localPosition);
    _checkHit(details.localPosition);
  }

  void _onPanEnd(DragEndDetails details) {
    _isDragging = false;
    setState(() => _currentTouch = null);
    if (_currentPattern.isNotEmpty) {
      widget.onPatternComplete(List.from(_currentPattern));
    }
  }

  void _checkHit(Offset position) {
    for (int i = 0; i < 9; i++) {
      if (_currentPattern.contains(i)) continue;
      final key = _dotKeys[i];
      final renderBox = key.currentContext?.findRenderObject() as RenderBox?;
      if (renderBox == null) continue;

      final dotPos = renderBox.localToGlobal(Offset.zero, ancestor: context.findRenderObject());
      final dotCenter = dotPos + Offset(renderBox.size.width / 2, renderBox.size.height / 2);
      final distance = (position - dotCenter).distance;

      if (distance < 32) {
        HapticFeedback.lightImpact();
        _currentPattern.add(i);
        widget.onPatternUpdate(List.from(_currentPattern));
        break;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onPanStart: _onPanStart,
      onPanUpdate: _onPanUpdate,
      onPanEnd: _onPanEnd,
      child: CustomPaint(
        foregroundPainter: _LinePainter(
          pattern: _currentPattern.isEmpty ? widget.pattern : _currentPattern,
          dotKeys: _dotKeys,
          currentTouch: _currentTouch,
          parentContext: context,
          color: widget.hasError ? AppColors.error : AppColors.primary,
        ),
        child: SizedBox(
          width: 240,
          height: 240,
          child: GridView.builder(
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              mainAxisSpacing: 24,
              crossAxisSpacing: 24,
            ),
            itemCount: 9,
            itemBuilder: (context, index) {
              final isSelected = widget.pattern.contains(index) || _currentPattern.contains(index);
              return Container(
                key: _dotKeys[index],
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isSelected
                      ? (widget.hasError ? AppColors.error : AppColors.primary).withOpacity(0.15)
                      : AppColors.zinc100,
                  border: Border.all(
                    color: isSelected
                        ? (widget.hasError ? AppColors.error : AppColors.primary)
                        : AppColors.zinc300,
                    width: isSelected ? 2.5 : 1.5,
                  ),
                ),
                child: Center(
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 150),
                    width: isSelected ? 16 : 0,
                    height: isSelected ? 16 : 0,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isSelected
                          ? (widget.hasError ? AppColors.error : AppColors.primary)
                          : Colors.transparent,
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

class _LinePainter extends CustomPainter {
  final List<int> pattern;
  final List<GlobalKey> dotKeys;
  final Offset? currentTouch;
  final BuildContext parentContext;
  final Color color;

  _LinePainter({
    required this.pattern,
    required this.dotKeys,
    required this.currentTouch,
    required this.parentContext,
    required this.color,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (pattern.isEmpty) return;

    final paint = Paint()
      ..color = color.withOpacity(0.6)
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    final parentRenderBox = parentContext.findRenderObject() as RenderBox?;
    if (parentRenderBox == null) return;

    final centers = <Offset>[];
    for (final index in pattern) {
      final key = dotKeys[index];
      final renderBox = key.currentContext?.findRenderObject() as RenderBox?;
      if (renderBox == null) continue;
      final pos = renderBox.localToGlobal(Offset.zero, ancestor: parentRenderBox);
      centers.add(pos + Offset(renderBox.size.width / 2, renderBox.size.height / 2));
    }

    for (int i = 0; i < centers.length - 1; i++) {
      canvas.drawLine(centers[i], centers[i + 1], paint);
    }

    if (currentTouch != null && centers.isNotEmpty) {
      canvas.drawLine(centers.last, currentTouch!, paint..color = color.withOpacity(0.3));
    }
  }

  @override
  bool shouldRepaint(covariant _LinePainter oldDelegate) => true;
}
