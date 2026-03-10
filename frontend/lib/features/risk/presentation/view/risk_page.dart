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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // BMI Gauge Card
          _buildBmiGaugeCard(context),
          const SizedBox(height: 16),

          // Health Metrics Section
          _buildSectionTitle(context, 'health_metrics'),
          const SizedBox(height: 8),
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

          // Risk Factors Section
          _buildSectionTitle(context, 'risk_factors'),
          const SizedBox(height: 8),
          _buildRiskFactorCard(
            context,
            icon: Icons.smoking_rooms,
            label: 'smoking',
            value: risk.smoking,
          ),
          const SizedBox(height: 8),
          _buildRiskFactorCard(
            context,
            icon: Icons.family_restroom,
            label: 'genetic_disease',
            value: risk.geneticDisease,
          ),
          const SizedBox(height: 8),
          _buildRiskFactorCard(
            context,
            icon: Icons.directions_run,
            label: 'physical_activity',
            value: risk.physicalActivity.isNotEmpty,
            customValue: risk.physicalActivity,
          ),
          const SizedBox(height: 24),

          // Medical Info Section
          _buildSectionTitle(context, 'medical_info'),
          const SizedBox(height: 8),
          _buildInfoCard(
            context,
            icon: Icons.medication,
            label: 'medicine_type',
            value: risk.medicineType.isEmpty ? '-' : risk.medicineType,
          ),
          const SizedBox(height: 8),
          _buildInfoCard(
            context,
            icon: Icons.bloodtype,
            label: 'diabetes_type',
            value: risk.diabetesType.isEmpty ? '-' : risk.diabetesType,
          ),
          const SizedBox(height: 8),
          _buildInfoCard(
            context,
            icon: Icons.water_drop,
            label: 'sugar_pregnancy',
            value: risk.sugarPregnancy.toString(),
          ),
          const SizedBox(height: 24),

          // Action Buttons
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => _showUpdateRiskDialog(context, risk),
                  icon: const Icon(Icons.edit),
                  label: Text(context.read<LocaleCubit>().translate('update')),
                ),
              ),
              const SizedBox(width: 12),
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
                  ),
                  icon: const Icon(Icons.delete),
                  label: Text(context.read<LocaleCubit>().translate('delete')),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(BuildContext context, String key) => Text(
    context.read<LocaleCubit>().translate(key),
    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
  );

  Widget _buildBmiGaugeCard(BuildContext context) {
    final bmi = risk.bmi;
    final bmiCategory = _getBmiCategory(bmi);
    final bmiColor = _getBmiColor(bmi);
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            Text(
              context.read<LocaleCubit>().translate('bmi'),
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 16),
            Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                  width: 150,
                  height: 150,
                  child: CircularProgressIndicator(
                    value: (bmi / 50).clamp(0.0, 1.0),
                    strokeWidth: 15,
                    backgroundColor: Colors.grey[200],
                    valueColor: AlwaysStoppedAnimation<Color>(bmiColor),
                  ),
                ),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      bmi.toStringAsFixed(1),
                      style: TextStyle(
                        fontSize: 36,
                        fontWeight: FontWeight.bold,
                        color: bmiColor,
                      ),
                    ),
                    Text(
                      bmiCategory,
                      style: TextStyle(
                        fontSize: 14,
                        color: bmiColor,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildBmiLegend('Underweight', '<18.5', Colors.amber),
                _buildBmiLegend('Normal', '18.5-25', Colors.green),
                _buildBmiLegend('Overweight', '25-30', Colors.orange),
                _buildBmiLegend('Obese', '>30', Colors.red),
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
  }) => Card(
    elevation: 2,
    child: Padding(
      padding: const EdgeInsets.all(12.0),
      child: Column(
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(height: 8),
          Text(
            value + (unit.isNotEmpty ? ' $unit' : ''),
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            context.read<LocaleCubit>().translate(label),
            style: const TextStyle(fontSize: 12, color: Colors.grey),
          ),
        ],
      ),
    ),
  );

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
      elevation: 2,
      child: ListTile(
        leading: Icon(icon, color: color),
        title: Text(context.read<LocaleCubit>().translate(label)),
        trailing:
            customValue != null
                ? Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    customValue,
                    style: TextStyle(color: color, fontWeight: FontWeight.w500),
                  ),
                )
                : Icon(
                  value ? Icons.warning : Icons.check_circle,
                  color: value ? Colors.red : Colors.green,
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
  }) => Card(
    elevation: 2,
    child: ListTile(
      leading: Icon(icon, color: Colors.blueGrey),
      title: Text(context.read<LocaleCubit>().translate(label)),
      trailing: Text(
        value,
        style: const TextStyle(fontWeight: FontWeight.w500),
      ),
    ),
  );

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
