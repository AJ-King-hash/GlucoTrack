import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:untitled10/core/localization/locale_cubit.dart';
import 'package:untitled10/core/utils/bmi_ui_logic.dart';
import 'package:untitled10/core/utils/health_utils.dart';

class BmiGaugeWidget extends StatelessWidget {
  final double bmi;
  const BmiGaugeWidget({super.key, required this.bmi});

  @override
  Widget build(BuildContext context) {
    final locale = context.read<LocaleCubit>();
    final categoryKey = HealthUtils.getBmiCategory(bmi);
    final color = HealthUtils.getBmiColor(bmi);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  bmi.toStringAsFixed(1),
                  style: TextStyle(
                    fontSize: 24,
                    color: color,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  locale.translate(categoryKey),
                  style: TextStyle(color: color),
                ),
              ],
            ),
            const SizedBox(height: 20),
            LayoutBuilder(
              builder: (context, constraints) {
                return Stack(
                  clipBehavior: Clip.none,
                  children: [
                    _buildGradientBar(),
                    Positioned(
                      left:
                          BmiUiLogic.calculateAlignment(bmi) *
                          (constraints.maxWidth - 4),
                      child: Container(
                        width: 4,
                        height: 16,
                        color: Colors.black,
                      ),
                    ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGradientBar() {
    return Container(
      height: 12,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(6),
        gradient: const LinearGradient(
          colors: [Colors.amber, Colors.green, Colors.orange, Colors.red],
        ),
      ),
    );
  }
}
