import 'package:flutter/material.dart';

import '../../../../shared/design/app_design_tokens.dart';

class CreateOrderStepIndicator extends StatelessWidget {
  final int currentStep;
  final List<String> labels;

  const CreateOrderStepIndicator({
    super.key,
    required this.currentStep,
    this.labels = const ['Mijoz', 'Mahsulot', 'To\'lov', 'Tasdiqlash'],
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.xl, vertical: AppSpacing.md),
      color: Colors.white,
      child: Row(
        children: [
          for (int i = 0; i < labels.length; i++) ...[
            _StepDot(step: i, label: labels[i], currentStep: currentStep),
            if (i < labels.length - 1)
              _StepLine(index: i, currentStep: currentStep),
          ],
        ],
      ),
    );
  }
}

class _StepDot extends StatelessWidget {
  final int step;
  final String label;
  final int currentStep;

  const _StepDot(
      {required this.step, required this.label, required this.currentStep});

  @override
  Widget build(BuildContext context) {
    final isActive = currentStep >= step;
    final isCurrent = currentStep == step;
    return Column(
      children: [
        AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          width: 28,
          height: 28,
          decoration: BoxDecoration(
            color: isActive ? AppColors.primary : Colors.grey.shade300,
            shape: BoxShape.circle,
            border: isCurrent
                ? Border.all(color: AppColors.primary, width: 3)
                : null,
          ),
          child: Center(
            child: isActive && !isCurrent
                ? const Icon(Icons.check, color: Colors.white, size: 16)
                : Text(
                    '${step + 1}',
                    style: TextStyle(
                      color: isActive ? Colors.white : Colors.grey,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
          ),
        ),
        const SizedBox(height: AppSpacing.xs),
        Text(label,
            style: TextStyle(
                fontSize: 10,
                color: isActive ? AppColors.primary : Colors.grey)),
      ],
    );
  }
}

class _StepLine extends StatelessWidget {
  final int index;
  final int currentStep;

  const _StepLine({required this.index, required this.currentStep});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        height: 2,
        color: currentStep > index ? AppColors.primary : Colors.grey.shade300,
      ),
    );
  }
}
