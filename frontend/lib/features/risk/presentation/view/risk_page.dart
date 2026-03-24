import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:glucotrack/core/localization/locale_cubit.dart';
import 'package:glucotrack/features/risk/domain/entity/risk_entity.dart';
import 'package:glucotrack/features/risk/presentation/manager/risk_cubit.dart';
import 'package:glucotrack/features/risk/presentation/manager/risk_state.dart';
import 'package:glucotrack/features/risk/presentation/widgets/create_risk_dialog.dart';
import 'package:glucotrack/features/risk/presentation/widgets/update_risk_dialog.dart';

class RiskPage extends StatefulWidget {
  const RiskPage({super.key});

  @override
  State<RiskPage> createState() => _RiskPageState();
}

class _RiskPageState extends State<RiskPage> {
  int? selectedRiskId;

  @override
  void initState() {
    super.initState();
    // Fetch risk when page loads
    context.read<RiskCubit>().getRisk(0);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(context.read<LocaleCubit>().translate('risk_management')),
      ),
      body: BlocConsumer<RiskCubit, RiskState>(
        listener: (context, state) {
          if (state is RiskFailure) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(state.message)));
          } else if (state is RiskCreated) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  context.read<LocaleCubit>().translate(
                    'risk_created_successfully',
                  ),
                ),
              ),
            );
          } else if (state is RiskUpdated) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  context.read<LocaleCubit>().translate(
                    'risk_updated_successfully',
                  ),
                ),
              ),
            );
          } else if (state is RiskDeleted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  context.read<LocaleCubit>().translate(
                    'risk_deleted_successfully',
                  ),
                ),
              ),
            );
            selectedRiskId = null;
          }
        },
        builder: (context, state) {
          if (state is RiskLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is RiskLoaded) {
            return RiskDetailsView(risk: state.risk);
          } else if (state is RiskCreated) {
            return RiskDetailsView(risk: state.risk);
          } else if (state is RiskUpdated) {
            return RiskDetailsView(risk: state.risk);
          } else if (state is RiskFailure) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    state.message,
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 16, color: Colors.red),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => context.read<RiskCubit>().getRisk(0),
                    child: Text(
                      context.read<LocaleCubit>().translate('try_again'),
                    ),
                  ),
                ],
              ),
            );
          } else {
            return Center(
              child: Text(
                context.read<LocaleCubit>().translate('select_risk_or_create'),
              ),
            );
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showCreateRiskDialog(context),
        child: const Icon(Icons.add),
      ),
    );
  }

  void _showCreateRiskDialog(BuildContext context) {
    showDialog(
      context: context,
      builder:
          (_) => BlocProvider.value(
            value: context.read<RiskCubit>(),
            child: const CreateRiskDialog(),
          ),
    );
  }
}

class RiskDetailsView extends StatelessWidget {
  final RiskEntity? risk;

  const RiskDetailsView({super.key, required this.risk});

