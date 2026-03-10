import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:untitled10/core/localization/locale_cubit.dart';
import 'package:untitled10/features/home/presentation/widgets/dropdown.dart';
import 'package:untitled10/features/risk/domain/entity/risk_entity.dart';
import 'package:untitled10/features/risk/presentation/manager/risk_cubit.dart';
import 'package:untitled10/features/risk/presentation/manager/risk_state.dart';

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
    // Fetch risk data when page loads
    // The backend gets user ID from JWT token, so we pass any value
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
    final formKey = GlobalKey<FormState>();
    int age = 0;
    double weight = 0.0;
    double height = 0.0;
    int sugarPregnancy = 0;
    bool smoking = false;
    bool geneticDisease = false;
    String physicalActivity = '';
    String diabetesType = '';
    String medicineType = '';
    bool isLoading = false;

    showDialog(
      context: context,
      builder:
          (dialogContext) => StatefulBuilder(
            builder: (dialogContext, setDialogState) {
              return AlertDialog(
                title: Text(
                  context.read<LocaleCubit>().translate('create_new_risk'),
                ),
                content: Form(
                  key: formKey,
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        TextFormField(
                          decoration: InputDecoration(
                            labelText: context.read<LocaleCubit>().translate(
                              'age',
                            ),
                          ),
                          keyboardType: TextInputType.number,
                          onSaved: (value) => age = int.tryParse(value!) ?? 0,
                          validator:
                              (value) =>
                                  value!.isEmpty
                                      ? context.read<LocaleCubit>().translate(
                                        'please_enter_age',
                                      )
                                      : null,
                        ),
                        TextFormField(
                          decoration: InputDecoration(
                            labelText: context.read<LocaleCubit>().translate(
                              'weight',
                            ),
                          ),
                          keyboardType: TextInputType.number,
                          onSaved:
                              (value) =>
                                  weight = double.tryParse(value!) ?? 0.0,
                          validator:
                              (value) =>
                                  value!.isEmpty
                                      ? context.read<LocaleCubit>().translate(
                                        'please_enter_weight',
                                      )
                                      : null,
                        ),
                        TextFormField(
                          decoration: InputDecoration(
                            labelText: context.read<LocaleCubit>().translate(
                              'height',
                            ),
                          ),
                          keyboardType: TextInputType.number,
                          onSaved:
                              (value) =>
                                  height = double.tryParse(value!) ?? 0.0,
                          validator:
                              (value) =>
                                  value!.isEmpty
                                      ? context.read<LocaleCubit>().translate(
                                        'please_enter_height',
                                      )
                                      : null,
                        ),
                        TextFormField(
                          decoration: InputDecoration(
                            labelText: context.read<LocaleCubit>().translate(
                              'sugar_pregnancy',
                            ),
                          ),
                          keyboardType: TextInputType.number,
                          onSaved:
                              (value) =>
                                  sugarPregnancy = int.tryParse(value!) ?? 0,
                        ),
                        CheckboxListTile(
                          title: Text(
                            context.read<LocaleCubit>().translate('smoking'),
                          ),
                          value: smoking,
                          onChanged:
                              (value) => setDialogState(
                                () => smoking = value ?? false,
                              ),
                        ),
                        CheckboxListTile(
                          title: Text(
                            context.read<LocaleCubit>().translate(
                              'genetic_disease',
                            ),
                          ),
                          value: geneticDisease,
                          onChanged:
                              (value) => setDialogState(
                                () => geneticDisease = value ?? false,
                              ),
                        ),
                        TextFormField(
                          decoration: InputDecoration(
                            labelText: context.read<LocaleCubit>().translate(
                              'physical_activity',
                            ),
                          ),
                          onSaved: (value) => physicalActivity = value!,
                          validator:
                              (value) =>
                                  value!.isEmpty
                                      ? context.read<LocaleCubit>().translate(
                                        'please_enter_physical_activity',
                                      )
                                      : null,
                        ),
                        Dropdown(
                          label: context.read<LocaleCubit>().translate(
                            'diabetes_type',
                          ),
                          items: ['d1', 'd2'],
                          initialValue:
                              diabetesType.isNotEmpty ? diabetesType : null,
                          onChanged:
                              (value) => setDialogState(
                                () => diabetesType = value ?? '',
                              ),
                          validator:
                              (value) =>
                                  value == null || value.isEmpty
                                      ? context.read<LocaleCubit>().translate(
                                        'please_select_diabetes_type',
                                      )
                                      : null,
                        ),
                        const SizedBox(height: 16),
                        Dropdown(
                          label: context.read<LocaleCubit>().translate(
                            'medicine_type',
                          ),
                          items: ['Insuline', 'MouthSugarLower'],
                          initialValue:
                              medicineType.isNotEmpty ? medicineType : null,
                          onChanged:
                              (value) => setDialogState(
                                () => medicineType = value ?? '',
                              ),
                          validator:
                              (value) =>
                                  value == null || value.isEmpty
                                      ? context.read<LocaleCubit>().translate(
                                        'please_select_medicine_type',
                                      )
                                      : null,
                        ),
                      ],
                    ),
                  ),
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text(
                      context.read<LocaleCubit>().translate('cancel'),
                    ),
                  ),
                  ElevatedButton(
                    onPressed:
                        isLoading
                            ? null
                            : () async {
                              if (formKey.currentState!.validate()) {
                                formKey.currentState!.save();
                                setDialogState(() => isLoading = true);

                                final bmi =
                                    height > 0
                                        ? weight / (height * height)
                                        : 0.0;
                                context.read<RiskCubit>().createRisk(
                                  RiskEntity(
                                    age: age,
                                    weight: weight,
                                    height: height,
                                    bmi: bmi,
                                    sugarPregnancy: sugarPregnancy,
                                    smoking: smoking,
                                    geneticDisease: geneticDisease,
                                    physicalActivity: physicalActivity,
                                    diabetesType: diabetesType,
                                    medicineType: medicineType,
                                  ),
                                );
                                Navigator.pop(dialogContext);
                              }
                            },
                    child:
                        isLoading
                            ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                            : Text(
                              context.read<LocaleCubit>().translate('create'),
                            ),
                  ),
                ],
              );
            },
          ),
    );
  }
}

