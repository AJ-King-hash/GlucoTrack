// features/risk/presentation/widgets/update_risk_dialog.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:untitled10/core/localization/locale_cubit.dart';
import 'package:untitled10/features/risk/domain/entity/risk_entity.dart';
import 'package:untitled10/features/risk/presentation/manager/risk_cubit.dart';

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
  late int sugarPregnancy;
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

              CheckboxListTile(
                title: Text(locale.translate('smoking')),
                value: smoking,
                onChanged: (v) => setState(() => smoking = v!),
              ),

              // Add your Dropdowns and other fields here...
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
  }) {
    return TextFormField(
      initialValue: initial,
      decoration: InputDecoration(
        labelText: context.read<LocaleCubit>().translate(label),
      ),
      keyboardType: TextInputType.number,
      onSaved: onSave,
      validator:
          (v) =>
              v!.isEmpty
                  ? context.read<LocaleCubit>().translate('required_field')
                  : null,
    );
  }
}
