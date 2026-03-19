import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:untitled10/core/localization/locale_cubit.dart';
import 'package:untitled10/features/risk/domain/entity/risk_entity.dart';
import 'package:untitled10/features/risk/presentation/manager/risk_cubit.dart';
import 'package:untitled10/features/user/presentation/manager/user_cubit.dart';
import 'package:untitled10/features/user/presentation/manager/user_state.dart';
import 'package:untitled10/features/home/presentation/widgets/dropdown.dart';

class UpdateRiskDialog extends StatefulWidget {
  final RiskEntity risk;

  const UpdateRiskDialog({super.key, required this.risk});

  @override
  State<UpdateRiskDialog> createState() => _UpdateRiskDialogState();
}

class _UpdateRiskDialogState extends State<UpdateRiskDialog> {
  final _formKey = GlobalKey<FormState>();
  late int age;
  late double weight, height;
  late int? sugarPregnancy;
  late bool smoking, geneticDisease;
  late String physicalActivity, diabetesType, medicineType;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    // Initialize local state from the entity
    age = widget.risk.age;
    weight = widget.risk.weight;
    height = widget.risk.height;
    sugarPregnancy = widget.risk.sugarPregnancy;
    smoking = widget.risk.smoking;
    geneticDisease = widget.risk.geneticDisease;
    physicalActivity = widget.risk.physicalActivity;
    diabetesType = widget.risk.diabetesType;
    medicineType = widget.risk.medicineType;
  }

  @override
  Widget build(BuildContext context) {
    final locale = context.read<LocaleCubit>();
    final userCubit = context.read<UserCubit>();
    final user = (userCubit.state as UserLoaded?)?.userModel;
    final isFemale = user?.gender == 'female';

    return AlertDialog(
      title: Text(locale.translate('update_risk')),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildTextField(
                label: 'age',
                initial: age.toString(),
                onSave: (v) => age = int.parse(v!),
              ),
              _buildTextField(
                label: 'weight',
                initial: weight.toString(),
                onSave: (v) => weight = double.parse(v!),
              ),
              _buildTextField(
                label: 'height',
                initial: height.toString(),
                onSave: (v) => height = double.parse(v!),
              ),

              // Sugar Pregnancy - only show for female
              if (isFemale)
                _buildTextField(
                  label: 'sugar_pregnancy',
                  initial: sugarPregnancy?.toString() ?? '',
                  onSave:
                      (v) =>
                          sugarPregnancy =
                              v?.isEmpty == false ? int.tryParse(v!) : null,
                  required: false,
                ),

              CheckboxListTile(
                title: Text(locale.translate('smoking')),
                value: smoking,
                onChanged: (v) => setState(() => smoking = v!),
              ),

              CheckboxListTile(
                title: Text(locale.translate('genetic_disease')),
                value: geneticDisease,
                onChanged: (v) => setState(() => geneticDisease = v!),
              ),

              _buildTextField(
                label: 'physical_activity',
                initial: physicalActivity,
                onSave: (v) => physicalActivity = v!,
                keyboardType: TextInputType.text,
              ),

              Dropdown(
                label: locale.translate('diabetes_type'),
                items: const ['d1', 'd2'],
                initialValue: diabetesType.isNotEmpty ? diabetesType : null,
                onChanged: (v) => setState(() => diabetesType = v ?? ''),
                validator:
                    (v) =>
                        v == null || v.isEmpty
                            ? locale.translate('please_select_diabetes_type')
                            : null,
              ),
              const SizedBox(height: 16),
              Dropdown(
                label: locale.translate('medicine_type'),
                items: const ['Insuline', 'MouthSugarLower'],
                initialValue: medicineType.isNotEmpty ? medicineType : null,
                onChanged: (v) => setState(() => medicineType = v ?? ''),
                validator:
                    (v) =>
                        v == null || v.isEmpty
                            ? locale.translate('please_select_medicine_type')
                            : null,
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(locale.translate('cancel')),
        ),
        ElevatedButton(
          onPressed: isLoading ? null : _submit,
          child:
              isLoading
                  ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                  : Text(locale.translate('update')),
        ),
      ],
    );
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      setState(() => isLoading = true);

      final bmi = height > 0 ? weight / (height * height) : 0.0;

      context.read<RiskCubit>().updateRisk(
        widget.risk.id!,
        widget.risk.copyWith(
          // Using copyWith is much safer/cleaner
          age: age,
          weight: weight,
          height: height,
          bmi: bmi,
          smoking: smoking,
          sugarPregnancy: sugarPregnancy,
          geneticDisease: geneticDisease,
          physicalActivity: physicalActivity,
          diabetesType: diabetesType,
          medicineType: medicineType,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
      );
      Navigator.pop(context);
    }
  }

  Widget _buildTextField({
    required String label,
    required String initial,
    required FormFieldSetter<String> onSave,
    TextInputType keyboardType = TextInputType.number,
    bool required = true,
  }) {
    return TextFormField(
      initialValue: initial,
      decoration: InputDecoration(
        labelText: context.read<LocaleCubit>().translate(label),
      ),
      keyboardType: keyboardType,
      onSaved: onSave,
      validator:
          required
              ? (v) =>
                  v!.isEmpty
                      ? context.read<LocaleCubit>().translate('required_field')
                      : null
              : null,
    );
  }
}