  @override
  Widget build(BuildContext context) {
    if (risk == null) {
      return Center(
        child: Text(
          context.read<LocaleCubit>().translate('no_risk_data_available'),
          style: const TextStyle(fontSize: 18, color: Colors.grey),
        ),
      );
    }
    final safeRisk = risk!;
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Container(
        decoration: BoxDecoration(borderRadius: BorderRadius.circular(16)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // BMI Gauge Card - Enhanced design
            Card(
              elevation: 8,
              shadowColor: Colors.black.withValues(alpha: 0.1),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 50,
                          height: 50,
                          decoration: BoxDecoration(
                            color: Colors.blue.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(
                            Icons.monitor_heart,
                            color: Colors.blue,
                            size: 28,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                context.read<LocaleCubit>().translate('bmi'),
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.black87,
                                ),
                              ),
                              Text(
                                _getBmiCategory(context, safeRisk.bmi),
                                style: TextStyle(
                                  fontSize: 14,
                                  color: _getBmiColor(
                                    safeRisk.bmi,
                                  ).withValues(alpha: 0.8),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.grey.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            safeRisk.bmi.toStringAsFixed(1),
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: _getBmiColor(safeRisk.bmi),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    LinearProgressIndicator(
                      value: (safeRisk.bmi / 40).clamp(0, 1),
                      backgroundColor: Colors.grey.withValues(alpha: 0.2),
                      valueColor: AlwaysStoppedAnimation<Color>(
                        _getBmiColor(safeRisk.bmi),
                      ),
                      minHeight: 8,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '18.5 - 24.9',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.green.withValues(alpha: 0.8),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        Text(
                          'Normal Range',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Health Metrics Section - Enhanced design
            _buildSectionTitle(context, 'health_metrics'),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildMetricCard(
                    context,
                    icon: Icons.cake,
                    label: 'age',
                    value: safeRisk.age.toString(),
                    unit: '',
                    color: Colors.blue,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildMetricCard(
                    context,
                    icon: Icons.monitor_weight,
                    label: 'weight',
                    value: safeRisk.weight.toStringAsFixed(1),
                    unit: 'kg',
                    color: Colors.green,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildMetricCard(
                    context,
                    icon: Icons.height,
                    label: 'height',
                    value: safeRisk.height.toStringAsFixed(2),
                    unit: 'm',
                    color: Colors.purple,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Risk Factors Section - Enhanced design
            _buildSectionTitle(context, 'risk_management'),
            const SizedBox(height: 16),
            _buildRiskFactorCard(
              context,
              icon: Icons.smoking_rooms,
              label: 'smoking',
              value: safeRisk.smoking,
            ),
            const SizedBox(height: 12),
            _buildRiskFactorCard(
              context,
              icon: Icons.family_restroom,
              label: 'genetic_disease',
              value: safeRisk.geneticDisease,
            ),
            const SizedBox(height: 12),
            _buildRiskFactorCard(
              context,
              icon: Icons.directions_run,
              label: 'physical_activity',
              value: safeRisk.physicalActivity.isNotEmpty,
              customValue: safeRisk.physicalActivity,
            ),
            const SizedBox(height: 24),

            // Medical Info Section - Enhanced design
            _buildSectionTitle(context, 'medical_info'),
            const SizedBox(height: 16),
            _buildInfoCard(
              context,
              icon: Icons.medication,
              label: 'medicine_type',
              value:
                  safeRisk.medicineType.isEmpty ? '-' : safeRisk.medicineType,
            ),
            const SizedBox(height: 12),
            _buildInfoCard(
              context,
              icon: Icons.bloodtype,
              label: 'diabetes_type',
              value:
                  safeRisk.diabetesType.isEmpty ? '-' : safeRisk.diabetesType,
            ),
            const SizedBox(height: 12),
            _buildInfoCard(
              context,
              icon: Icons.water_drop,
              label: 'sugar_pregnancy',
              value:
                  safeRisk.sugarPregnancy > 0
                      ? safeRisk.sugarPregnancy.toString()
                      : '-',
            ),
            const SizedBox(height: 32),

            // Action Buttons - Enhanced design
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _showUpdateRiskDialog(context, safeRisk),
                    icon: const Icon(Icons.edit),
                    label: Text(
                      context.read<LocaleCubit>().translate('update'),
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        vertical: 16,
                        horizontal: 24,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 4,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      if (safeRisk.id != null) {
                        _showDeleteConfirmation(context, safeRisk.id!);
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        vertical: 16,
                        horizontal: 24,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 4,
                    ),
                    icon: const Icon(Icons.delete),
                    label: Text(
                      context.read<LocaleCubit>().translate('delete'),
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(BuildContext context, String key) => Container(
    margin: const EdgeInsets.only(bottom: 16),
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    decoration: BoxDecoration(
      color: Colors.blue.withValues(alpha: 0.1),
      borderRadius: BorderRadius.circular(8),
    ),
    child: Text(
      context.read<LocaleCubit>().translate(key),
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: Colors.blue,
      ),
    ),
  );

  Widget _buildMetricCard(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String value,
    required String unit,
    required Color color,
  }) {
    return Card(
      elevation: 4,
      shadowColor: Colors.black.withValues(alpha: 0.1),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(height: 12),
            Text(
              '$value $unit',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              context.read<LocaleCubit>().translate(label),
              style: const TextStyle(
                fontSize: 12,
                color: Colors.grey,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRiskFactorCard(
    BuildContext context, {
    required IconData icon,
    required String label,
    required bool value,
    String? customValue,
  }) {
    return Card(
      elevation: 4,
      shadowColor: Colors.black.withValues(alpha: 0.1),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: Colors.blue.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: Colors.blue, size: 20),
        ),
        title: Text(
          context.read<LocaleCubit>().translate(label),
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        trailing:
            customValue != null
                ? Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.green.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    customValue,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: Colors.green,
                    ),
                  ),
                )
                : Container(
                  width: 48,
                  height: 28,
                  decoration: BoxDecoration(
                    color:
                        value
                            ? Colors.red.withValues(alpha: 0.1)
                            : Colors.green.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 18,
                        height: 18,
                        decoration: BoxDecoration(
                          color: value ? Colors.red : Colors.green,
                          borderRadius: BorderRadius.circular(9),
                        ),
                      ),
                    ],
                  ),
                ),
        subtitle:
            customValue == null
                ? Text(
                  value
                      ? context.read<LocaleCubit>().translate('yes')
                      : context.read<LocaleCubit>().translate('no'),
                  style: TextStyle(
                    color: value ? Colors.red : Colors.green,
                    fontWeight: FontWeight.w500,
                  ),
                )
                : null,
      ),
    );
  }

  Widget _buildInfoCard(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Card(
      elevation: 4,
      shadowColor: Colors.black.withValues(alpha: 0.1),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: Colors.orange.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: Colors.orange, size: 20),
        ),
        title: Text(
          context.read<LocaleCubit>().translate(label),
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        trailing: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.grey.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            value,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: Colors.grey,
            ),
          ),
        ),
      ),
    );
  }

  String _getBmiCategory(BuildContext context, double bmi) {
    final locale = context.read<LocaleCubit>();
    if (bmi < 18.5) return locale.translate('bmi_underweight');
    if (bmi < 25) return locale.translate('bmi_normal');
    if (bmi < 30) return locale.translate('bmi_overweight');
    return locale.translate('bmi_obese');
  }

  Color _getBmiColor(double bmi) {
    if (bmi < 18.5) return Colors.amber;
    if (bmi < 25) return Colors.green;
    if (bmi < 30) return Colors.orange;
    return Colors.red;
  }

  void _showDeleteConfirmation(BuildContext context, int riskId) {
    showDialog(
      context: context,
      builder:
          (dialogContext) => AlertDialog(
            title: Text(context.read<LocaleCubit>().translate('delete_risk')),
            content: Text(
              context.read<LocaleCubit>().translate('delete_risk_confirm'),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(dialogContext),
                child: Text(context.read<LocaleCubit>().translate('cancel')),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(dialogContext);
                  context.read<RiskCubit>().deleteRisk(riskId);
                },
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                child: Text(context.read<LocaleCubit>().translate('delete')),
              ),
            ],
          ),
    );
  }

  void _showUpdateRiskDialog(BuildContext context, RiskEntity risk) {
    showDialog(
      context: context,
      builder: (context) => UpdateRiskDialog(risk: risk),
    );
  }
}
