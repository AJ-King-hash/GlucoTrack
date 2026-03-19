import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:untitled10/core/localization/locale_cubit.dart';
import 'package:untitled10/features/risk/domain/entity/risk_entity.dart';
import 'package:untitled10/features/risk/presentation/manager/risk_cubit.dart';
import 'package:untitled10/features/home/presentation/widgets/dropdown.dart';
import 'package:untitled10/features/user/presentation/manager/user_cubit.dart';
import 'package:untitled10/features/user/presentation/manager/user_state.dart';
// import 'package:untitled10/features/auth/data/models/user_model.dart';

class CreateRiskDialog extends StatefulWidget {
  const CreateRiskDialog({super.key});

  @override
  State<CreateRiskDialog> createState() => _CreateRiskDialogState();
}

class _CreateRiskDialogState extends State<CreateRiskDialog> {
  final _formKey = GlobalKey<FormState>();

  // Form State
  int age = 0;
  double weight = 0.0;
  double height = 0.0;
  int? sugarPregnancy;
  bool smoking = false;
  bool geneticDisease = false;
  String physicalActivity = '';
  String diabetesType = '';
  String medicineType = '';
  bool isLoading = false;

  @override
  Widget build(BuildContext context) {
    final locale = context.read<LocaleCubit>();
    final userCubit = context.read<UserCubit>();
    final user = (userCubit.state as UserLoaded?)?.userModel;
    final isFemale = user?.gender == 'female';

    return AlertDialog(
      title: Text(locale.translate('create_new_risk')),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          // Prevents bottom overflow
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildTextFormField(
                label: 'age',
                hint: 'please_enter_age',
                onSaved: (v) => age = int.tryParse(v!) ?? 0,
              ),
              _buildTextFormField(
                label: 'weight',
                hint: 'please_enter_weight',
                onSaved: (v) => weight = double.tryParse(v!) ?? 0.0,
              ),
              _buildTextFormField(
                label: 'height',
                hint: 'please_enter_height',
                onSaved: (v) => height = double.tryParse(v!) ?? 0.0,
              ),
              // Sugar Pregnancy - only show for female
              if (isFemale)
                _buildTextFormField(
                  label: 'sugar_pregnancy',
                  onSaved:
                      (v) =>
                          sugarPregnancy =
                              v?.isEmpty == false ? int.tryParse(v!) : null,
                  required: false,
                ),
              CheckboxListTile(
                title: Text(locale.translate('smoking')),
                value: smoking,
                onChanged: (v) => setState(() => smoking = v ?? false),
              ),
              CheckboxListTile(
                title: Text(locale.translate('genetic_disease')),
                value: geneticDisease,
                onChanged: (v) => setState(() => geneticDisease = v ?? false),
              ),
              _buildTextFormField(
                label: 'physical_activity',
                hint: 'please_enter_physical_activity',
                keyboardType: TextInputType.text,
                onSaved: (v) => physicalActivity = v!,
              ),
              // Use your custom Dropdown widget
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
          onPressed: isLoading ? null : _handleCreate,
          child:
              isLoading
                  ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                  : Text(locale.translate('create')),
        ),
      ],
    );
  }

  // Helper to keep the column clean
  Widget _buildTextFormField({
    required String label,
    String? hint,
    required FormFieldSetter<String> onSaved,
    TextInputType keyboardType = TextInputType.number,
    bool required = true,
  }) {
    return TextFormField(
      decoration: InputDecoration(
        labelText: context.read<LocaleCubit>().translate(label),
      ),
      keyboardType: keyboardType,
      onSaved: onSaved,
      validator:
          required
              ? (v) =>
                  v!.isEmpty
                      ? context.read<LocaleCubit>().translate(hint ?? '')
                      : null
              : null,
    );
  }

  void _handleCreate() {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      setState(() => isLoading = true);

      final bmi = height > 0 ? weight / (height * height) : 0.0;

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
          createdAt: DateTime.now(),
        ),
      );
      Navigator.pop(context);
    }
  }
}