class RiskDetailsView extends StatelessWidget {
  final RiskEntity risk;

  const RiskDetailsView({super.key, required this.risk});

  @override
  Widget build(BuildContext context) {
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
                                _getBmiCategory(risk.bmi),
                                style: TextStyle(
                                  fontSize: 14,
                                  color: _getBmiColor(
                                    risk.bmi,
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
                            risk.bmi.toStringAsFixed(1),
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: _getBmiColor(risk.bmi),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    LinearProgressIndicator(
                      value: (risk.bmi / 40).clamp(0, 1),
                      backgroundColor: Colors.grey.withValues(alpha: 0.2),
                      valueColor: AlwaysStoppedAnimation<Color>(
                        _getBmiColor(risk.bmi),
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
                    value: risk.age.toString(),
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
                    value: risk.weight.toStringAsFixed(1),
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
                    value: risk.height.toStringAsFixed(2),
                    unit: 'm',
                    color: Colors.purple,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Risk Factors Section - Enhanced design
            _buildSectionTitle(context, 'risk_factors'),
            const SizedBox(height: 16),
            _buildRiskFactorCard(
              context,
              icon: Icons.smoking_rooms,
              label: 'smoking',
              value: risk.smoking,
            ),
            const SizedBox(height: 12),
            _buildRiskFactorCard(
              context,
              icon: Icons.family_restroom,
              label: 'genetic_disease',
              value: risk.geneticDisease,
            ),
            const SizedBox(height: 12),
            _buildRiskFactorCard(
              context,
              icon: Icons.directions_run,
              label: 'physical_activity',
              value: risk.physicalActivity.isNotEmpty,
              customValue: risk.physicalActivity,
            ),
            const SizedBox(height: 24),

            // Medical Info Section - Enhanced design
            _buildSectionTitle(context, 'medical_info'),
            const SizedBox(height: 16),
            _buildInfoCard(
              context,
              icon: Icons.medication,
              label: 'medicine_type',
              value: risk.medicineType.isEmpty ? '-' : risk.medicineType,
            ),
            const SizedBox(height: 12),
            _buildInfoCard(
              context,
              icon: Icons.bloodtype,
              label: 'diabetes_type',
              value: risk.diabetesType.isEmpty ? '-' : risk.diabetesType,
            ),
            const SizedBox(height: 12),
            _buildInfoCard(
              context,
              icon: Icons.water_drop,
              label: 'sugar_pregnancy',
              value: risk.sugarPregnancy.toString(),
            ),
            const SizedBox(height: 32),

            // Action Buttons - Enhanced design
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _showUpdateRiskDialog(context, risk),
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
                      if (risk.id != null) {
                        _showDeleteConfirmation(context, risk.id!);
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

  Widget _buildBmiGaugeCard(BuildContext context) {
    final bmi = risk.bmi;
    final bmiCategory = _getBmiCategory(bmi);
    final bmiColor = _getBmiColor(bmi);
    return Card(
      elevation: 8,
      shadowColor: Colors.black.withValues(alpha: 0.1),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
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
                        bmiCategory,
                        style: TextStyle(
                          fontSize: 14,
                          color: bmiColor.withValues(alpha: 0.8),
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
                    bmi.toStringAsFixed(1),
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: bmiColor,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            LinearProgressIndicator(
              value: (bmi / 40).clamp(0, 1),
              backgroundColor: Colors.grey.withValues(alpha: 0.2),
              valueColor: AlwaysStoppedAnimation<Color>(bmiColor),
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
    );
  }

  Widget _buildBmiLegend(String label, String range, Color color) => Column(
    children: [
      Container(
        width: 12,
        height: 12,
        decoration: BoxDecoration(color: color, shape: BoxShape.circle),
      ),
      const SizedBox(height: 4),
      Text(label, style: const TextStyle(fontSize: 10)),
      Text(range, style: const TextStyle(fontSize: 8, color: Colors.grey)),
    ],
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
    final isPositive = customValue != null ? customValue.isNotEmpty : value;
    final color = isPositive ? Colors.orange : Colors.green;
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

  String _getBmiCategory(double bmi) {
    if (bmi < 18.5) return 'Underweight';
    if (bmi < 25) return 'Normal';
    if (bmi < 30) return 'Overweight';
    return 'Obese';
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
    final formKey = GlobalKey<FormState>();
    int age = risk.age;
    double weight = risk.weight;
    double height = risk.height;
    int sugarPregnancy = risk.sugarPregnancy;
    bool smoking = risk.smoking;
    bool geneticDisease = risk.geneticDisease;
    String physicalActivity = risk.physicalActivity;
    String diabetesType = risk.diabetesType;
    String medicineType = risk.medicineType;
    bool isLoading = false;

    showDialog(
      context: context,
      builder:
          (dialogContext) => StatefulBuilder(
            builder: (dialogContext, setDialogState) {
              return AlertDialog(
                title: Text(
                  context.read<LocaleCubit>().translate('update_risk'),
                ),
                content: Form(
                  key: formKey,
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        TextFormField(
                          initialValue: age.toString(),
                          decoration: InputDecoration(
                            labelText: context.read<LocaleCubit>().translate(
                              'age',
                            ),
                          ),
                          keyboardType: TextInputType.number,
                          onSaved: (value) => age = int.tryParse(value!) ?? 0,
                          validator:
                              (value) =>
                                  value!.isEmpty
                                      ? context.read<LocaleCubit>().translate(
                                        'please_enter_age',
                                      )
                                      : null,
                        ),
                        TextFormField(
                          initialValue: weight.toString(),
                          decoration: InputDecoration(
                            labelText: context.read<LocaleCubit>().translate(
                              'weight',
                            ),
                          ),
                          keyboardType: TextInputType.number,
                          onSaved:
                              (value) =>
                                  weight = double.tryParse(value!) ?? 0.0,
                          validator:
                              (value) =>
                                  value!.isEmpty
                                      ? context.read<LocaleCubit>().translate(
                                        'please_enter_weight',
                                      )
                                      : null,
                        ),
                        TextFormField(
                          initialValue: height.toString(),
                          decoration: InputDecoration(
                            labelText: context.read<LocaleCubit>().translate(
                              'height',
                            ),
                          ),
                          keyboardType: TextInputType.number,
                          onSaved:
                              (value) =>
                                  height = double.tryParse(value!) ?? 0.0,
                          validator:
                              (value) =>
                                  value!.isEmpty
                                      ? context.read<LocaleCubit>().translate(
                                        'please_enter_height',
                                      )
                                      : null,
                        ),
                        TextFormField(
                          initialValue: sugarPregnancy.toString(),
                          decoration: InputDecoration(
                            labelText: context.read<LocaleCubit>().translate(
                              'sugar_pregnancy',
                            ),
                          ),
                          keyboardType: TextInputType.number,
                          onSaved:
                              (value) =>
                                  sugarPregnancy = int.tryParse(value!) ?? 0,
                        ),
                        CheckboxListTile(
                          title: Text(
                            context.read<LocaleCubit>().translate('smoking'),
                          ),
                          value: smoking,
                          onChanged:
                              (value) => setDialogState(
                                () => smoking = value ?? false,
                              ),
                        ),
                        CheckboxListTile(
                          title: Text(
                            context.read<LocaleCubit>().translate(
                              'genetic_disease',
                            ),
                          ),
                          value: geneticDisease,
                          onChanged:
                              (value) => setDialogState(
                                () => geneticDisease = value ?? false,
                              ),
                        ),
                        TextFormField(
                          initialValue: physicalActivity,
                          decoration: InputDecoration(
                            labelText: context.read<LocaleCubit>().translate(
                              'physical_activity',
                            ),
                          ),
                          onSaved: (value) => physicalActivity = value!,
                          validator:
                              (value) =>
                                  value!.isEmpty
                                      ? context.read<LocaleCubit>().translate(
                                        'please_enter_physical_activity',
                                      )
                                      : null,
                        ),
                        Dropdown(
                          label: context.read<LocaleCubit>().translate(
                            'diabetes_type',
                          ),
                          items: ['d1', 'd2'],
                          initialValue:
                              diabetesType.isNotEmpty ? diabetesType : null,
                          onChanged:
                              (value) => setDialogState(
                                () => diabetesType = value ?? '',
                              ),
                          validator:
                              (value) =>
                                  value == null || value.isEmpty
                                      ? context.read<LocaleCubit>().translate(
                                        'please_select_diabetes_type',
                                      )
                                      : null,
                        ),
                        const SizedBox(height: 16),
                        Dropdown(
                          label: context.read<LocaleCubit>().translate(
                            'medicine_type',
                          ),
                          items: ['Insuline', 'MouthSugarLower'],
                          initialValue:
                              medicineType.isNotEmpty ? medicineType : null,
                          onChanged:
                              (value) => setDialogState(
                                () => medicineType = value ?? '',
                              ),
                          validator:
                              (value) =>
                                  value == null || value.isEmpty
                                      ? context.read<LocaleCubit>().translate(
                                        'please_select_medicine_type',
                                      )
                                      : null,
                        ),
                      ],
                    ),
                  ),
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text(
                      context.read<LocaleCubit>().translate('cancel'),
                    ),
                  ),
                  ElevatedButton(
                    onPressed:
                        isLoading
                            ? null
                            : () {
                              if (formKey.currentState!.validate()) {
                                formKey.currentState!.save();
                                setDialogState(() => isLoading = true);
                                final bmi =
                                    height > 0
                                        ? weight / (height * height)
                                        : 0.0;
                                if (risk.id != null) {
                                  context.read<RiskCubit>().updateRisk(
                                    risk.id!,
                                    RiskEntity(
                                      id: risk.id,
                                      userId: risk.userId,
                                      age: age,
                                      weight: weight,
                                      height: height,
                                      bmi: bmi,
                                      sugarPregnancy: sugarPregnancy,
                                      smoking: smoking,
                                      geneticDisease: geneticDisease,
                                      physicalActivity: physicalActivity,
                                      diabetesType: diabetesType,
                                      medicineType: medicineType,
                                      createdAt: risk.createdAt,
                                      updatedAt: DateTime.now(),
                                    ),
                                  );
                                }
                                Navigator.pop(dialogContext);
                              }
                            },
                    child:
                        isLoading
                            ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                            : Text(
                              context.read<LocaleCubit>().translate('update'),
                            ),
                  ),
                ],
              );
            },
          ),
    );
  }
}
