import 'package:flutter/material.dart';
import '../core/theme/theme.dart';

/// A customizable horizontal step indicator.
///
/// Usage:
/// ```dart
/// ZienaStepIndicator(
///   steps: ['Submitted', 'Under Review', 'Resolved'],
///   currentStep: 1, // 0-based index
/// )
/// ```
class ZienaStepIndicator extends StatelessWidget {
  /// List of step labels in order.
  final List<String> steps;

  /// 0-based index of the current active step.
  final int currentStep;

  /// Color of completed steps and connectors. Defaults to ZienaColors.primary.
  final Color? activeColor;

  /// Color of the current (active) step dot. Defaults to ZienaColors.primary.
  final Color? currentColor;

  /// Color of upcoming (inactive) steps. Defaults to a light pink.
  final Color? inactiveColor;

  /// Size of the completed step dots.
  final double completedDotSize;

  /// Size of the current (active) step dot — slightly larger with outer ring.
  final double currentDotSize;

  /// Size of the inactive step dots.
  final double inactiveDotSize;

  /// Font size of the step labels.
  final double labelFontSize;

  const ZienaStepIndicator({
    super.key,
    required this.steps,
    required this.currentStep,
    this.activeColor,
    this.currentColor,
    this.inactiveColor,
    this.completedDotSize = 16,
    this.currentDotSize = 20,
    this.inactiveDotSize = 14,
    this.labelFontSize = 12,
  });

  @override
  Widget build(BuildContext context) {
    final active   = activeColor   ?? ZienaColors.primary;
    final current  = currentColor  ?? ZienaColors.primary;
    final inactive = inactiveColor ?? ZienaColors.primary.withOpacity(0.25);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // ── Dots + connectors row ───────────────────────────────────────────
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 30),
          child: SizedBox(
            height: currentDotSize + 8,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: List.generate(steps.length, (i) {
                final isDone    = i < currentStep;
                final isCurrent = i == currentStep;
                final isLast    = i == steps.length - 1;

                return Expanded(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // ── Left connector (not shown for first step) ────────────
                      if (i > 0)
                        Expanded(
                          child: _Connector(
                            filled: isDone || isCurrent,
                            color: active,
                            inactiveColor: inactive,
                          ),
                        ),

                      // ── Dot ─────────────────────────────────────────────────
                      _StepDot(
                        isDone:    isDone,
                        isCurrent: isCurrent,
                        activeColor:   active,
                        currentColor:  current,
                        inactiveColor: inactive,
                        completedSize: completedDotSize,
                        currentSize:   currentDotSize,
                        inactiveSize:  inactiveDotSize,
                      ),

                      // ── Right connector (not shown for last step) ────────────
                      if (!isLast)
                        Expanded(
                          child: _Connector(
                            filled: isDone,
                            color: active,
                            inactiveColor: inactive,
                          ),
                        ),
                    ],
                  ),
                );
              }),
            ),
          ),
        ),

        const SizedBox(height: 8),

        // ── Labels row ──────────────────────────────────────────────────────
        Row(
          children: List.generate(steps.length, (i) {
            final isDone    = i < currentStep;
            final isCurrent = i == currentStep;
            final isActive  = isDone || isCurrent;

            return Expanded(
              child: Text(
                steps[i],
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: labelFontSize,
                  fontWeight: isCurrent
                      ? FontWeight.w700
                      : isDone
                      ? FontWeight.w600
                      : FontWeight.w400,
                  color: isActive
                      ? active
                      : inactive,
                ),
              ),
            );
          }),
        ),
      ],
    );
  }
}

// ── Connector line ────────────────────────────────────────────────────────────
class _Connector extends StatelessWidget {
  final bool filled;
  final Color color;
  final Color inactiveColor;

  const _Connector({
    required this.filled,
    required this.color,
    required this.inactiveColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 3,
      decoration: BoxDecoration(
        color: filled ? color : inactiveColor,
        borderRadius: BorderRadius.circular(2),
      ),
    );
  }
}

// ── Step dot ──────────────────────────────────────────────────────────────────
class _StepDot extends StatelessWidget {
  final bool isDone;
  final bool isCurrent;
  final Color activeColor;
  final Color currentColor;
  final Color inactiveColor;
  final double completedSize;
  final double currentSize;
  final double inactiveSize;

  const _StepDot({
    required this.isDone,
    required this.isCurrent,
    required this.activeColor,
    required this.currentColor,
    required this.inactiveColor,
    required this.completedSize,
    required this.currentSize,
    required this.inactiveSize,
  });

  @override
  Widget build(BuildContext context) {
    if (isCurrent) {
      // Active dot: solid inner circle + translucent outer ring
      return Container(
        width: currentSize + 8,
        height: currentSize + 8,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: currentColor.withOpacity(0.25),
        ),
        child: Center(
          child: Container(
            width: currentSize,
            height: currentSize,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: currentColor,
            ),
          ),
        ),
      );
    }

    if (isDone) {
      // Completed dot: solid filled
      return Container(
        width: completedSize,
        height: completedSize,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: activeColor,
        ),
      );
    }

    // Inactive dot: light translucent
    return Container(
      width: currentSize,
      height: currentSize,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: inactiveColor,
      ),
    );
  }
}